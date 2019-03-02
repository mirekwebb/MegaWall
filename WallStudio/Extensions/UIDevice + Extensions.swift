//
//  UIDevice + Extensions.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/2/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {

    class var isSE: Bool {
        return UIScreen.main.nativeBounds.height <= 1136
    }

    class var isIPAD: Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }

}
