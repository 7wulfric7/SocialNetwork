//
//  AppDelegate.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/2/20.
//

import UIKit
import FBSDKCoreKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "BackButton")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "BackButton")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        func application(
               _ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
               ApplicationDelegate.shared.application(app,open: url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: options[UIApplication.OpenURLOptionsKey.annotation]
               )
           }
    }


}

