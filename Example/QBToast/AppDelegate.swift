//
//  AppDelegate.swift
//  QBToast
//
//  Created by sjc-bui on 06/01/2021.
//  Copyright (c) 2021 sjc-bui. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    UserDefaults.standard.register(defaults: [
      "position": 0,
      "message": "サンプルメッセージです",
      "cornerRadius": 4.0,
      "duration": 1.0
    ])

    window = UIWindow(frame: UIScreen.main.bounds)
    var navigationController: UINavigationController!
    if #available(iOS 13.0, *) {
      navigationController = UINavigationController(rootViewController: ViewController(style: .insetGrouped))
    } else {
      navigationController = UINavigationController(rootViewController: ViewController(style: .grouped))
    }
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    return true
  }
}
