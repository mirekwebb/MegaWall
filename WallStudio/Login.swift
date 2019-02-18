//
//  Login.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//



import UIKit
import Parse
import ParseFacebookUtilsV4


class Login: UIViewController, UITextFieldDelegate, UIAlertViewDelegate
{
    
    // Views
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var loginViews: [UIView]!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet var loginButtons: [UIButton]!
    @IBOutlet weak var logoImage: UIImageView!
    
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        dismiss(animated: false, completion: nil)
    }
}

override func viewDidLoad() {
        super.viewDidLoad()
        
    // Layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    
    
    // Placeholder Color
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: color])
    
    
    // Round Corners
    for aView in loginViews {
        aView.layer.cornerRadius = 6
        aView.layer.borderColor = UIColor.black.cgColor
        aView.layer.borderWidth = 0
    }
    
    loginOutlet.layer.cornerRadius = 6
    
    for butt in loginButtons {
        butt.layer.cornerRadius = 6
        butt.layer.borderColor = UIColor.black.cgColor
        butt.layer.borderWidth = 0
    }
}
    
    
    
   
// Login Button
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD("Please wait...")
        
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        if error == nil {
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
                
        } else {
            self.simpleAlert(mess: "\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
 
    


// Facebook Login Button
@IBAction func facebookButt(_ sender: Any) {
    // Set permissions required from the facebook user account
    let permissions = ["public_profile", "email"];
    showHUD("Please wait...")
    
    PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { (user, error) in
        if user == nil {
            self.simpleAlert(mess: "Facebook login cancelled")
            
        } else if (user!.isNew) {
            print("new user signed with facebook");
            self.getFBUserData()
            
        } else {
            print("usr logged with facebook");
            
            self.dismiss(animated: false, completion: nil)
            self.hideHUD()
    }}
}
    
    
func getFBUserData() {
    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"])
    let connection = FBSDKGraphRequestConnection()
    connection.add(graphRequest) { (connection, result, error) in
        if error == nil {
            let userData:[String:AnyObject] = result as! [String : AnyObject]
                
            let name = userData["name"] as! String
            let email = userData["email"] as! String
            let currUser = PFUser.current()!
            let nameArr = name.components(separatedBy: " ")
            var username = String()
            for word in nameArr {
                username.append(word.lowercased())
            }
            currUser.username = username
            currUser.email = email
            currUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.dismiss(animated: false, completion: nil)
                    self.hideHUD()
            }})
                
        } else {
            self.simpleAlert(mess: "\(error!.localizedDescription)")
    }}
    connection.start()
}
    
    
  
    

    
    
// SignUp Button
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    signupVC.modalTransitionStyle = .crossDissolve
    present(signupVC, animated: true, completion: nil)
}
    
    
   
    
// TextField Delegates
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {
        passwordTxt.resignFirstResponder()
        loginButt(self)
    }
return true
}
    
    
    
    
    
    
// Dismiss Keyboard
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}


    
    

    
// Forgot Password?
@IBAction func forgotPasswButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
                message: "Type your email address you used to register.",
                preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
        // TextField
        let textField = alert.textFields!.first!
        let txtStr = textField.text!
        PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
            if error == nil {
                self.simpleAlert(mess: "You will receive an email shortly with a link to reset your password")
        }})
        
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in })
    
    alert.addTextField { (textField: UITextField) in
        textField.keyboardAppearance = .dark
        textField.keyboardType = .emailAddress
    }
    
    alert.addAction(ok)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}


    

    
    
// Dismiss Button
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
