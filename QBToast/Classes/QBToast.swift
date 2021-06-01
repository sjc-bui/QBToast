//
//  QBToast.swift
//  Pods-QBToast_Example
//
//  Created by quan bui on 2021/06/01.
//

import UIKit

extension UIView {

  public func showToast() {
    
  }

  private func createToastView() -> UIView {
    let wrapView = UIView()
    return wrapView
  }

  private func show() {
    
  }

  private func hide() {
    
  }
}

public struct QBToastStyle {

  let backgroundColor: UIColor

  let titleColor: UIColor

  let titleFont: UIFont

  let titleAlignment: NSTextAlignment

  let titleNumberOfLines: Int

  let messageColor: UIColor

  let messageFont: UIFont

  let messageAlignment: NSTextAlignment

  let messageNumberOfLines: Int

  let maxWidthPercentage: CGFloat

  let maxHeightPercentage: CGFloat

  let cornerRadius: CGFloat
  
  let fadeDuration: CGFloat

  public init(
    backgroundColor: UIColor = .black.withAlphaComponent(0.8),
    titleColor: UIColor = .white,
    titleFont: UIFont = .boldSystemFont(ofSize: 16.0),
    titleAlignment: NSTextAlignment = .left,
    titleNumberOfLines: Int = 0,
    messageColor: UIColor = .white,
    messageFont: UIFont = .systemFont(ofSize: 16.0),
    messageAlignment: NSTextAlignment = .left,
    messageNumberOfLines: Int = 0,
    maxWidthPercentage: CGFloat = 0.8,
    maxHeightPercentage: CGFloat = 0.8,
    cornerRadius: CGFloat = 4.0,
    fadeDuration: CGFloat = 0.2
  ) {
    self.backgroundColor = backgroundColor
    self.titleColor = titleColor
    self.titleFont = titleFont
    self.titleAlignment = titleAlignment
    self.titleNumberOfLines = titleNumberOfLines
    self.messageColor = messageColor
    self.messageFont = messageFont
    self.messageAlignment = messageAlignment
    self.messageNumberOfLines = messageNumberOfLines
    self.maxWidthPercentage = maxWidthPercentage
    self.maxHeightPercentage = maxHeightPercentage
    self.cornerRadius = cornerRadius
    self.fadeDuration = fadeDuration
  }
}

public class QBToastManager {

  public static let shared = QBToastManager()

  public var style = QBToastStyle()

  public var duration: TimeInterval = 3.0

  public var position: QBToastPosition = .bottom

  public var tapToDismissEnabled: Bool = true

  public var inQueueEnabled: Bool = false
}

public enum QBToastPosition {
  case top
  case center
  case bottom

  fileprivate func centerPoint() -> CGPoint {
    return CGPoint(x: 0, y: 0)
  }
}

fileprivate extension UIView {
  var safeArea: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return self.safeAreaInsets
    } else {
      return .zero
    }
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
