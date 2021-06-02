//
//  ViewController.swift
//  QBToast
//
//  Created by sjc-bui on 06/01/2021.
//  Copyright (c) 2021 sjc-bui. All rights reserved.
//

import UIKit
import QBToast

class ViewController: UIViewController {
  var btn: UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.title = "QBToast iOS"

    btn = UIButton()
    btn?.setTitle("Click", for: .normal)
    btn?.titleLabel?.textColor = .white
    btn?.backgroundColor = .systemBlue
    btn?.layer.cornerRadius = 6.0
    btn?.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(btn!)
    btn?.widthAnchor.constraint(equalToConstant: 120).isActive = true
    btn?.heightAnchor.constraint(equalToConstant: 46).isActive = true
    btn?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    btn?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height - (self.view.bounds.height / 4)).isActive = true
    btn?.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
  }

  var i = 0
  @objc func btnClick() {
    i += 1
    if i > 3 {
      i = 1
    }
    makeToast(i)
    print(i)
  }

  func makeToast(_ rand: Int) {
    let style = QBToastStyle(cornerRadius: 12.0)
    switch rand {
      case 1:
        self.navigationController!.view.showToast(message: "Swiftは、macOS、iOS、watchOS、tvOSのためのパワフルかつ使いやすいプログラミング言語です", style: style, duration: 5.0)
        break
      case 2:
        self.navigationController!.view.showToast(message: "Objective-C", style: style, position: .top, duration: 5.0)
        break
      case 3:
        self.navigationController!.view.showToast(message: "Apple Silicon", style: style, position: .center, duration: 5.0)
        break
      default:
        break
    }
  }
}
