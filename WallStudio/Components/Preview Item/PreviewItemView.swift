//
//  PreviewItemView.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/4/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit

class PreviewItemView: UIView {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @IBInspectable var image: UIImage? {
        didSet {
            itemImageView.image = image
        }
    }

    @IBInspectable var title: String? {
        didSet {
            itemLabel.text = title
        }
    }

    func setup() {
        guard let view = loadViewFromNib() else {
            return
        }
        self.backgroundColor = .clear
        view.backgroundColor = .clear
        view.frame = bounds

        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                 UIViewAutoresizing.flexibleHeight]

        addSubview(view)
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view
    }
}
