//
//  WallGrid.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import AudioToolbox
import Parse

class WallCell: UICollectionViewCell {
    @IBOutlet var wallImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
}

class WallGrid: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {

    @IBOutlet var wallCollView: UICollectionView!
    @IBOutlet var imagePreviewView: UIView!
    @IBOutlet var imgPrev: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet weak var likesLabelin: UILabel!

    // AdMob Banners
    var adMobBannerView = GADBannerView()

    var wallsArray = [PFObject]()
    var categoryName = String()
    var selectedWallpaper = 0
    var isFavorites = false
    var byLikes = false


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
        let backButt = UIButton(type: .custom)
        backButt.adjustsImageWhenHighlighted = false
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        backButt.setTitle("BACK", for: UIControlState.normal)
        backButt.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        backButt.setTitleColor(UIColor.white, for: UIControlState.normal)

        // SortBy BarButton
        let sortByButton = UIButton(type: .custom)
        sortByButton.adjustsImageWhenHighlighted = false
        sortByButton.frame = CGRect(x: 0, y: 0, width: 58, height: 44)
        sortByButton.addTarget(self, action: #selector(sortByButt), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortByButton)
        sortByButton.setTitle("SORT BY", for: UIControlState.normal)
        sortByButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        sortByButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        // Get Time
        let currentTime = Date()
        let df = DateFormatter()
        df.dateFormat = "h:mm"
        timeLabel.text = df.string(from: currentTime)

        // Ini AdMob
        initAdMobBanner()

        // Query
        queryWallpapers()
    }

