//
//  CategoriesTableCellViewModel.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/27/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit

protocol CategoriesTableViewCellType {
    var posterImage: UIImage? { get }
    var title: String? { get }
}

class CategoriesTableCellViewModel: CategoriesTableViewCellType  {

    var posterImage: UIImage?
    var title: String?

    init(posterImage: UIImage?, title: String?) {
        self.posterImage = posterImage
        self.title = title
    }
}
