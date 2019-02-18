//
//  Configs.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//



import Foundation
import UIKit



let APP_NAME = "WallStudio" // Your App Name

let ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/7805958028" // Your AdMob ID

let SUBMIT_EMAIL = "submit@example.com" // Email for submission wallpapers

// Your Parse Keys
let PARSE_APP_ID = "We9cpGc4E6wabNlz9IWCBWILy6qzLfRYVRdImew8"
let PARSE_CLIENT_KEY = "8keoPPwwgjvgFzeEECt8ZzBo3VFCAU6q2JR6xwvn"





// HUD View
let hudView = UIView(frame: CGRect(x:0, y:0, width:120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:80, height:80))
extension UIViewController {
    func showHUD(_ mess:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor.black
        hudView.alpha = 0.8
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = .white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 120, height:20)
        label.font = UIFont(name: "Montserrat-Regular", size: 11)
        label.text = mess
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(mess:String) {
        let alert = UIAlertController(title: APP_NAME,
                                      message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}



