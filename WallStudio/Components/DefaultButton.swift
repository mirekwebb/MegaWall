//
//  DefaultButton.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/26/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit

class DefaultButton: UIButton {

    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }
        set {
            self.layer.cornerRadius = CGFloat(newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    override func prepareForInterfaceBuilder() {
        sharedInit()
    }

    func sharedInit() {
        self.contentHorizontalAlignment = .left
        self.contentVerticalAlignment = .center

        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        self.titleLabel?.textAlignment = .center
    }
}
