//
//  AppDelegate.swift
//  mashtag
//
//  Created by Austin Chan on 7/8/15.
//  Copyright (c) 2015 Fiftyawoe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigation = UINavigationController(rootViewController: HomeViewController(nibName: "HomeViewController", bundle: nil))
        navigation.navigationBar.hidden = true
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

