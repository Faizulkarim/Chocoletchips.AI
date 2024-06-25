//
//  AppDelegate.swift
//  Plamedot
//
//  Created by Md Faizul karim on 29/1/23.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseCrashlytics
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.\
        setKeyBoard()
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func setKeyBoard() {
        IQKeyboardManager.shared.enable                                           = true
        IQKeyboardManager.shared.enableAutoToolbar                                = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField                    = 5
        IQKeyboardManager.shared.shouldResignOnTouchOutside                       = true
        IQKeyboardManager.shared.toolbarTintColor                                 = UIColor.brown
    }


}

