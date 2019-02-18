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
    
    // Views
    @IBOutlet var catImage: UIImageView!
    @IBOutlet var catNameLabel: UILabel!
}



class Categories: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, UISearchBarDelegate
{

    // Views
    @IBOutlet var catTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    
    // AdMob Banner View
    var adMobBannerView = GADBannerView()

    
    // Vars
    var categoriesArray = [PFObject]()
   

    
    
override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
    
    
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "Browse Categories".uppercased()

    // Initialize a Back BarButton Item
    let backButt = UIButton(type: .custom)
    backButt.adjustsImageWhenHighlighted = false
    backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backButt.addTarget(self, action: #selector(backButton(_:)), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
    backButt.setTitle("BACK", for: UIControlState.normal)
    backButt.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
    backButt.setTitleColor(UIColor.white, for:UIControlState.normal)
    
    if let font : UIFont = UIFont(name: "Montserrat-Regular", size: 12) {
        rightBarButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: font], for: UIControlState.normal)
    }
    
    
    // Ini AdMob
    initAdMobBanner()

    
    // Query
    queryCategories()
}


    
    
    
    
// Categories
func queryCategories() {
    showHUD("Loading...")
    
    let query = PFQuery(className: CATEGORIES_CLASS_NAME)
    
    // Search
    if searchBar.text != "" {
        let searchStr = searchBar.text!.capitalized
        query.whereKey(CATEGORIES_NAME, contains: searchStr)
    }
    
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.categoriesArray = objects!
            self.hideHUD()
            self.catTableView.reloadData()
            
        } else {
            self.simpleAlert(mess: "\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
  
    
    
// TableView Delegates
func numberOfSections(in tableView: UITableView) -> Int {
        return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath) as! CatCell
    
    let catClass = categoriesArray[indexPath.row]
    
    let imageFile = catClass[CATEGORIES_THUMB] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            cell.catImage.image = UIImage(data: imageData)
    }}})
    
    cell.catImage.layer.cornerRadius = 10
    cell.catNameLabel.text = "  \(catClass[CATEGORIES_NAME]!)"
    
    // Layout cell
    cell.backgroundColor = UIColor.clear
    
    
return cell
}

    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
}
    
    
// Show Wallpapers
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var catClass = PFObject(className: CATEGORIES_CLASS_NAME)
    catClass = categoriesArray[indexPath.row]
    
    let wgVC = storyboard?.instantiateViewController(withIdentifier: "WallGrid") as! WallGrid
    wgVC.categoryName = "\(catClass[CATEGORIES_NAME]!)"
    wgVC.isFavorites = false
    navigationController?.pushViewController(wgVC, animated: true)
}
    

    

    
// SearchBar
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.text = ""
    searchBar.showsCancelButton = false
    
    queryCategories()
}
 
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    queryCategories()
}

func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
   
    searchBar.showsCancelButton = true
}
    
    
    
    
// Back Button
@objc func backButton(_ sender:UIButton) {
    _ = navigationController?.popViewController(animated: true)
}
    
    

    
// Refresh Button
@IBAction func refreshButt(_ sender: AnyObject) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
    
    queryCategories()
}
    
    
    
    


// AdMob Banners
func initAdMobBanner() {
    adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
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
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 20
        } else { h = 0 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
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


    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
