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

public typealias Manager = QBToastManager

public final class QBToast: UIViewController {

  public var message: String?

  public var style: QBToastStyle!

  public var position: QBToastPosition

  public var duration: TimeInterval

  public var haptic: QBToastHaptic

  public var state: QBToastState

  private var initialCenter: CGPoint = .zero

  private var originalPoint: CGPoint = .zero

  private var completionHandler: ((Bool) -> Void)?

  private struct QBToastKey {
    static var timer    = "timer"
    static var queue    = "queue"
    static var active   = "active"
    static var position = "position"
    static var duration = "duration"
    static var haptic   = "haptic"
  }

  public init(message: String?,
              style: QBToastStyle = Manager.shared.style,
              position: QBToastPosition = Manager.shared.position,
              duration: TimeInterval = Manager.shared.duration,
              haptic: QBToastHaptic = Manager.shared.haptic,
              state: QBToastState = Manager.shared.state) {
    self.message  = message
    self.style    = style
    self.position = position
    self.duration = duration
    self.haptic   = haptic
    self.state    = state
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // Toast message queue
  private var queue: NSMutableArray {
    if let queue = objc_getAssociatedObject(UIView.self, &QBToastKey.queue) as? NSMutableArray {
      return queue
    } else {
      let queue = NSMutableArray()
      objc_setAssociatedObject(UIView.self, &QBToastKey.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return queue
    }
  }

  private var activeToasts: NSMutableArray {
    if let activeToasts = objc_getAssociatedObject(UIView.self, &QBToastKey.active) as? NSMutableArray {
      return activeToasts
    } else {
      let activeToasts = NSMutableArray()
      objc_setAssociatedObject(UIView.self, &QBToastKey.active, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return activeToasts
    }
  }

  public func showToast(completionHandler: ((Bool) -> Void)? = nil) {
    do {
      guard let window = UIApplication.shared.keyWindow else { return }
      let toast = try createToastView(message: message, style: style, state: state, window: window)
      self.completionHandler = completionHandler

      if Manager.shared.inQueueEnabled, activeToasts.count > 0 {
        objc_setAssociatedObject(toast, &QBToastKey.position, NSNumber(value: position.rawValue),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(toast, &QBToastKey.duration, NSNumber(value: duration),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(toast, &QBToastKey.haptic, NSNumber(value: haptic.rawValue),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        queue.add(toast)
      } else {
        self.show(toast: toast, duration: duration, position: position, haptic: haptic, window: window)
      }
    } catch QBToastError.messageIsNil {
      print("Toast message is required!")
    } catch { }
  }

  // MARK: - Create Toast View
  private func createToastView(message: String?, style: QBToastStyle,
                               state: QBToastState, window: UIWindow) throws -> UIView {
    guard message != nil else { throw QBToastError.messageIsNil }

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

      let maxSize = CGSize(width: window.bounds.size.width  * style.maxWidthPercentage,
                           height: window.bounds.size.height * style.maxHeightPercentage)
      let messageSize = messageLabel?.sizeThatFits(maxSize)
      if let messageSize = messageSize {
        let actualWidth  = min(messageSize.width, maxSize.width)
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
    wrapView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin,
                                 .flexibleBottomMargin, .flexibleLeftMargin]
    wrapView.frame = CGRect(x: 0.0, y: 0.0,
                            width: messageRect.size.width   + (style.toastPadding * 2),
                            height: messageRect.size.height + (style.toastPadding * 2))

    wrapView.backgroundColor = toastBackgroundColor(state)
    wrapView.layer.cornerRadius = style.cornerRadius
    if #available(iOS 13, *) {
      wrapView.layer.cornerCurve = .continuous
    }

    if style.shadowEnabled {
      wrapView.dropShadow(color: style.shadowColor, offset: style.shadowOffset,
                          opacity: style.shadowOpacity, radius: style.shadowRadius)
    }

    if let messageLabel = messageLabel {
      messageLabel.frame = messageRect
      wrapView.addSubview(messageLabel)
    }

    return wrapView
  }

  // MARK: - Show Toast
  private func show(toast: UIView, duration: TimeInterval,
                    position: QBToastPosition, haptic: QBToastHaptic, window: UIWindow) {
    let endpoint = position.centerPoint(forToastView: toast, inSuperView: window)
    toast.alpha = 0
    toast.center = endpoint
    toast.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)

    if Manager.shared.tapToDismissEnabled {
      let toastRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
      toast.addGestureRecognizer(toastRecognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }
    toast.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))

    activeToasts.add(toast)
    window.addSubview(toast)
    haptic.impact()

    UIView.animate(withDuration: 0.086, delay: 0.0, options: .curveEaseIn) {
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

  @objc func panGesture(_ sender: UIPanGestureRecognizer) {
    guard let toast = sender.view else { return }
    switch sender.state {
    case .began:
      self.initialCenter = toast.center
      self.originalPoint = toast.center
    case .changed:
      let translation = sender.translation(in: toast.superview)
      toast.center = CGPoint(x: initialCenter.x,
                             y: initialCenter.y + (translation.y / 3.0))
    case .ended,
         .cancelled:
      UIView.animate(withDuration: 0.25,
                     delay: 0.0,
                     usingSpringWithDamping: 1.0,
                     initialSpringVelocity: 0.0,
                     options: .curveLinear) {
        toast.center = self.originalPoint
      } completion: { [weak self] success in
        self?.hide(toast)
      }
    default:
      break
    }
  }

  @objc func tapToDismiss(_ recognizer: UIGestureRecognizer) {
    guard let toast = recognizer.view else { return }
    self.hide(toast, byTap: true)
  }

  @objc func toastTimer(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView, activeToasts.contains(toast) else { return }
    self.hide(toast)
  }

  // MARK: - Hide Toast
  private func hide(_ toast: UIView, byTap: Bool = false) {
    guard let window = UIApplication.shared.keyWindow else { return }
    if let timer = objc_getAssociatedObject(toast, &QBToastKey.timer) as? Timer {
      timer.invalidate()
    }

    UIView.animate(withDuration: 0.11, delay: 0.0, options: .curveEaseOut) {
      toast.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      toast.alpha = 0
    } completion: { _ in
      self.activeToasts.remove(toast)
      toast.removeFromSuperview()
      self.completionHandler?(byTap)

      if let nextToast = self.queue.firstObject as? UIView,
         let position = objc_getAssociatedObject(nextToast, &QBToastKey.position) as? NSNumber,
         let duration = objc_getAssociatedObject(nextToast, &QBToastKey.duration) as? NSNumber,
         let haptic   = objc_getAssociatedObject(nextToast, &QBToastKey.haptic)   as? NSNumber {
        if let toastPosition = QBToastPosition(rawValue: position.intValue),
           let hapticType = QBToastHaptic(rawValue: haptic.intValue) {
          self.queue.removeObject(at: 0)
          self.show(toast: nextToast, duration: duration.doubleValue, position: toastPosition, haptic: hapticType, window: window)
        }
      }
    }
  }

  private func toastBackgroundColor(_ state: QBToastState) -> UIColor {
    switch state {
    case .success:
      return UIColor.success
    case .warning:
      return UIColor.warning
    case .error:
      return UIColor.error
    case .info:
      return UIColor.info
    case .custom:
      return style.backgroundColor
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

public enum QBToastHaptic: Int {
  case success = 0
  case warning = 1
  case error   = 2
  case light   = 3
  case medium  = 4
  case none    = 5

  func impact() {
    #if os(iOS)
    let generator = UINotificationFeedbackGenerator()
    switch self {
    case .success:
      generator.notificationOccurred(.success)
    case .warning:
      generator.notificationOccurred(.warning)
    case .error:
      generator.notificationOccurred(.error)
    case .light:
      let impactGen = UIImpactFeedbackGenerator(style: .light)
      impactGen.impactOccurred()
    case .medium:
      let impactGen = UIImpactFeedbackGenerator(style: .medium)
      impactGen.impactOccurred()
    case .none:
      break;
    }
    #endif
  }
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
    messageFont: UIFont               = .systemFont(ofSize: 14.0, weight: .regular),
    messageNumberOfLines: Int         = 0,
    messageAlignment: NSTextAlignment = .left,
    maxWidthPercentage: CGFloat       = 0.8,
    maxHeightPercentage: CGFloat      = 0.8,
    toastPadding: CGFloat             = 16.0,
    cornerRadius: CGFloat             = 4.0,
    shadowEnabled: Bool               = true,
    shadowColor: UIColor              = UIColor(hex: "#323232"),
    shadowRadius: CGFloat             = 4.0,
    shadowOpacity: Float              = 0.3,
    shadowOffset: CGSize              = CGSize.zero,
    fadeDuration: TimeInterval        = 0.4
  ) {
    self.backgroundColor      = backgroundColor
    self.messageColor         = messageColor
    self.messageFont          = messageFont
    self.messageNumberOfLines = messageNumberOfLines
    self.messageAlignment     = messageAlignment
    self.maxWidthPercentage   = max(min(maxWidthPercentage, 1.0), 0.0)
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

  /** Haptic feedback `Default .none`*/
  public var haptic: QBToastHaptic = .none

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
  fileprivate func centerPoint(forToastView toast: UIView, inSuperView view: UIView) -> CGPoint {
    let topPadding    = Manager.shared.style.toastPadding + view.safeArea.top
    let bottomPadding = Manager.shared.style.toastPadding + view.safeArea.bottom
    switch self {
    case .top:
      return CGPoint(x: view.bounds.size.width / 2, y: (toast.frame.size.height / 2) + topPadding)
    case .center:
      return CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
    case .bottom:
      return CGPoint(x: view.bounds.size.width / 2,
                     y: view.bounds.size.height - (toast.frame.size.height / 2) - bottomPadding)
    }
  }
}

// MARK: - Extension
private extension UIView {
  /** Get safeAreaInsets*/
  var safeArea: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
  }

  func dropShadow(color: UIColor, offset: CGSize, opacity: Float, radius: CGFloat) {
    self.clipsToBounds       = true
    self.layer.shadowColor   = color.cgColor
    self.layer.shadowOffset  = offset
    self.layer.shadowOpacity = opacity
    self.layer.shadowRadius  = radius
    self.layer.masksToBounds = false
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
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    if Scanner(string: hexString.replacingOccurrences(of: "#", with: "")).scanHexInt32(&color) {
      red = CGFloat((color & 0xFF0000) >> 16) / 255.0
      green = CGFloat((color & 0x00FF00) >>  8) / 255.0
      blue = CGFloat( color & 0x0000FF) / 255.0
    }
    self.init(red: red, green: green, blue: blue, alpha: 1.0)
  }
}
