//
//  Categories.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AudioToolbox
import Parse

class CatCell: UITableViewCell {
    @IBOutlet var catImage: UIImageView!
    @IBOutlet var catNameLabel: UILabel!
}

class Categories: UIViewController {

    @IBOutlet private var categoriesTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var rightBarButtonItem: UIBarButtonItem!

    private var categoriesArray = [PFObject]()

    // AdMob Banner View
    private var adMobBannerView = GADBannerView()

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Browse Categories".uppercased()

        // Initialize a Back BarButton Item
        let backButton = UIButton(type: .custom)
        backButton.adjustsImageWhenHighlighted = false
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        backButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        if let font: UIFont = UIFont(name: "Montserrat-Regular", size: 12) {
            rightBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: font], for: UIControlState.normal)
        }

        // Initialize AdMob
        initAdMobBanner()

        // Query
        queryCategories()
    }

    // Categories
    private func queryCategories() {
        showHUD(with: "Loading...")

        let query = PFQuery(className: CATEGORIES_CLASS_NAME)

        // Search
        if searchBar.text != "" {
            let searchStr = searchBar.text!.capitalized
            query.whereKey(CATEGORIES_NAME, contains: searchStr)
        }

        query.findObjectsInBackground { [weak self] (objects, error) in
            guard let self = self else {
                return
            }

            if error == nil {
                self.categoriesArray = objects!
                self.categoriesTableView.reloadData()
                self.hideHUD()
            } else {
                self.hideHUD()
                self.showSimpleAlert(with: "\(error!.localizedDescription)")
            }
        }
    }

    // SearchBar
    private func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false

        queryCategories()
    }

    private func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        queryCategories()
    }

    // Back Button
    @objc private func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    // Refresh Button
    @IBAction private func refreshButtonPressed(_ sender: AnyObject) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false

        queryCategories()
    }

    // AdMob Banners
    private func initAdMobBanner() {
        adMobBannerView.adSize = GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)

        let request = GADRequest()
        adMobBannerView.load(request)
    }

    // Show the banner
    private func showBanner(_ banner: UIView) {
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

    // Hide the banner
    private func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }

}

extension Categories: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath) as! CatCell

        let catClass = categoriesArray[indexPath.row]

        let imageFile = catClass[CATEGORIES_THUMB] as? PFFileObject
        imageFile?.getDataInBackground(block: { (data, error) in
            guard error == nil,
                let imageData = data else {
                    return
            }
            cell.catImage.image = UIImage(data: imageData)
        })

        cell.catImage.layer.cornerRadius = 10
        cell.catNameLabel.text = "  \(catClass[CATEGORIES_NAME]!)"

        cell.backgroundColor = UIColor.clear

        return cell
    }

}

extension Categories: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // Show Wallpapers
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var categoriesClass = PFObject(className: CATEGORIES_CLASS_NAME)
        categoriesClass = categoriesArray[indexPath.row]

        let wallGridViewController = storyboard?.instantiateViewController(withIdentifier: "WallGrid") as! WallGrid
        wallGridViewController.categoryName = "\(categoriesClass[CATEGORIES_NAME]!)"
        wallGridViewController.isFavorites = false
        navigationController?.pushViewController(wallGridViewController, animated: true)
    }
}

extension Categories: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

extension Categories: GADBannerViewDelegate {

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
