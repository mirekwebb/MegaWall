//
//  WallpaperPreviewViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/4/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class WallpaperPreviewViewController: UIViewController {

    @IBOutlet private weak var wallpaperImageView: UIImageView!

    private var previewImage: UIImage!

    @IBOutlet weak var topItemsStackView: UIStackView!
    convenience init(image: UIImage) {
        self.init()
        previewImage = image
    }

    private init() {
        let bundle = Bundle(for: WallpaperPreviewViewController.self)
        super.init(nibName: String(describing: WallpaperPreviewViewController.self), bundle: bundle)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tapGesture)

        wallpaperImageView.image = previewImage
    }

    @objc private func dismissController() {
        dismiss(animated: true, completion: nil)
    }
}
