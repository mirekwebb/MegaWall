//
//  SignUp.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//



import UIKit
import Parse


class SignUp: UIViewController, UITextFieldDelegate
{
    
    // Views
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    @IBOutlet var signpViews: [UIView]!

    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 650)
    
    
    // Placeholder Ccolor
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "choose a username", attributes: [NSAttributedStringKey.foregroundColor: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "choose a password", attributes: [NSAttributedStringKey.foregroundColor: color])
    emailTxt.attributedPlaceholder = NSAttributedString(string: "type your email address", attributes: [NSAttributedStringKey.foregroundColor: color])

    
    
     // Round Corners
     for aView in signpViews {
     aView.layer.cornerRadius = 6
     aView.layer.borderColor = UIColor.black.cgColor
     aView.layer.borderWidth = 0
     }
     signUpOutlet.layer.cornerRadius = 6
     touOutlet.layer.cornerRadius = 6
}
    
    
    
// Dismiss Keyboard
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
   dismissKeyboard()
}

func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
    
    
// SignUp Button
@IBAction func signupButt(_ sender: AnyObject) {
    dismissKeyboard()
    
    if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" {
        simpleAlert(mess: "Please fill all fields to SignUp.")
        self.hideHUD()
        
    } else {
        showHUD("Please wait...")

        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text!.lowercased()
        userForSignUp.password = passwordTxt.text
        userForSignUp.email = emailTxt.text
        
        userForSignUp.signUpInBackground { (succeeded, error) -> Void in
            if error == nil {
                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
        
            } else {
                self.simpleAlert(mess: "\(error!.localizedDescription)")
                self.hideHUD()
        }}
    }
}
    
    
    
    
// TextField Delegate
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt {
        emailTxt.resignFirstResponder()
        signupButt(self)
    }
    
return true
}
    
    
    
    
// Dismiss Button
@IBAction func dismissButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    
    

// Terms & Condition Button
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
    

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
