//
//  OptionsAlert.swift
//  WallStudio
//
//  Created by Andrei Rybak on 3/8/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit
import Parse

enum Options {
    case like
    case favorite
    case report
}

class OptionsAlert {
    private var options: [Options]
    private var presenter: UIViewController
    private var wallpaper: PFObject

    init(options: [Options], wallpaper: PFObject, presenter: UIViewController) {
        self.options = options
        self.presenter = presenter
        self.wallpaper = wallpaper
    }

    func show() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Sort Wallpapers by:",
                                      preferredStyle: .alert)


        for option in options {
            switch option {
            case .like:
                alert.addAction(likeAction())
            case .favorite:
                alert.addAction(addToFavoriteAction())
            case .report:
                alert.addAction(reportAction())
            }
        }

        presenter.present(alert, animated: true, completion: nil)
    }


    private func reportAction() -> UIAlertAction {
        let reportAction = UIAlertAction(title: "Report as Inappropriate", style: .default, handler: { [weak self] (action) -> Void in

            guard let self = self else {
                return
            }

            self.presenter.showHUD(with: "Please wait...")
            self.wallpaper[WALLPAPERS_IS_PENDING] = true
            self.wallpaper[WALLPAPERS_REPORT_MESSAGE] = "Reported as Inappropriate"
            self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                if error == nil {
                    self?.presenter.hideHUD()
                    self?.presenter.showSimpleAlert(with: "Thanks for reporting this wallpaper. Our staff review this request.")
                    _ = self?.presenter.navigationController?.popViewController(animated: true)
                }
            })
        })
        return reportAction
    }

    private func likeAction() -> UIAlertAction {
        var likedBy = [String]()
        var likeActionTitle = ""

        if wallpaper[WALLPAPERS_LIKED_BY] != nil {
            likedBy = wallpaper[WALLPAPERS_LIKED_BY] as! [String]
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

        let likeAction = UIAlertAction(title: likeActionTitle, style: .default, handler: { [weak self] (action) -> Void in

            guard let self = self else {
                return
            }

            if PFUser.current() != nil {

                if self.wallpaper[WALLPAPERS_LIKED_BY] == nil {
                    likedBy.append(PFUser.current()!.objectId!)
                    self.wallpaper.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                    self.wallpaper[WALLPAPERS_LIKED_BY] = likedBy
                    self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                        if error == nil {
                            self?.presenter.showSimpleAlert(with: "You've liked this wallpaper. ")
                        }
                    })

                } else {

                    if likedBy.contains(PFUser.current()!.objectId!) {
                        self.wallpaper.incrementKey(WALLPAPERS_LIKES, byAmount: -1)
                        likedBy = likedBy.filter { $0 != PFUser.current()!.objectId! }

                        self.wallpaper[WALLPAPERS_LIKED_BY] = likedBy
                        self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.presenter.showSimpleAlert(with: "You've unliked this wallpaper")
                            }
                        })

                    } else {
                        likedBy.append(PFUser.current()!.objectId!)
                        self.wallpaper.incrementKey(WALLPAPERS_LIKES, byAmount: 1)
                        self.wallpaper[WALLPAPERS_LIKED_BY] = likedBy
                        self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.presenter.showSimpleAlert(with: "You've liked this wallpaper")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Like this Wallpaper. Want to Login now?",
                                              preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let loginViewController = self.presenter.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.presenter.present(loginViewController, animated: true, completion: nil)
                })

                // Cancel Button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.presenter.present(alert, animated: true, completion: nil)
            }
        })
        return likeAction
    }

    private func addToFavoriteAction() -> UIAlertAction {

        var favBy = [String]()
        var addFavActionTitle = ""

        if wallpaper[WALLPAPERS_FAVORITED_BY] != nil {
            favBy = wallpaper[WALLPAPERS_FAVORITED_BY] as! [String]
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

        let addToFavoriteAction = UIAlertAction(title: addFavActionTitle, style: .default, handler: { (action) -> Void in

//            guard let self = self else {
//                return
//            }

            if PFUser.current() != nil {

                if self.wallpaper[WALLPAPERS_FAVORITED_BY] == nil {
                    favBy.append(PFUser.current()!.objectId!)

                    self.wallpaper[WALLPAPERS_FAVORITED_BY] = favBy
                    self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                        if error == nil {
                            self?.presenter.showSimpleAlert(with: "Added to your Favorites")
                        }
                    })

                } else {

                    if favBy.contains(PFUser.current()!.objectId!) {
                        favBy = favBy.filter { $0 != PFUser.current()!.objectId! }

                        self.wallpaper[WALLPAPERS_FAVORITED_BY] = favBy
                        self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.presenter.showSimpleAlert(with: "Removed from your Favorites")
                            }
                        })

                    } else {
                        favBy.append(PFUser.current()!.objectId!)

                        self.wallpaper[WALLPAPERS_FAVORITED_BY] = favBy
                        self.wallpaper.saveInBackground(block: { [weak self] (succ, error) in
                            if error == nil {
                                self?.presenter.showSimpleAlert(with: "Added to your Favorites")
                            }
                        })
                    }
                }

            } else {
                let alert = UIAlertController(title: APP_NAME,
                                              message: "Please Login to Add to your Favorites. Want to Login now?",
                                              preferredStyle: .alert)


                let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                    let loginViewController = self.presenter.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.presenter.present(loginViewController, animated: true, completion: nil)
                })

                // Cancel Button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.presenter.present(alert, animated: true, completion: nil)
            }

        })
        return addToFavoriteAction
    }
}
