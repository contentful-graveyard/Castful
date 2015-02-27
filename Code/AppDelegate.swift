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

        UIView.appearance().tintColor = UIColor(red: 0.984, green: 0.71, blue: 0.365, alpha: 1.0)

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
        recordVC.title = "Recording"
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
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                                    asset.publishWithSuccess({ () -> Void in
                                        MMProgressHUD.dismiss()

                                        let web = WebViewController()
                                        web.title = "Dat Website"
                                        web.loadURL(NSURL(string: "https://assets.contentful.com/crvcnjrd7aj2/25yupHorJGkey6cuE82EEO/966df7fb945414b77493d81dcc6fe1d2/index.html")!)

                                        let nav = self.window?.rootViewController as UINavigationController
                                        nav.pushViewController(web, animated: true)
                                    }, failure: failure)
                                    return
                                })
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
