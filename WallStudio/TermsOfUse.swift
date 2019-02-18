//
//  TermsOfUse.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit

class TermsOfUse: UIViewController {

    @IBOutlet private var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "terms", withExtension: "html")
        webView.loadRequest(URLRequest(url: url!))
    }

    // Dismiss Button
    @IBAction private func dismissButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
