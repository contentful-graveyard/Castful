//
//  AppDelegate.swift
//  Castful
//
//  Created by Boris Bügling on 27/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import ContentfulDeliveryAPI
import ContentfulManagementAPI
import ContentfulLogin
import Keys
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let loginViewController = CMALoginViewController()
        loginViewController.oauthClientId = "<TOKEN>"

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = UINavigationController(rootViewController: loginViewController)
        window?.makeKeyAndVisible()

        return true
    }
}
