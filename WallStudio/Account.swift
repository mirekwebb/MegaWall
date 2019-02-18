//
//  Account.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//



import UIKit
import Parse



class Account: UIViewController, UITextFieldDelegate
{

    // Views
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
        
    
    
override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "Account".uppercased()
    
    
    // Back BarButton
    let backButt = UIButton(type: .custom)
    backButt.adjustsImageWhenHighlighted = false
    backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
    backButt.setTitle("BACK", for: UIControlState.normal)
    backButt.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
    backButt.setTitleColor(UIColor.white, for:UIControlState.normal)
    
    
    
    // Logout BarButton
    let logoutButton = UIButton(type: .custom)
    logoutButton.adjustsImageWhenHighlighted = false
    logoutButton.frame = CGRect(x: 0, y: 0, width: 58, height: 44)
    logoutButton.addTarget(self, action: #selector(logoutButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
    logoutButton.setTitle("LOGOUT", for: UIControlState.normal)
    logoutButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
    logoutButton.setTitleColor(UIColor.white, for:UIControlState.normal)

    
    
    
    // User Data
    let currUser = PFUser.current()!
    usernametxt.text = currUser.username!
    emailTxt.text = currUser.email!
    
    
    
    // Round Corners
    usernametxt.layer.cornerRadius = 5
    emailTxt.layer.cornerRadius = 5
    

}

  
  
   
// Update Profile Button
@IBAction func updateProfileButt(_ sender: Any) {
    if usernametxt.text == "" || emailTxt.text == "" {
        self.simpleAlert(mess: "Please insert a Username and a valid Email address")
    
    } else {
        let currUser = PFUser.current()!
        showHUD("Loading...")
        
        usernametxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        
        currUser.username = usernametxt.text!
        currUser.email = emailTxt.text!

        currUser.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
                self.simpleAlert(mess: "Profile updated")
            } else {
                self.hideHUD()
                self.simpleAlert(mess: "\(error!.localizedDescription)")
        }})
    
    }
}


    
    
    
    
    
// Logout Button
@objc func logoutButt() {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: .alert)
        
    let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
        self.showHUD("Logging Out...")
            
        PFUser.logOutInBackground(block: { (error) in
            if error == nil {
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.hideHUD()
        })
    })
        
        
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
    alert.addAction(ok); alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}

    
    
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
return true
}
    
    
    
    
// Back Button
@objc func backButton() {
    _ = navigationController?.popViewController(animated: true)
}
    

    
  
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
