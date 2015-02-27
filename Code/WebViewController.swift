//
//  WebViewController.swift
//  Castful
//
//  Created by Boris Bügling on 27/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    lazy var webView = UIWebView()

    func loadURL(url: NSURL) {
        webView.loadRequest(NSURLRequest(URL: url))
    }

    func refresh() {
        if let URL = webView.request?.URL {
            loadURL(URL)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")

        view.addSubview(webView)
        webView.frame = view.bounds
    }
}
