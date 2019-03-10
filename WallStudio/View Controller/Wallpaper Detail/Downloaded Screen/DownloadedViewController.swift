//
//  DownloadedViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/8/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class DownloadedViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        messageLabel.text = "Wallpaper downloaded in Photos"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
