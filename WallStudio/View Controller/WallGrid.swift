//
//  WallGrid.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import MessageUI
import AudioToolbox
import Parse

class WallCell: UICollectionViewCell {
    @IBOutlet var wallImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
}

class WallGrid: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet private var wallCollectionView: UICollectionView!
    @IBOutlet private var imagePreviewView: UIView!
    @IBOutlet private var imagePreviewImageView: UIImageView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private weak var likesLabel: UILabel!

    private var wallsArray = [PFObject]()
    var categoryName = String()
    private var selectedWallpaper = 0
    var isFavorites = false
    private var byLikes = false


    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if !isFavorites {
            self.title = "\(categoryName)".uppercased()
        } else {
            self.title = "My Favorites".uppercased()
        }

        // Hide Image Preview
        imagePreviewView.frame = CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height)

        // Back BarButton
        let backButton = UIButton(type: .custom)
        backButton.adjustsImageWhenHighlighted = false
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        backButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        // SortBy BarButton
        let sortByButton = UIButton(type: .custom)
        sortByButton.adjustsImageWhenHighlighted = false
        sortByButton.frame = CGRect(x: 0, y: 0, width: 58, height: 44)
        sortByButton.addTarget(self, action: #selector(sortByButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortByButton)
        sortByButton.setTitle("SORT BY", for: UIControlState.normal)
        sortByButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        sortByButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        // Get Time
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        timeLabel.text = dateFormatter.string(from: currentTime)

        // Query
        queryWallpapers()
    }

    // Show Wallpapers
    func queryWallpapers() {
        showHUD(with: "Loading...")

        let query = PFQuery(className: WALLPAPERS_CLASS_NAME)

        if !isFavorites {
            query.whereKey(WALLPAPERS_CATEGORY, equalTo: categoryName)
        } else {
            query.whereKey(WALLPAPERS_FAVORITED_BY, contains: PFUser.current()!.objectId!)
        }

        if byLikes {
            query.order(byDescending: WALLPAPERS_LIKES)
        } else {
            query.order(byDescending: "createdAt")
        }

        query.whereKey(WALLPAPERS_IS_PENDING, equalTo: false)

        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let self = self else {
                return
            }

            if error == nil {
                self.wallsArray = objects!
                self.hideHUD()
                self.wallCollectionView.reloadData()
            } else {
                self.showSimpleAlert(with: "\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }

    // Show/Hide Image Preview
    private func showImagePreviewView() {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.imagePreviewView.frame.origin.y = 0
        }, completion: { [weak self] (finished: Bool) in
            self?.navigationController?.isNavigationBarHidden = true
        })
    }

    private func hideImagePreviewView() {
        imagePreviewImageView.image = nil
        UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.imagePreviewView.frame.origin.y = self.view.frame.size.height
        }, completion: { [weak self] (finished: Bool) in
            self?.navigationController?.isNavigationBarHidden = false
        })
    }

    // Close Preview
    @IBAction private func closePreviewButtonPressed(_ sender: Any) {
        hideImagePreviewView()
    }

    // Sort By Button
    @objc private func sortByButtonPressed() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Sort Wallpapers by:",
                                      preferredStyle: .alert)


        let byLikes = UIAlertAction(title: "More Liked", style: .default, handler: { (action) -> Void in
            self.byLikes = true
            self.queryWallpapers()
        })


        let  byLatest = UIAlertAction(title: "Latest Added", style: .default, handler: { (action) -> Void in
            self.byLikes = false
            self.queryWallpapers()
        })

        // Cancel Button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(byLikes)
        alert.addAction( byLatest)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // Menu Button
    @IBAction private func optionsButtonPressed(_ sender: Any) {
        var wallObj = PFObject(className: WALLPAPERS_CLASS_NAME)
        wallObj = wallsArray[selectedWallpaper]

        var favBy = [String]()
        var addFavActionTitle = ""

        if wallObj[WALLPAPERS_FAVORITED_BY] != nil {
            favBy = wallObj[WALLPAPERS_FAVORITED_BY] as! [String]
            if PFUser.current() != nil {
                if favBy.contains(PFUser.current()!.objectId!) {
                    addFavActionTitle = "- Remove from Favorites"
                } else {
                    addFavActionTitle = "+ Add to Favorites"
                }
            } else {
                addFavActionTitle = "+ Add to Favorites"
            }
        } else {
            addFavActionTitle = "+ Add to Favorites"
        }

        var likedBy = [String]()
        var likeActionTitle = ""

        if wallObj[WALLPAPERS_LIKED_BY] != nil {
            likedBy = wallObj[WALLPAPERS_LIKED_BY] as! [String]
            if PFUser.current() != nil {
                if likedBy.contains(PFUser.current()!.objectId!) {
                    likeActionTitle = "Unlike this wallpaper"
                } else {
                    likeActionTitle = "Like this wallpaper"
                }
            } else {
                likeActionTitle = "Like this wallpaper"
            }
        } else {
            likeActionTitle = "Like this wallpaper"
        }

        let alert = UIAlertController(title: APP_NAME,
                                      message: "Choose an Option",
                                      preferredStyle: .actionSheet)

        // Report Wallpaper
        let reportAction = UIAlertAction(title: "Report as Inappropriate", style: .default, handler: { (action) -> Void in

            self.showHUD(with: "Please wait...")
            wallObj[WALLPAPERS_IS_PENDING] = true
            wallObj[WALLPAPERS_REPORT_MESSAGE] = "Reported as Inappropriate"
            wallObj.saveInBackground(block: { [weak self] (succ, error) in
                if error == nil {
                    self?.hideHUD()
                    self?.showSimpleAlert(with: "Thanks for reporting this wallpaper. Our staff review this request.")
                    _ = self?.navigationController?.popViewController(animated: true)
                }
            })
        })

        // Like Wallpaper
        let likeAction = UIAlertAction(title: likeActionTitle, style: .default, handler: { (action) -> Void in

            if PFUser.current() != nil {

                if wallObj[WALLPAPERS_LIKED_BY] == nil {
                    likedBy.append(PFUser.current()!.objectId!)
                    wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                    wallObj[WALLPAPERS_LIKED_BY] = likedBy
                    wallObj.saveInBackground(block: { [weak self] (succ, error) in
                        if error == nil {
                            self?.showSimpleAlert(with: "You've liked this wallpaper. ")
                        }
                    })

                } else {

                    if likedBy.contains(PFUser.current()!.objectId!) {
                        wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: -1)
                        likedBy = likedBy.filter { $0 != PFUser.current()!.objectId! }

                        wallObj[WALLPAPERS_LIKED_BY] = likedBy
                        wallObj.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.showSimpleAlert(with: "You've unliked this wallpaper")
                            }
                        })

                    } else {
                        likedBy.append(PFUser.current()!.objectId!)
                        wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                        wallObj[WALLPAPERS_LIKED_BY] = likedBy
                        wallObj.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.showSimpleAlert(with: "You've liked this wallpaper")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Like this Wallpaper. Want to Login now?",
                                              preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(loginViewController, animated: true, completion: nil)
                })

                // Cancel Button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        })

        // Add To Favorites
        let addToFavoriteAction = UIAlertAction(title: addFavActionTitle, style: .default, handler: { (action) -> Void in
            if PFUser.current() != nil {

                if wallObj[WALLPAPERS_FAVORITED_BY] == nil {
                    favBy.append(PFUser.current()!.objectId!)

                    wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                    wallObj.saveInBackground(block: { [weak self] (succ, error) in
                        if error == nil {
                            self?.showSimpleAlert(with: "Added to your Favorites")
                        }
                    })

                } else {

                    if favBy.contains(PFUser.current()!.objectId!) {
                        favBy = favBy.filter { $0 != PFUser.current()!.objectId! }

                        wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                        wallObj.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.showSimpleAlert(with: "Removed from your Favorites")
                            }
                        })

                    } else {
                        favBy.append(PFUser.current()!.objectId!)

                        wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                        wallObj.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.showSimpleAlert(with: "Added to your Favorites")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Add to your Favorites. Want to Login now?",
                                              preferredStyle: .alert)


                let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(loginViewController, animated: true, completion: nil)
                })

                // Cancel Button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }

        })

        // Remove From Favorites
        let removeFromFavoriteAction = UIAlertAction(title: "Remove from Favorites", style: .default, handler: { (action) -> Void in

            var favBy = [String]()
            favBy = wallObj[WALLPAPERS_FAVORITED_BY] as! [String]
            favBy = favBy.filter { $0 != PFUser.current()!.objectId! }

            wallObj[WALLPAPERS_FAVORITED_BY] = favBy
            wallObj.saveInBackground(block: { [weak self] (succ, error) in
                if error == nil {
                    self?.showSimpleAlert(with: "Removed from your Favorites")
                    self?.hideImagePreviewView()
                    self?.queryWallpapers()
                }
            })
        })

        // Cancel Button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(reportAction)
        alert.addAction(likeAction)

        if isFavorites {
            alert.addAction(removeFromFavoriteAction)
        } else {
            alert.addAction(addToFavoriteAction)
        }

        alert.addAction(cancelAction)

        if UIDevice.current.userInterfaceIdiom == .pad {
            let popOver = UIPopoverController(contentViewController: alert)
            popOver.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2, width: 0, height: 0), in: self.view, permittedArrowDirections: .down, animated: true)
        } else {
            present(alert, animated: true, completion: nil)
        }
    }

    // Share Wallpaper
    @IBAction private func shareButtonPressed(_ sender: AnyObject) {
        let message = "Hey, check out this wallpaper found on #\(APP_NAME)!"
        let image = imagePreviewImageView.image!

        let shareItems: Array = [message, image] as [Any]

        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]

        if UIDevice.current.userInterfaceIdiom == .pad {
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.left, animated: true)
        } else {
            present(activityViewController, animated: true, completion: nil)
        }
    }

    // Back Button
    @objc private func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

}

