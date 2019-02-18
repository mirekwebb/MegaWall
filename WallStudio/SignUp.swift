//
//  SignUp.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse

class SignUp: UIViewController {

    @IBOutlet private var containerScrollView: UIScrollView!
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private weak var signUpOutlet: UIButton!
    @IBOutlet private weak var termsOfUseButton: UIButton!
    @IBOutlet private var signupViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Layouts
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 650)

        // Placeholder Ccolor
        let color = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "choose a username", attributes: [NSAttributedStringKey.foregroundColor: color])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "choose a password", attributes: [NSAttributedStringKey.foregroundColor: color])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "type your email address", attributes: [NSAttributedStringKey.foregroundColor: color])

        // Round Corners
        for aView in signupViews {
            aView.layer.cornerRadius = 6
            aView.layer.borderColor = UIColor.black.cgColor
            aView.layer.borderWidth = 0
        }

        signUpOutlet.layer.cornerRadius = 6
        termsOfUseButton.layer.cornerRadius = 6
    }

    // Dismiss Keyboard
    @IBAction private func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }

    // SignUp Button
    @IBAction func signupButtonPressed(_ sender: AnyObject) {
        dismissKeyboard()

        if usernameTextField.text == "" || passwordTextField.text == "" || emailTextField.text == "" {
            showSimpleAlert(with: "Please fill all fields to SignUp.")
            self.hideHUD()

        } else {
            showHUD(with: "Please wait...")

            let userForSignUp = PFUser()
            userForSignUp.username = usernameTextField.text!.lowercased()
            userForSignUp.password = passwordTextField.text
            userForSignUp.email = emailTextField.text

            userForSignUp.signUpInBackground { [weak self] (succeeded, error) -> Void in
                guard let strongSelf = self,
                    error == nil else {
                        self?.hideHUD()
                        self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                        return
                }
                strongSelf.hideHUD()
                strongSelf.dismiss(animated: false, completion: nil)
            }
        }
    }

    // Dismiss Button
    @IBAction private func dismissButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    // Terms & Condition Button
    @IBAction private func termsOfUseButtonPressed(_ sender: AnyObject) {
        let termsOfUseVC = storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(termsOfUseVC, animated: true, completion: nil)
    }
}

extension SignUp: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }

        if textField == passwordTextField {
            emailTextField.becomeFirstResponder()
        }

        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            signupButtonPressed(self)
        }
        return true
    }
}
