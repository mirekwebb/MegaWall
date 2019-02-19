//
//  Login.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse

class Login: UIViewController, UIAlertViewDelegate {

    @IBOutlet private var containerScrollView: UIScrollView!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var loginViews: [UIView]!
    @IBOutlet private weak var loginOutlet: UIButton!
    @IBOutlet private var loginButtons: [UIButton]!
    @IBOutlet private weak var logoImage: UIImageView!

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
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: color])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: color])

        // Round Corners
        for aView in loginViews {
            aView.layer.cornerRadius = 6
            aView.layer.borderColor = UIColor.black.cgColor
            aView.layer.borderWidth = 0
        }

        loginOutlet.layer.cornerRadius = 6

        for button in loginButtons {
            button.layer.cornerRadius = 6
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 0
        }
    }

    // Login Button
    @IBAction private func loginButtonPressed(_ sender: AnyObject) {
        dismissKeyboard()
        showHUD(with: "Please wait...")

        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { [weak self] (user, error) -> Void in
            guard let strongSelf = self,
                error != nil else {
                    self?.hideHUD()
                    self?.dismiss(animated: true, completion: nil)
                    return
            }
            strongSelf.showSimpleAlert(with: "\(error!.localizedDescription)")
            strongSelf.hideHUD()
        }
    }

    // Facebook Login Button
    @IBAction private func facebookButtonPressed(_ sender: Any) {

        // Set permissions required from the facebook user account
        let permissions = ["public_profile", "email"]
        showHUD(with: "Please wait...")

        PFFacebookUtils.logInInBackground(withReadPermissions: permissions) { [weak self] (user, error) in
            guard let self = self else {
                return
            }
            if user == nil {
                self.showSimpleAlert(with: "Facebook login cancelled")

            } else if (user!.isNew) {
                print("new user signed with facebook")
                self.getFBUserData()

            } else {
                print("usr logged with facebook")

                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
            } }
    }

    private func getFBUserData() {

        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"])
        let connection = FBSDKGraphRequestConnection()

        connection.add(graphRequest) { [weak self] (connection, result, error) in
            guard error == nil else {
                self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                return
            }

            let userData: [String: AnyObject] = result as! [String: AnyObject]

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
            currUser.saveInBackground(block: { [weak self] (succ, error) in
                if error == nil {
                    self?.dismiss(animated: false, completion: nil)
                    self?.hideHUD()
                }
            })
        }
        connection.start()
    }

    @IBAction private func signupButtonPressed(_ sender: AnyObject) {
        let signupViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
        signupViewController.modalTransitionStyle = .crossDissolve
        present(signupViewController, animated: true, completion: nil)
    }

    @IBAction private func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction private func forgotPasswordButtonPressed(_ sender: AnyObject) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Type your email address you used to register.",
                                      preferredStyle: .alert)

        let ok = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields!.first!
            let textString = textField.text!

            PFUser.requestPasswordResetForEmail(inBackground: textString, block: { [weak self] (succ, error) in
                if error == nil {
                    self?.showSimpleAlert(with: "You will receive an email shortly with a link to reset your password")
                }
            })
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
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: UITextFieldDelegate

extension Login: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            loginButtonPressed(self)
        }
        return true
    }
}
