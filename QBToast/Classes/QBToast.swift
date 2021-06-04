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

public class QBToast: UIViewController {
  let message: String?
  let style: QBToastStyle!
  let position: QBToastPosition
  let duration: TimeInterval
  let state: QBToastState

  public typealias QBToastCompletion = ((Bool) -> Void)?
  var completionHandler: QBToastCompletion = nil

  private struct QBToastKey {
    static var timer = "timer"
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

  public func showToast(completionHandler: QBToastCompletion = nil) {
    do {
      guard let window = UIApplication.shared.keyWindow else { return }
      let toast = try createToastView(message: message, style: style, state: state, window: window)
      self.completionHandler = completionHandler
      self.show(toast: toast, duration: duration, position: position, window: window)
    } catch QBToastError.messageIsNil {
      print("Toast message is required!")
    } catch { }
  }

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

    wrapView.layer.roundCorner(radius: style.cornerRadius)

    if let messageLabel = messageLabel {
      messageLabel.frame = messageRect
      wrapView.addSubview(messageLabel)
    }

    return wrapView
  }

  private func show(toast: UIView,
                    duration: TimeInterval,
                    position: QBToastPosition,
                    window: UIWindow) {
    let startpoint = position.startPoint(forToastView: toast, inSuperView: window)
    let point = position.centerPoint(forToastView: toast, inSuperView: window)

    toast.center = startpoint
    toast.alpha = 0

    if QBToastManager.shared.tapToDismissEnabled {
      let toastRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
      toast.addGestureRecognizer(toastRecognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }

    window.addSubview(toast)
    UIView.animate(withDuration: QBToastManager.shared.style.fadeDuration,
                   delay: 0.0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.65,
                   options: .curveEaseIn) {
      toast.alpha = 1
      toast.center = point
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
    guard let toast = timer.userInfo as? UIView else { return }
    self.hide(toast)
  }

  /** Hide Toast view*/
  private func hide(_ toast: UIView, byTap: Bool = false) {
    guard let window = UIApplication.shared.keyWindow else { return }
    if let timer = objc_getAssociatedObject(toast, &QBToastKey.timer) as? Timer {
      timer.invalidate()
    }
    var currentPoint = toast.center
    let centerYPoint = window.bounds.size.height / 2

    if currentPoint.y > centerYPoint {
      currentPoint.y += (toast.frame.size.height * 2)
    } else {
      currentPoint.y -= (toast.frame.size.height * 2)
    }

    UIView.animate(withDuration: QBToastManager.shared.style.fadeDuration,
                   delay: 0.0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.65,
                   options: .curveEaseOut) {
      toast.alpha = 0
      toast.center = currentPoint
    } completion: { _ in
      toast.removeFromSuperview()
      self.completionHandler?(byTap)
    }
  }
}

private enum QBToastError: Error {
  case messageIsNil
}

public enum QBToastState {
  case success
  case warning
  case error
  case info
  case custom
}

public struct QBToastStyle {

  /** Toast view background color. Default `.black(0.8)`*/
  let backgroundColor: UIColor

  /** Toast message color*/
  let messageColor: UIColor

  /** Toast message font*/
  let messageFont: UIFont

  /** Toast message number of lines*/
  let messageNumberOfLines: Int

  /** Toast message alignment*/
  let messageAlignment: NSTextAlignment

  let maxWidthPercentage: CGFloat

  let maxHeightPercentage: CGFloat

  /** Toast message padding*/
  let toastPadding: CGFloat

  /** Corner radius of Toast View*/
  let cornerRadius: CGFloat

  /** Toast appear, disappear duration*/
  let fadeDuration: TimeInterval

  public init(
    backgroundColor: UIColor = .black,
    messageColor: UIColor = .white,
    messageFont: UIFont = .systemFont(ofSize: 14.0, weight: .medium),
    messageNumberOfLines: Int = 0,
    messageAlignment: NSTextAlignment = .left,
    maxWidthPercentage: CGFloat = 0.8,
    maxHeightPercentage: CGFloat = 0.8,
    toastPadding: CGFloat = 12.0,
    cornerRadius: CGFloat = 2.0,
    fadeDuration: TimeInterval = 0.4
  ) {
    self.backgroundColor      = backgroundColor.withAlphaComponent(0.8)
    self.messageColor         = messageColor
    self.messageFont          = messageFont
    self.messageNumberOfLines = messageNumberOfLines
    self.messageAlignment     = messageAlignment
    self.maxWidthPercentage   = maxWidthPercentage
    self.maxHeightPercentage  = maxHeightPercentage
    self.toastPadding         = toastPadding
    self.cornerRadius         = cornerRadius
    self.fadeDuration         = fadeDuration
  }
}

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

  /** Display Toast in queue `Not emplementing...`*/
  public var inQueueEnabled: Bool = false
}

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

  /** `Toast` start animation from start point*/
  fileprivate func startPoint(forToastView toast: UIView,
                              inSuperView superview: UIView) -> CGPoint {
    switch self {
      case .top:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: -toast.frame.size.height)
      case .center:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: superview.bounds.size.height / 2 - toast.frame.size.height)
      case .bottom:
        return CGPoint(x: superview.bounds.size.width / 2,
                       y: superview.bounds.size.height + toast.frame.size.height)
    }
  }
}

private extension UIView {
  /**
   Get safeAreaInsets
   */
  var safeArea: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
  }
}

extension CALayer {
  /**
   Round smooth corner for UIView
   */
  func roundCorner(radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds,
                            cornerRadius: radius)
    let layer = CAShapeLayer()
    layer.path = path.cgPath
    self.mask = layer
  }
}

extension UIColor {
  static let success = UIColor(hex: "#5cb85c")
  static let warning = UIColor(hex: "#f0ad4e")
  static let error   = UIColor(hex: "#d9534f")
  static let info    = UIColor(hex: "#5bc0de")

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
