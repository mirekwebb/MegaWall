//
//  AppDelegate.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_ID
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)

        // Init Facebook
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)

        // Setup StatusBar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)

        // Setup Push Notifications
        let notifTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: notifTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0

        // TintText AlertViews
        self.window?.tintColor = UIColor.black

        // 3D Touch Functions
        if #available(iOS 9.0, *) {

            let shortcut1 = UIMutableApplicationShortcutItem(type: "share",
                                                             localizedTitle: "Share \(APP_NAME)",
                                                             localizedSubtitle: "",
                                                             icon: UIApplicationShortcutIcon(type: .share),
                                                             userInfo: nil
            )

            application.shortcutItems = [shortcut1]

        } else {

        }

        return true
    }


    // Handler for 3D Touch
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {

        case "share":
            let message = "Check out \(APP_NAME) on the AppStore: https://goo.gl/EVkNwd"
            let image = UIImage(named: "logo")!

            let shareItems = [message, image] as [Any]

            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]

            if UIDevice.current.userInterfaceIdiom == .pad {
                let popOver = UIPopoverController(contentViewController: activityViewController)
                popOver.present(from: .zero, in: (window!.rootViewController?.view)!, permittedArrowDirections: .any, animated: true)
            } else {
                window!.rootViewController?.present(activityViewController, animated: true, completion: nil)
            }

        default:
            break
        }
        completionHandler(true)
    }


    // Push Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground(block: { (succ, error) in
            if error == nil {
                print("device registered")
            } else {
                print("\(error!.localizedDescription)")
            }
        })
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PFPush.handle(userInfo)
        if application.applicationState == .inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(inBackground: userInfo, block: nil)
        }
    }

    // Facebook Login
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

