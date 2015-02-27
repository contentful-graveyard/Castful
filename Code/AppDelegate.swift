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
    var selectedAccessToken = ""
    var selectedSpace = ""

    var board: UIStoryboard?
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let loginViewController = CMALoginViewController()
        loginViewController.oauthClientId = "<TOKEN>"

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "spaceSelected:", name: CDASpaceChangedNotification, object: nil)

        board = UIStoryboard(name: "Storyboard", bundle: nil)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = UINavigationController(rootViewController: loginViewController)
        window?.makeKeyAndVisible()

        return true
    }

    func spaceSelected(note: NSNotification) {
        selectedAccessToken = note.userInfo?[CDAAccessTokenKey] as String
        selectedSpace = note.userInfo?[CDASpaceIdentifierKey] as String

        let nav = window?.rootViewController as UINavigationController
        let recordVC = board?.instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.RecordViewController.rawValue) as UIViewController
        nav.pushViewController(recordVC, animated: true)
    }
}
