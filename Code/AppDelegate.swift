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
import IAmUpload
import MMProgressHUD
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RecordViewControllerDelegate {
    var selectedAccessToken = ""
    var selectedSpace = ""

    var board: UIStoryboard?
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let loginViewController = CMALoginViewController()
        loginViewController.oauthClientId = "<TOKEN>"
        loginViewController.permissionScope = .Manage

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
        let recordVC = board?.instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.RecordViewController.rawValue) as RecordViewController
        recordVC.delegate = self
        nav.pushViewController(recordVC, animated: true)
    }

    func temporaryFileUpload(fileURL: NSURL, callback: (NSURL) -> Void) {
        let data = NSData(contentsOfURL: fileURL)

        let s3uploader = BBUS3Uploader(bucket: "bucket", key: "key", secret: "secret")
        s3uploader.path = "app-upload"

        s3uploader.uploadFileWithData(data, fileExtension: "m4a", completionHandler: { (url, error) -> Void in
            if let url = url {
                callback(url)
            } else {
                NSLog("Temporary file upload error: %@", error)
            }
        }, progressHandler: nil)
    }

    func uploadToContentful(url: NSURL) {
        let title = String(format: "Podcast on recorded on %@", NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))

        let configuration = CDAConfiguration.defaultConfiguration()
        configuration.rateLimiting = true
        configuration.userAgent = "Castful/1.0"

        let token = CMALoginViewController.contentfulOAuthToken()
        let managementClient = CMAClient(accessToken: token, configuration: configuration)

        let failure = { (response: CDAResponse!, error: NSError!) -> Void in
            NSLog("%@", error)
            MMProgressHUD.dismiss()
        }

        managementClient.fetchSpaceWithIdentifier(selectedSpace, success: { (_, space) in
            if let space = space {
                let locale = space.defaultLocale

                space.createAssetWithTitle([locale: title],
                    description: nil,
                    fileToUpload: [ locale: url.absoluteString! ],
                    success: { (_, asset) in
                        if let asset = asset {
                            asset.processWithSuccess({ () in
                                MMProgressHUD.dismiss()
                            }, failure: failure)
                        }
                }, failure: failure)
            }
        }, failure: failure)
    }

    // MARK: RecordViewControllerDelegate

    func recordViewController(vc: RecordViewController, didFinishRecordingAtPath: NSURL) {
        MMProgressHUD.showWithTitle("Uploading Podcast...")

        temporaryFileUpload(didFinishRecordingAtPath, callback: { (url) -> Void in
            self.uploadToContentful(url)
        })
    }
}
