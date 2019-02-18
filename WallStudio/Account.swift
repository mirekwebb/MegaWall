//
//  Account.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse

class Account: UIViewController {

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Account".uppercased()

        // Back BarButton
        let backButton = UIButton(type: .custom)
        backButton.adjustsImageWhenHighlighted = false
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.setTitle("BACK", for: UIControlState.normal)
        backButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        backButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        // Logout BarButton
        let logoutButton = UIButton(type: .custom)
        logoutButton.adjustsImageWhenHighlighted = false
        logoutButton.frame = CGRect(x: 0, y: 0, width: 58, height: 44)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
        logoutButton.setTitle("LOGOUT", for: UIControlState.normal)
        logoutButton.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        logoutButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        // User Data
        let currUser = PFUser.current()!
        usernameTextField.text = currUser.username!
        emailTextField.text = currUser.email!

        usernameTextField.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
    }

    // Update Profile Button
    @IBAction private func updateProfileButtonPressed(_ sender: Any) {
        guard usernameTextField.text != "", emailTextField.text != "" else {
            self.showSimpleAlert(with: "Please insert a Username and a valid Email address")
            return
        }

        let currentUser = PFUser.current()!
        showHUD(with: "Loading...")

        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()

        currentUser.username = usernameTextField.text!
        currentUser.email = emailTextField.text!

        currentUser.saveInBackground(block: { [weak self] (succ, error) in
            guard let strongSelf = self, error == nil else {
                self?.hideHUD()
                self?.showSimpleAlert(with: "\(error!.localizedDescription)")
                return
            }
            strongSelf.hideHUD()
            strongSelf.showSimpleAlert(with: "Profile updated")
        })
    }

    // Logout Button
    @objc private func logoutButtonPressed() {
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Are you sure you want to logout?",
                                      preferredStyle: .alert)

        let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
            self.showHUD(with: "Logging Out...")

            PFUser.logOutInBackground(block: { (error) in
                guard error == nil else {
                    self.hideHUD()
                    return
                }
                _ = self.navigationController?.popViewController(animated: true)
                self.hideHUD()
            })
        })

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    // Back Button
    @objc func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }

}

// MARK: UITextFieldDelegate

extension Account: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