// MARK: UICollectionViewDataSource

extension WallGrid: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallCell", for: indexPath) as! WallCell

        var wallObj = PFObject(className: WALLPAPERS_CLASS_NAME)
        wallObj = wallsArray[indexPath.row]

        let imageFile = wallObj[WALLPAPERS_IMAGE] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data else {
                    return
            }
            cell.wallImage.image = UIImage(data: imageData)
        })
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension WallGrid: UICollectionViewDelegate {

    // Show Image Preview
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var wallObj = PFObject(className: WALLPAPERS_CLASS_NAME)
        wallObj = wallsArray[indexPath.row]

        // Likes
        if wallObj[WALLPAPERS_LIKES] != nil {
            let likes = wallObj[WALLPAPERS_LIKES] as! Int
            self.likesLabel.text = "♥️ \(likes) likes"
        } else {
            self.likesLabel.text = ""
        }

        selectedWallpaper = indexPath.row

        let imageFile = wallObj[WALLPAPERS_IMAGE] as? PFFileObject
        imageFile?.getDataInBackground(block: { [weak self] (data, error) in
            guard let self = self,
                error == nil,
                let imageData = data else {
                    return
            }
            self.imagePreviewImageView.image = UIImage(data: imageData)
            self.showImagePreviewView()
        })
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension WallGrid: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3, height: view.frame.size.width / 2)
    }
}
