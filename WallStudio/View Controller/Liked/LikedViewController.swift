//
//  LikedViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/2/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit
import Parse

class LikedViewController: UIViewController {

    private enum Constants {
        static let cellNibName = "GridCell"
        static let cellReuseIdentifier = "GridCell"
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    private var wallsArray = [PFObject]()
    private var selectedWallpaperIndex = 0

    private var wallpaperService: WallpaperServiceType = WallpaperService()

    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: Constants.cellNibName, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)

        queryWallpapers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = false

        let backButton = UIBarButtonItem(title: "BACK", style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton

        let sortByButton = UIBarButtonItem(title: "SORT BY", style: .plain, target: self, action: #selector(sortByButtonPressed))
        sortByButton.tintColor = .white
        navigationItem.rightBarButtonItem = sortByButton
    }

    // Show Wallpapers
    func queryWallpapers() {
        showHUD(with: "Loading...")

        let query = PFQuery(className: WALLPAPERS_CLASS_NAME)
        query.whereKey(WALLPAPERS_FAVORITED_BY, contains: PFUser.current()!.objectId!)
        query.whereKey(WALLPAPERS_IS_PENDING, equalTo: false)
        query.order(byDescending: "createdAt")

        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let strongSelf = self,
                let objects = objects,
                error == nil else {
                    self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                    self?.hideHUD()
                    return
            }
            strongSelf.wallsArray = objects
            strongSelf.hideHUD()
            strongSelf.collectionView.reloadData()
        }
    }

    func queryWallpapersByLikes() {
        showHUD(with: "Loading...")

        let query = PFQuery(className: WALLPAPERS_CLASS_NAME)
        query.whereKey(WALLPAPERS_FAVORITED_BY, contains: PFUser.current()!.objectId!)
        query.whereKey(WALLPAPERS_IS_PENDING, equalTo: false)
        query.order(byDescending: WALLPAPERS_LIKES)

        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let strongSelf = self,
                let objects = objects,
                error == nil else {
                    self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                    self?.hideHUD()
                    return
            }
            strongSelf.wallsArray = objects
            strongSelf.hideHUD()
            strongSelf.collectionView.reloadData()
        }
    }

    // Back Button
    @objc private func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

    // Sort By Button
    @objc private func sortByButtonPressed() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Sort Wallpapers by:",
                                      preferredStyle: .alert)


        let byLikes = UIAlertAction(title: "More Liked", style: .default, handler: { (action) -> Void in
            self.queryWallpapersByLikes()
        })


        let byLatest = UIAlertAction(title: "Latest Added", style: .default, handler: { (action) -> Void in
            self.queryWallpapers()
        })

        // Cancel Button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(byLikes)
        alert.addAction(byLatest)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource

extension LikedViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as? GridCell else {
            return UICollectionViewCell()
        }

        let wallpaperObject = wallsArray[indexPath.row]

        wallpaperService.getImage(for: wallpaperObject) { (image, error) in
            guard error == nil else {
                    return
            }
            cell.configure(with: image)
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension LikedViewController: UICollectionViewDelegate {

    // Show Image Preview
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaperDetailViewModel = WallpaperDetailViewModel(wallpapers: wallsArray, selectedWallpaperIndex: indexPath.row)
        let wallpaperDetailViewController = WallpaperDetailViewController(viewModel: wallpaperDetailViewModel)
        wallpaperDetailViewController.modalPresentationStyle = .overCurrentContext
        present(wallpaperDetailViewController, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension LikedViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3, height: view.frame.size.width / 2)
    }
}
