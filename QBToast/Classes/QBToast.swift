//
//  QBToast.swift
//  Pods-QBToast_Example
//
//  Created by quan bui on 2021/06/01.
//

import UIKit

extension UIView {

  public func showToast(message: String?,
                        style: QBToastStyle = QBToastManager.shared.style,
                        position: QBToastPosition = QBToastManager.shared.position,
                        duration: TimeInterval = QBToastManager.shared.duration,
                        state: QBToastState = QBToastManager.shared.state) {
    do {
      let toast = try createToastView(message: message, style: style, state: state)
      self.show(toast: toast, duration: duration, position: position)
    } catch QBToastError.messageIsNil {
      print("Toast message is required!")
    } catch { }
  }

  private func createToastView(message: String?, style: QBToastStyle, state: QBToastState) throws -> UIView {
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

      let maxSize = CGSize(width : self.bounds.size.width  * style.maxWidthPercentage,
                           height: self.bounds.size.height * style.maxHeightPercentage)
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

  private func show(toast: UIView, duration: TimeInterval, position: QBToastPosition) {
    let startpoint = position.startPoint(forToastView: toast, inSuperView: self)
    let point = position.centerPoint(forToastView: toast, inSuperView: self)

    toast.center = startpoint
    toast.alpha = 0

    if QBToastManager.shared.tapToDismissEnabled {
      let toastRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
      toast.addGestureRecognizer(toastRecognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }

    self.addSubview(toast)
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
    }
  }

  @objc func tapToDismiss(_ recognizer: UIGestureRecognizer) {
    guard let toast = recognizer.view else { return }
    self.hide(toast)
  }

  @objc func toastTimer(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView else { return }
    self.hide(toast)
  }

  private func hide(_ toast: UIView) {
    var currentPoint = toast.center
    let centerYPoint = self.bounds.size.height / 2

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

  let messageColor: UIColor

  let messageFont: UIFont

  let messageNumberOfLines: Int

  let messageAlignment: NSTextAlignment

  let maxWidthPercentage: CGFloat

  let maxHeightPercentage: CGFloat

  let toastPadding: CGFloat

  let cornerRadius: CGFloat

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
    cornerRadius: CGFloat = 4.0,
    fadeDuration: TimeInterval = 0.4
  ) {
    self.backgroundColor      = backgroundColor.withAlphaComponent(0.9)
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

public enum QBToastPosition: CaseIterable {
  case top
  case center
  case bottom

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
  var safeArea: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
  }
}

extension CALayer {
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
