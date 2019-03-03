//
//  WallpaperDetailViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/3/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit
import Parse

class WallpaperDetailViewController: UIViewController {

    private enum Constants {
        static let cellNibName = "WallpaperDetailCollectionViewCell"
        static let cellReuseIdentifier = "WallpaperDetailCollectionViewCell"
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet private weak var detailImageImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    var viewModel: WallpaperDetailViewModelType!

    convenience init(viewModel: WallpaperDetailViewModelType) {
        self.init()
        self.viewModel = viewModel
    }

    private init() {
        let bundle = Bundle(for: WallpaperDetailViewController.self)
        super.init(nibName: String(describing: WallpaperDetailViewController.self), bundle: bundle)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: Constants.cellNibName, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)

        bindWithViewModel()
    }

    private func bindWithViewModel() {
        //TODO: Make disposable
        viewModel.selectedWallpaperImage.producer.startWithValues { [weak self] image in
            self?.detailImageImageView.image = image
        }
        timeLabel.text = viewModel.currentTime
        dateLabel.text = viewModel.currentDate
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension WallpaperDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.wallpapers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! WallpaperDetailCollectionViewCell

        let wallpaperObject = viewModel.wallpapers[indexPath.row]

        let imageFile = wallpaperObject[WALLPAPERS_IMAGE] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data else {
                    return
            }
            cell.configure(with: UIImage(data: imageData))
        })
        return cell
    }

}

extension WallpaperDetailViewController: UICollectionViewDelegate {

}

// MARK: UICollectionViewDelegateFlowLayout

extension WallpaperDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.frame.height)
    }
}
