//
//  UIViewController + Extensions.swift
//  WallStudio
//
//  Created by Andrei Rybak on 2/18/19.
//  Copyright © 2019 GF. All rights reserved.
//

import Foundation
import UIKit

// HUD View
// TODO: Change implementation for HUD view. It will fix Thread warnings.
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

extension UIViewController {

    func showHUD(with message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            hudView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
            hudView.backgroundColor = UIColor.black
            hudView.alpha = 0.8
            hudView.layer.cornerRadius = 8

            indicatorView.center = CGPoint(x: hudView.frame.size.width / 2, y: hudView.frame.size.height / 2)
            indicatorView.activityIndicatorViewStyle = .white
            hudView.addSubview(indicatorView)
            indicatorView.startAnimating()
            self.view.addSubview(hudView)

            label.frame = CGRect(x: 0, y: 90, width: 120, height: 20)
            label.font = UIFont(name: "Montserrat-Regular", size: 11)
            label.text = message
            label.textAlignment = .center
            label.textColor = UIColor.white
            hudView.addSubview(label)
        }
    }

    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }

    func showSimpleAlert(with message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            let alert = UIAlertController(title: APP_NAME,
                                          message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showLoginAlert(with message: String) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: message,
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
            self.present(loginViewController, animated: true, completion: nil)
        })

        // Cancel Button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })

        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
