//
//  WallpaperDetailCollectionViewCell.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/3/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class WallpaperDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var wallpaperImageView: UIImageView!
    @IBOutlet private weak var selectedImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectedImageView.isHidden = false
            } else {
                selectedImageView.isHidden = true
            }
        }
    }

    func configure(with image: UIImage?) {
        guard let image = image else {
            return
        }
        wallpaperImageView.image = image
    }

}
