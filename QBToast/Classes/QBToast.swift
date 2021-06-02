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
                        duration: TimeInterval = QBToastManager.shared.duration) {
    do {
      let toast = try createToastView(message: message, style: style)
      self.show(toast: toast, duration: duration, position: position)
    } catch QBToastError.missingParameters {
      print("Missing parameters")
    } catch { }
  }

  private func createToastView(message: String?, style: QBToastStyle) throws -> UIView {

    guard message != nil else {
      throw QBToastError.missingParameters
    }

    var messageLabel: UILabel?
    if let message = message {
      messageLabel                  = UILabel()
      messageLabel?.text            = message
      messageLabel?.textColor       = style.messageColor
      messageLabel?.font            = style.messageFont
      messageLabel?.textAlignment   = NSTextAlignment.center
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
      messageRect.origin.x    = style.horizontalPadding
      messageRect.origin.y    = style.verticalPadding
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
                            width: messageRect.size.width + (style.horizontalPadding * 2),
                            height: messageRect.size.height + (style.verticalPadding * 2))
    wrapView.backgroundColor = style.backgroundColor
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

  @objc func toastTimer(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView else { return }
    hide(toast)
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
  case missingParameters
}

public struct QBToastStyle {
  
  /** Toast view background color. Default `.black(0.8)`*/
  let backgroundColor: UIColor

  let messageColor: UIColor

  let messageFont: UIFont

  let messageNumberOfLines: Int

  let maxWidthPercentage: CGFloat

  let maxHeightPercentage: CGFloat

  let horizontalPadding: CGFloat

  let verticalPadding: CGFloat

  let cornerRadius: CGFloat

  let fadeDuration: TimeInterval

  public init(
    backgroundColor: UIColor = .black,
    messageColor: UIColor = .white,
    messageFont: UIFont = .systemFont(ofSize: 16.0),
    messageNumberOfLines: Int = 0,
    maxWidthPercentage: CGFloat = 0.8,
    maxHeightPercentage: CGFloat = 0.8,
    horizontalPadding: CGFloat = 12.0,
    verticalPadding: CGFloat = 12.0,
    cornerRadius: CGFloat = 4.0,
    fadeDuration: TimeInterval = 0.4
  ) {
    self.backgroundColor      = backgroundColor.withAlphaComponent(0.7)
    self.messageColor         = messageColor
    self.messageFont          = messageFont
    self.messageNumberOfLines = messageNumberOfLines
    self.maxWidthPercentage   = maxWidthPercentage
    self.maxHeightPercentage  = maxHeightPercentage
    self.horizontalPadding    = horizontalPadding
    self.verticalPadding      = verticalPadding
    self.cornerRadius         = cornerRadius
    self.fadeDuration         = fadeDuration
  }
}

public class QBToastManager {

  public static let shared = QBToastManager()

  public var style = QBToastStyle()

  public var duration: TimeInterval = 0.3

  public var position: QBToastPosition = .bottom

  public var tapToDismissEnabled: Bool = true

  public var inQueueEnabled: Bool = false
}

public enum QBToastPosition {
  case top
  case center
  case bottom

  fileprivate func centerPoint(forToastView    toast: UIView,
                               inSuperView superview: UIView) -> CGPoint {

    let topPadding = QBToastManager.shared.style.verticalPadding + superview.safeArea.top
    let bottomPadding = QBToastManager.shared.style.verticalPadding + superview.safeArea.bottom

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

extension UIApplication {
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
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
