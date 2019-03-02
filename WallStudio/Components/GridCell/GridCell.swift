//
//  GridCell.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/2/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with image: UIImage?) {
        guard let image = image else {
            return
        }
        self.imageView.image = image
    }

}
