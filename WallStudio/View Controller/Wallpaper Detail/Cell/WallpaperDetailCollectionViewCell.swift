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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with image: UIImage?) {
        guard let image = image else {
            return
        }
        wallpaperImageView.image = image
    }

}
