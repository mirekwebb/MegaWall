//
//  HomeViewController.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/26/19.
//  Copyright © 2019 GF. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {

    private enum Constants {
        static let logoTopOffset: CGFloat = UIDevice.isSE ? 32 : 75
        static let titleTopOffset: CGFloat = UIDevice.isSE ? 12 : 12
        static let buttonsTopOffset: CGFloat = UIDevice.isSE ? 18 : 62
        static let spacingBetweenButton: CGFloat = UIDevice.isSE ? 15 : 24
    }

    @IBOutlet private weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonsStackViewTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var secondaryButtonsStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        createCategoriesAndWallpapersClasses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func setupViews() {
        logoTopConstraint.constant = Constants.logoTopOffset
        titleTopConstraint.constant = Constants.titleTopOffset
        buttonsStackViewTopConstraint.constant = Constants.buttonsTopOffset
        buttonsStackView.spacing = Constants.spacingBetweenButton

        if UIDevice.isSE {
            secondaryButtonsStackView.axis = .vertical
            secondaryButtonsStackView.alignment = .fill
            secondaryButtonsStackView.distribution = .equalSpacing
            secondaryButtonsStackView.spacing = Constants.spacingBetweenButton
        }
    }

    // Create Class - Config Database
    private func createCategoriesAndWallpapersClasses() {
        showHUD(with: "Sync Database...")

        // Create Categories
        let categoriesClass = PFObject(className: CATEGORIES_CLASS_NAME)
        categoriesClass[CATEGORIES_NAME] = "MODIFY"
        let imageData = UIImageJPEGRepresentation(UIImage(named: "catIconDemo")!, 0.1)
        let imageFile = PFFileObject(name: "thumb.jpg", data: imageData!)
        categoriesClass[CATEGORIES_THUMB] = imageFile

        categoriesClass.saveInBackground(block: { [weak self] (succ, error) in
            guard error == nil else {
                self?.hideHUD()
                self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                return
            }

            // Create Wallpapers
            let wallpaperClass = PFObject(className: WALLPAPERS_CLASS_NAME)
            wallpaperClass[WALLPAPERS_CATEGORY] = "MODIFY"
            wallpaperClass[WALLPAPERS_IS_PENDING] = false
            let imageData = UIImageJPEGRepresentation(UIImage(named: "bkg")!, 0.1)
            let imageFile = PFFileObject(name: "image.jpg", data: imageData!)
            wallpaperClass[WALLPAPERS_IMAGE] = imageFile

            wallpaperClass.saveInBackground(block: { [weak self] (succ, error) in
                if error == nil {
                    self?.showSimpleAlert(with: "Congrats!...your app is setup correctly. Now add your own Data in your Dashboard.")
                    self?.hideHUD()
                }
            })
        })
    }

    @IBAction func browseCatalogButtonPressed(_ sender: Any) {
        let categoriesViewController = CategoriesViewController()
        navigationController?.pushViewController(categoriesViewController, animated: true)
    }

    @IBAction func myFavoritesButtonPressed(_ sender: Any) {

        if PFUser.current() != nil {
            let likedViewController = FavoritesViewController()
            navigationController?.pushViewController(likedViewController, animated: true)

        } else {
            let alert = UIAlertController(title: APP_NAME,
                                          message: "Please Login to Manage your Favorites. Want to Login now?",
                                          preferredStyle: .alert)


            let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
                self.present(loginViewController, animated: true, completion: nil)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func uploadButtonPressed(_ sender: Any) {
        if PFUser.current() != nil {
            let subVC = storyboard?.instantiateViewController(withIdentifier: "SubmitWallpaper") as! SubmitWallpaper
            navigationController?.pushViewController(subVC, animated: true)

        } else {
            let alert = UIAlertController(title: APP_NAME,
                                          message: "Please Login to Submit a Wallpaper. Want to Login now?",
                                          preferredStyle: .alert)


            let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                self.present(loginViewController, animated: true, completion: nil)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func profileButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if PFUser.current() != nil {
            let accountViewController = storyboard.instantiateViewController(withIdentifier: "Account") as! Account
            navigationController?.pushViewController(accountViewController, animated: true)
        } else {
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
            present(loginViewController, animated: true, completion: nil)
        }
    }
}
