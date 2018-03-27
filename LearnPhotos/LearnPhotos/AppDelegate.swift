//
//  AppDelegate.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white

        let masterViewController = MasterViewController(style: .plain)
        let navigationController = UINavigationController(rootViewController: masterViewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }

}