    // Show Wallpapers
    func queryWallpapers() {
        showHUD("Loading...")

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

        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.wallsArray = objects!
                self.hideHUD()
                self.wallCollView.reloadData()
            } else {
                self.simpleAlert(mess: "\(error!.localizedDescription)")
                self.hideHUD()
            }
        }
    }

    // CollView Delegates
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
            if error == nil {
                if let imageData = data {
                    cell.wallImage.image = UIImage(data: imageData)
                }
            }
        })
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3, height: view.frame.size.width / 2)
    }

    // Show Image Preview
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var wallObj = PFObject(className: WALLPAPERS_CLASS_NAME)
        wallObj = wallsArray[indexPath.row]

        // Likes
        if wallObj[WALLPAPERS_LIKES] != nil {
            let likes = wallObj[WALLPAPERS_LIKES] as! Int
            self.likesLabelin.text = "♥️ \(likes) likes"
        } else {
            self.likesLabelin.text = ""
        }

        selectedWallpaper = indexPath.row

        let imageFile = wallObj[WALLPAPERS_IMAGE] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            if error == nil {
                if let imageData = data {
                    self.imgPrev.image = UIImage(data: imageData)
                    self.showImagePrevView()
                }
            }
        })
    }

    // Show/Hide Image Preview
    func showImagePrevView() {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.imagePreviewView.frame.origin.y = 0
        }, completion: { (finished: Bool) in
            self.navigationController?.isNavigationBarHidden = true
        })
    }

    func hideImagePrevView() {
        imgPrev.image = nil
        UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.imagePreviewView.frame.origin.y = self.view.frame.size.height
        }, completion: { (finished: Bool) in
            self.navigationController?.isNavigationBarHidden = false
        })
    }

    // Close Preview
    @IBAction func closePreviewButt(_ sender: Any) {
        hideImagePrevView()
    }

    // Sort By Button
    @objc func sortByButt() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Sort Wallpapers by:",
                                      preferredStyle: .alert)


        let byLikes = UIAlertAction(title: "More Liked", style: .default, handler: { (action) -> Void in
            self.byLikes = true
            self.queryWallpapers()
        })


        let latests = UIAlertAction(title: "Latest Added", style: .default, handler: { (action) -> Void in
            self.byLikes = false
            self.queryWallpapers()
        })

        // Cancel Button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(byLikes)
        alert.addAction(latests)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    // Menu Button
    @IBAction func optionsButt(_ sender: Any) {
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
        let report = UIAlertAction(title: "Report as Inappropriate", style: .default, handler: { (action) -> Void in

            self.showHUD("Please wait...")
            wallObj[WALLPAPERS_IS_PENDING] = true
            wallObj[WALLPAPERS_REPORT_MESSAGE] = "Reported as Inappropriate"
            wallObj.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    self.simpleAlert(mess: "Thanks for reporting this wallpaper. Our staff review this request.")
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        })

        // Like Wallpaper
        let like = UIAlertAction(title: likeActionTitle, style: .default, handler: { (action) -> Void in

            if PFUser.current() != nil {

                if wallObj[WALLPAPERS_LIKED_BY] == nil {
                    likedBy.append(PFUser.current()!.objectId!)
                    wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                    wallObj[WALLPAPERS_LIKED_BY] = likedBy
                    wallObj.saveInBackground(block: { (succ, error) in
                        if error == nil {
                            self.simpleAlert(mess: "You've liked this wallpaper. ")
                        }
                    })

                } else {

                    if likedBy.contains(PFUser.current()!.objectId!) {
                        wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: -1)
                        likedBy = likedBy.filter { $0 != PFUser.current()!.objectId! }

                        wallObj[WALLPAPERS_LIKED_BY] = likedBy
                        wallObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert(mess: "You've unliked this wallpaper")
                            }
                        })

                    } else {
                        likedBy.append(PFUser.current()!.objectId!)
                        wallObj.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                        wallObj[WALLPAPERS_LIKED_BY] = likedBy
                        wallObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert(mess: "You've liked this wallpaper")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Like this Wallpaper. Want to Login now?",
                                              preferredStyle: .alert)

                let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(aVC, animated: true, completion: nil)
                })

                // Cancel Button
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })

        // Add To Favorites
        let addFav = UIAlertAction(title: addFavActionTitle, style: .default, handler: { (action) -> Void in
            if PFUser.current() != nil {

                if wallObj[WALLPAPERS_FAVORITED_BY] == nil {
                    favBy.append(PFUser.current()!.objectId!)

                    wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                    wallObj.saveInBackground(block: { (succ, error) in
                        if error == nil {
                            self.simpleAlert(mess: "Added to your Favorites")
                        }
                    })

                } else {

                    if favBy.contains(PFUser.current()!.objectId!) {
                        favBy = favBy.filter { $0 != PFUser.current()!.objectId! }

                        wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                        wallObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert(mess: "Removed from your Favorites")
                            }
                        })

                    } else {
                        favBy.append(PFUser.current()!.objectId!)

                        wallObj[WALLPAPERS_FAVORITED_BY] = favBy
                        wallObj.saveInBackground(block: { (succ, error) in
                            if error == nil {
                                self.simpleAlert(mess: "Added to your Favorites")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Add to your Favorites. Want to Login now?",
                                              preferredStyle: .alert)


                let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(aVC, animated: true, completion: nil)
                })

                // Cancel Button
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }

        })

        // Remove From Favorites
        let removeFav = UIAlertAction(title: "Remove from Favorites", style: .default, handler: { (action) -> Void in

            var favBy = [String]()
            favBy = wallObj[WALLPAPERS_FAVORITED_BY] as! [String]
            favBy = favBy.filter { $0 != PFUser.current()!.objectId! }

            wallObj[WALLPAPERS_FAVORITED_BY] = favBy
            wallObj.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert(mess: "Removed from your Favorites")
                    self.hideImagePrevView()
                    self.queryWallpapers()
                }
            })
        })

        // Cancel Button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(report)
        alert.addAction(like)

        if isFavorites {
            alert.addAction(removeFav)
        } else {
            alert.addAction(addFav)
        }

        alert.addAction(cancel)

        if UIDevice.current.userInterfaceIdiom == .pad {
            let popOver = UIPopoverController(contentViewController: alert)
            popOver.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2, width: 0, height: 0), in: self.view, permittedArrowDirections: .down, animated: true)
        } else {
            present(alert, animated: true, completion: nil)
        }
    }

    // Share Wallpaper
    @IBAction func shareButt(_ sender: AnyObject) {
        let message = "Hey, check out this wallpaper found on #\(APP_NAME)!"
        let image = imgPrev.image!

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
    @objc func backButton() {
        _ = navigationController?.popViewController(animated: true)
    }

    // AdMob Banner
    func initAdMobBanner() {
        adMobBannerView.adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)

        let request = GADRequest()
        adMobBannerView.load(request)
    }

    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }

    // Show the banner
    func showBanner(_ banner: UIView) {
        var bottomOffset: CGFloat = 0

        // iPhone X
        // TODO: Add support for XSMax
        if UIScreen.main.bounds.size.height == 812 {
            bottomOffset = 20
        } else {
            bottomOffset = 0
        }

        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width / 2 - banner.frame.size.width / 2,
                              y: view.frame.size.height - banner.frame.size.height - bottomOffset,
                              width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }

    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }

    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }

}

