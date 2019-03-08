//
//  WallpaperDetailViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/3/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Parse

class WallpaperDetailViewController: UIViewController {

    private enum Constants {
        static let cellNibName = "WallpaperDetailCollectionViewCell"
        static let cellReuseIdentifier = "WallpaperDetailCollectionViewCell"
    }

    // Outlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var detailImageImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var likesStackView: UIStackView!
    @IBOutlet private weak var likesLabel: UILabel!

    var viewModel: WallpaperDetailViewModelType!

    private var wallpaperService: WallpaperServiceType = WallpaperService()
    private var viewModelDisposable: Disposable?

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

    private var isInitialScrollDone: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !isInitialScrollDone else {
            return
        }

        let indexPathOfSelectedItem = IndexPath(row: viewModel.selectedWallpaperIndex, section: 0)
        collectionView.scrollToItem(at: indexPathOfSelectedItem, at: .centeredHorizontally, animated: true)
        isInitialScrollDone = true
    }

    private func bindWithViewModel() {
        viewModelDisposable = viewModel.selectedWallpaperImage.producer.startWithValues { [weak self] image in
            self?.detailImageImageView.image = image
        }
        timeLabel.text = viewModel.currentTime
        dateLabel.text = viewModel.currentDate
        updateLikesLabel()
    }

    @IBAction func likeButtonPressed(_ sender: Any) {
        guard let currentUserId = PFUser.current()?.objectId else {
            showLoginAlert(with: "Please Login to Like this Wallpaper. Want to Login now?")
            return
        }

        let wallpaper = viewModel.selectedWallpaper

        let likedBy = wallpaperService.usersWhoLiked(wallpaper: wallpaper)

        if likedBy.contains(currentUserId) {
            wallpaperService.dislike(wallpaper: wallpaper, with: currentUserId) { [weak self] (success, error) in
                if error == nil {
                    self?.updateLikesLabel()
                    self?.showSimpleAlert(with: "You've unliked this wallpaper")
                }
            }
        } else {
            wallpaperService.like(wallpaper: wallpaper, with: currentUserId) { [weak self] (success, error) in
                if error == nil {
                    self?.updateLikesLabel()
                    self?.showSimpleAlert(with: "You've liked this wallpaper. ")
                }
            }
        }
    }

    @IBAction func downloadButtonPressed(_ sender: Any) {
        let selectedWallpaper = viewModel.selectedWallpaper

        wallpaperService.getImage(for: selectedWallpaper) { [weak self] (image, error) in
            guard error == nil,
                let image = image else {
                    self?.showSimpleAlert(with: "Ooops... Something went wrong")
                    return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self?.showSimpleAlert(with: "Image downloaded")
        }
    }

    @IBAction func previewButtonPressed(_ sender: Any) {
        guard let selectedImageIndex = collectionView.indexPathsForSelectedItems?.first else {
            return
        }

        let selectedWallpaper = viewModel.wallpapers[selectedImageIndex.row]
        wallpaperService.getImage(for: selectedWallpaper) { [weak self] (image, error) in
            guard error == nil,
                let image = image else {
                    return
            }
            let previewViewController = WallpaperPreviewViewController(image: image)
            previewViewController.modalPresentationStyle = .overCurrentContext
            self?.present(previewViewController, animated: true, completion: nil)
        }
    }

    @IBAction func moreButtonPressed(_ sender: Any) {
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        viewModelDisposable?.dispose()
    }

    private func updateLikesLabel() {
        if self.viewModel.numberOfLikes == 1 {
            self.likesLabel.text = "\(self.viewModel.numberOfLikes) like"
        } else {
            self.likesLabel.text = "\(self.viewModel.numberOfLikes) likes"
        }
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

        wallpaperService.getImage(for: wallpaperObject) { (image, error) in
            guard error == nil else {
                    return
            }
            cell.configure(with: image)
        }
        return cell
    }

}

extension WallpaperDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedWallpaper = viewModel.wallpapers[indexPath.row]
        wallpaperService.getImage(for: selectedWallpaper) { [weak self] (image, error) in
            guard error == nil,
                let image = image else {
                    return
            }
            self?.detailImageImageView.image = image
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension WallpaperDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: collectionView.frame.height)
    }
}
