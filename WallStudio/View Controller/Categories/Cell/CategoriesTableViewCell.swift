//
//  CategoriesTableViewCell.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/27/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet private weak var categoriePoster: UIImageView!
    @IBOutlet private weak var categorieTitleLabel: UILabel!

    var viewModel: CategoriesTableViewCellType?

    override func awakeFromNib() {
        super.awakeFromNib()
        categoriePoster.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.categoriePoster.image = nil
        self.categorieTitleLabel.text = nil
    }

    func configure(with model: CategoriesTableViewCellType) {
        self.viewModel = model

        self.categoriePoster.image = model.posterImage
        self.categorieTitleLabel.text = model.title
    }

    func update(image: UIImage?) {
        guard let image = image else {
            return
        }
        self.categoriePoster.image = image
    }
}
