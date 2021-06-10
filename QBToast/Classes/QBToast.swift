//
//  QBToast.swift
//
//  Copyright (c) 2021 sjc-bui <bui@setjapan.co.jp>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import ObjectiveC

public typealias QBToastCompletion = ((Bool) -> Void)?

public class QBToast: UIViewController {

  public var message: String?

  public var style: QBToastStyle!

  public var position: QBToastPosition

  public var duration: TimeInterval

  public var state: QBToastState

  var completionHandler: QBToastCompletion = nil

  private struct QBToastKey {
    static var timer    = "timer"
    static var queue    = "queue"
    static var active   = "active"
    static var position = "position"
    static var duration = "duration"
  }

  public init(message: String?,
              style: QBToastStyle = QBToastManager.shared.style,
              position: QBToastPosition = QBToastManager.shared.position,
              duration: TimeInterval = QBToastManager.shared.duration,
              state: QBToastState = QBToastManager.shared.state) {
    self.message  = message
    self.style    = style
    self.position = position
    self.duration = duration
    self.state    = state
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // Toast message queue
  private var queue: NSMutableArray {
    get {
      if let queue = objc_getAssociatedObject(UIView.self, &QBToastKey.queue) as? NSMutableArray {
        return queue
      } else {
        let queue = NSMutableArray()
        objc_setAssociatedObject(UIView.self, &QBToastKey.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return queue
      }
    }
  }

  private var activeToasts: NSMutableArray {
    get {
      if let activeToasts = objc_getAssociatedObject(UIView.self, &QBToastKey.active) as? NSMutableArray {
        return activeToasts
      } else {
        let activeToasts = NSMutableArray()
        objc_setAssociatedObject(UIView.self, &QBToastKey.active, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return activeToasts
      }
    }
  }

  public func showToast(completionHandler: QBToastCompletion = nil) {
    do {
      guard let window = UIApplication.shared.keyWindow else { return }
      let toast = try createToastView(message: message, style: style, state: state, window: window)
      self.completionHandler = completionHandler

      if QBToastManager.shared.inQueueEnabled,
         activeToasts.count > 0 {
        objc_setAssociatedObject(toast, &QBToastKey.position, NSNumber(value: position.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(toast, &QBToastKey.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        queue.add(toast)
      } else {
        self.show(toast: toast, duration: duration,
                  position: position, window: window)
      }
    } catch QBToastError.messageIsNil {
      print("Toast message is required!")
    } catch { }
  }

  // MARK: - Create Toast View
  private func createToastView(message: String?,
                               style: QBToastStyle,
                               state: QBToastState,
                               window: UIWindow) throws -> UIView {
    guard message != nil else {
      throw QBToastError.messageIsNil
    }

    var messageLabel: UILabel?
    if let message = message {
      messageLabel                  = UILabel()
      messageLabel?.text            = message
      messageLabel?.textColor       = style.messageColor
      messageLabel?.font            = style.messageFont
      messageLabel?.textAlignment   = .left
      messageLabel?.numberOfLines   = style.messageNumberOfLines
      messageLabel?.lineBreakMode   = .byTruncatingTail
      messageLabel?.backgroundColor = .clear

      let maxSize = CGSize(width : window.bounds.size.width  * style.maxWidthPercentage,
                           height: window.bounds.size.height * style.maxHeightPercentage)
      let messageSize = messageLabel?.sizeThatFits(maxSize)
      if let messageSize = messageSize {
        let actualWidth  = min(messageSize.width , maxSize.width)
        let actualHeight = min(messageSize.height, maxSize.height)
        messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
      }
    }

    var messageRect: CGRect = .zero
    if let messageLabel = messageLabel {
      messageRect.origin.x    = style.toastPadding
      messageRect.origin.y    = style.toastPadding
      messageRect.size.width  = messageLabel.bounds.size.width
      messageRect.size.height = messageLabel.bounds.size.height
    }

    let wrapView = UIView()
    wrapView.autoresizingMask = [.flexibleTopMargin,
                                 .flexibleRightMargin,
                                 .flexibleBottomMargin,
                                 .flexibleLeftMargin]
    wrapView.frame = CGRect(x: 0.0,
                            y: 0.0,
                            width: messageRect.size.width   + (style.toastPadding * 2),
                            height: messageRect.size.height + (style.toastPadding * 2))
    switch state {
      case .success:
        wrapView.backgroundColor = UIColor.success
      case .warning:
        wrapView.backgroundColor = UIColor.warning
      case .error:
        wrapView.backgroundColor = UIColor.error
      case .info:
        wrapView.backgroundColor = UIColor.info
      case .custom:
        wrapView.backgroundColor = style.backgroundColor
    }

    wrapView.layer.cornerRadius = style.cornerRadius

    if style.shadowEnabled {
      wrapView.clipsToBounds       = true
      wrapView.layer.shadowColor   = style.shadowColor.cgColor
      wrapView.layer.shadowOffset  = style.shadowOffset
      wrapView.layer.shadowOpacity = style.shadowOpacity
      wrapView.layer.shadowRadius  = style.shadowRadius
      wrapView.layer.masksToBounds = false
    }

    if let messageLabel = messageLabel {
      messageLabel.frame = messageRect
      wrapView.addSubview(messageLabel)
    }

    return wrapView
  }

  // MARK: - Show Toast
  private func show(toast: UIView,
                    duration: TimeInterval,
                    position: QBToastPosition,
                    window: UIWindow) {
    let endpoint   = position.centerPoint(forToastView: toast, inSuperView: window)
    toast.alpha = 0
    toast.center = endpoint
    toast.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)

    if QBToastManager.shared.tapToDismissEnabled {
      let toastRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
      toast.addGestureRecognizer(toastRecognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }

    activeToasts.add (toast)
    window.addSubview(toast)

    UIView.animate(withDuration: 0.086,
                   delay: 0.0,
                   options: .curveEaseIn) {
      toast.alpha = 1
      toast.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    } completion: { _ in
      let timer = Timer(timeInterval: duration,
                        target: self,
                        selector: #selector(self.toastTimer(_:)),
                        userInfo: toast,
                        repeats: false)
      RunLoop.main.add(timer, forMode: .common)
      objc_setAssociatedObject(toast, &QBToastKey.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  @objc func tapToDismiss(_ recognizer: UIGestureRecognizer) {
    guard let toast = recognizer.view else { return }
    self.hide(toast, byTap: true)
  }

  @objc func toastTimer(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView,
          activeToasts.contains(toast) else { return }
    self.hide(toast)
  }

  // MARK: -  Hide Toast
  private func hide(_ toast: UIView, byTap: Bool = false) {
    guard let window = UIApplication.shared.keyWindow else { return }

    if let timer = objc_getAssociatedObject(toast, &QBToastKey.timer) as? Timer {
      timer.invalidate()
    }

    UIView.animate(withDuration: 0.11,
                   delay: 0.0,
                   options: .curveEaseOut) {
      toast.transform = CGAffineTransform(scaleX: 0.68, y: 0.68)
      toast.alpha = 0
    } completion: { _ in
      self.activeToasts.remove(toast)
      toast.removeFromSuperview()
      self.completionHandler?(byTap)

      if let nextToast = self.queue.firstObject as? UIView,
         let position = objc_getAssociatedObject(nextToast, &QBToastKey.position) as? NSNumber,
         let duration = objc_getAssociatedObject(nextToast, &QBToastKey.duration) as? NSNumber {
        if let toastPosition = QBToastPosition(rawValue: position.intValue) {
          self.queue.removeObject(at: 0)
          self.show(toast: nextToast, duration: duration.doubleValue,
                    position: toastPosition, window: window)
        }
      }
    }
  }
}

// MARK: - Toast Error
private enum QBToastError: Error {
  case messageIsNil
}

// MARK: - Toast States
public enum QBToastState: Int, CaseIterable {
  case success = 0
  case warning = 1
  case error   = 2
  case info    = 3
  case custom  = 4
}

// MARK: - Toast Style
public struct QBToastStyle {

  /** Toast view background color. Default `.black(0.8)`*/
  public var backgroundColor: UIColor

  /** Toast message color*/
  public var messageColor: UIColor

  /** Toast message font*/
  public var messageFont: UIFont

  /** Toast message number of lines*/
  public var messageNumberOfLines: Int

  /** Toast message alignment*/
  public var messageAlignment: NSTextAlignment

  public var maxWidthPercentage: CGFloat

  public var maxHeightPercentage: CGFloat

  /** Toast message padding*/
  public var toastPadding: CGFloat

  /** Corner radius of Toast View*/
  public var cornerRadius: CGFloat

  /** Drop Toast message shadow*/
  public var shadowEnabled: Bool

  /** The shadow color*/
  public var shadowColor: UIColor

  /** The shadow radius*/
  public var shadowRadius: CGFloat

  /** The shadow opacity*/
  public var shadowOpacity: Float

  /** The shadow offset*/
  public var shadowOffset: CGSize

  /** Toast appear, disappear duration*/
  public var fadeDuration: TimeInterval

  public init(
    backgroundColor: UIColor          = UIColor(hex: "#323232"),
    messageColor: UIColor             = .white,
    messageFont: UIFont               = .systemFont(ofSize: 14.0, weight: .medium),
    messageNumberOfLines: Int         = 0,
    messageAlignment: NSTextAlignment = .left,
    maxWidthPercentage: CGFloat       = 0.8,
    maxHeightPercentage: CGFloat      = 0.8,
    toastPadding: CGFloat             = 16.0,
    cornerRadius: CGFloat             = 4.0,
    shadowEnabled: Bool               = true,
    shadowColor: UIColor              = UIColor(hex: "#323232"),
    shadowRadius: CGFloat             = 4.0,
    shadowOpacity: Float              = 0.38,
    shadowOffset: CGSize              = CGSize(width: 1.0, height: 2.0),
    fadeDuration: TimeInterval        = 0.4
  ) {
    self.backgroundColor      = backgroundColor
    self.messageColor         = messageColor
    self.messageFont          = messageFont
    self.messageNumberOfLines = messageNumberOfLines
    self.messageAlignment     = messageAlignment
    self.maxWidthPercentage   = max(min(maxWidthPercentage , 1.0), 0.0)
    self.maxHeightPercentage  = max(min(maxHeightPercentage, 1.0), 0.0)
    self.toastPadding         = toastPadding
    self.cornerRadius         = cornerRadius
    self.shadowEnabled        = shadowEnabled
    self.shadowColor          = shadowColor
    self.shadowRadius         = shadowRadius
    self.shadowOpacity        = shadowOpacity
    self.shadowOffset         = shadowOffset
    self.fadeDuration         = fadeDuration
  }
}

// MARK: - Toast Manager
public class QBToastManager {
  /** Singleton instance*/
  public static let shared = QBToastManager()

  /** Toast style*/
  public var style = QBToastStyle()

  /** Toast states: `.success, .warning, .error, .info, .custom` `Default .custom`*/
  public var state: QBToastState = .custom

  /** Display duration `Default 3.0`*/
  public var duration: TimeInterval = 3.0

  /** Toast display position `Default .bottom`*/
  public var position: QBToastPosition = .bottom

  /** Enable tap action to dismiss toast `Default true`*/
  public var tapToDismissEnabled: Bool = true

  /** Display Toast in queue `Default true`*/
  public var inQueueEnabled: Bool = true
}

// MARK: - Toast Position
public enum QBToastPosition: Int, CaseIterable {
  case top    = 0
  case center = 1
  case bottom = 2

  /** `Toast` display in center point*/
  fileprivate func centerPoint(forToastView    toast: UIView,
                               inSuperView superview: UIView) -> CGPoint {

    let topPadding    = QBToastManager.shared.style.toastPadding + superview.safeArea.top
    let bottomPadding = QBToastManager.shared.style.toastPadding + superview.safeArea.bottom

    switch self {
      case .top:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: (toast.frame.size.height / 2) + topPadding)
      case .center:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: superview.bounds.size.height / 2)
      case .bottom:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: superview.bounds.size.height - (toast.frame.size.height / 2) - bottomPadding)
    }
  }
}

// MARK: - Extension
private extension UIView {
  /**
   Get safeAreaInsets
   */
  var safeArea: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
  }
}

public extension UIColor {
  static let success = UIColor(hex: "#4caf50")
  static let warning = UIColor(hex: "#ff9800")
  static let error   = UIColor(hex: "#f44336")
  static let info    = UIColor(hex: "#2196f3")

  /// - Parameter hexString: hex string
  convenience init(hex hexString: String) {
    var color: UInt32 = 0
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    if Scanner(string: hexString.replacingOccurrences(of: "#", with: "")).scanHexInt32(&color) {
      r = CGFloat((color & 0xFF0000) >> 16) / 255.0
      g = CGFloat((color & 0x00FF00) >>  8) / 255.0
      b = CGFloat( color & 0x0000FF) / 255.0
    }
    self.init(red: r, green: g, blue: b, alpha: 1.0)
  }
}
