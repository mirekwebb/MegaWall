//
//  Home.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//



import UIKit
import Parse


class Home: UIViewController {

    // Views
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var containerView: UIView!
    @IBOutlet var homebuttonsViews: [UIView]!
    @IBOutlet weak var logoImage: UIImageView!
     @IBOutlet weak var touOutlet: UIButton!
    
    
override func viewWillAppear(_ animated: Bool) {
      navigationController?.isNavigationBarHidden = true
}

    
override func viewDidLoad() {
        super.viewDidLoad()

    logoImage.layer.cornerRadius = 20
    
    // Radio Buttons
    for butt in buttons {
        butt.layer.cornerRadius = 3
    }
    
    for aView in homebuttonsViews {
        aView.layer.cornerRadius = 12
    }
    
    
    // Center Buttons (X-Y)
    containerView.center = view.center
    
    
    
    
    // NOTE: REMOVE THIS LINE FROM HERE ---------------------------------------------------- */
    
    //createCategoriesAndWallpapersClasses()
    
    // TO HERE
    
}

    
   
    
    
    
// Browse Button
@IBAction func browseButt(_ sender: AnyObject) {
    let catVC = storyboard?.instantiateViewController(withIdentifier: "Categories") as! Categories
    navigationController?.pushViewController(catVC, animated: true)
}
    
    
    
    
// Submit Button
@IBAction func submitButt(_ sender: AnyObject) {
    if PFUser.current() != nil {
        let subVC = storyboard?.instantiateViewController(withIdentifier: "SubmitWallpaper") as! SubmitWallpaper
        navigationController?.pushViewController(subVC, animated: true)
    
    } else {
        let alert = UIAlertController(title: APP_NAME,
            message: "Please Login to Submit a Wallpaper. Want to Login now?",
            preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            self.present(aVC, animated: true, completion: nil)
        })
        
        // Cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
    
    

    
   
// Favorites Button
@IBAction func favoritesButt(_ sender: Any) {
    if PFUser.current() != nil {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "WallGrid") as! WallGrid
        aVC.isFavorites = true
        navigationController?.pushViewController(aVC, animated: true)
        
    } else {
        let alert = UIAlertController(title: APP_NAME,
        message: "Please Login to Manage your Favorites. Want to Login now?",
        preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            self.present(aVC, animated: true, completion: nil)
        })
        
        // Cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
    
    

    
    
// Account Button
@IBAction func accountButt(_ sender: Any) {
    if PFUser.current() != nil {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Account") as! Account
        navigationController?.pushViewController(aVC, animated: true)
    } else {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(aVC, animated: true, completion: nil)
    }
}

    
    
    

    
    
// Create Class - Config Database
func createCategoriesAndWallpapersClasses() {
    showHUD("Sync Database...")
    
    // Create Categories
    let categoriesClass = PFObject(className: CATEGORIES_CLASS_NAME)
    categoriesClass[CATEGORIES_NAME] = "MODIFY"
    let imageData = UIImageJPEGRepresentation(UIImage(named: "catIconDemo")!, 0.1)
    let imageFile = PFFile(name:"thumb.jpg", data:imageData!)
    categoriesClass[CATEGORIES_THUMB] = imageFile
    categoriesClass.saveInBackground(block: { (succ, error) in
        if error == nil {
            
            // Create Wallpapers
            let wallClass = PFObject(className: WALLPAPERS_CLASS_NAME)
            wallClass[WALLPAPERS_CATEGORY] = "MODIFY"
            wallClass[WALLPAPERS_IS_PENDING] = false
            let imageData = UIImageJPEGRepresentation(UIImage(named: "bkg")!, 0.1)
            let imageFile = PFFile(name:"image.jpg", data:imageData!)
            wallClass[WALLPAPERS_IMAGE] = imageFile
            wallClass.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert(mess: "Congrats!...your app is setup correctly. Now add your own Data in your Dashboard.")
                    self.hideHUD()
            }})
            
        } else {
            self.simpleAlert(mess: "\(error!.localizedDescription)")
            self.hideHUD()
    }})
    

}
    
    // Terms & Condition Button
    @IBAction func touButt(_ sender: AnyObject) {
        let touVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(touVC, animated: true, completion: nil)
    }
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
