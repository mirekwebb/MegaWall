//
//  AppDelegate.swift
//  WallStudio
//
//  Created by Greenfield
//  Copyright (c) 2017 Greenfield.com. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.navigationBar.barTintColor = .black
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // Parse
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_ID
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)

        // Init Facebook
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)

        // Setup Push Notifications
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0

        // TintText AlertViews
        self.window?.tintColor = UIColor.black

        // 3D Touch Functions
        let shareShortcut = UIMutableApplicationShortcutItem(type: "share",
                                                             localizedTitle: "Share \(APP_NAME)",
                                                             localizedSubtitle: "",
                                                             icon: UIApplicationShortcutIcon(type: .share),
                                                             userInfo: nil
        )

        application.shortcutItems = [shareShortcut]

        return true
    }

    // Handler for 3D Touch
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {

        case "share":
            let message = "Check out \(APP_NAME) on the AppStore: https://goo.gl/EVkNwd"
            let image = UIImage(named: "logo")!

            let shareItems = [message, image] as [Any]

            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]

            if UIDevice.isIPAD {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = window?.rootViewController?.view
                activityViewController.popoverPresentationController?.sourceRect = .zero
            }
            window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
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

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }


    func applicationWillTerminate(_ application: UIApplication) {

    }

}

