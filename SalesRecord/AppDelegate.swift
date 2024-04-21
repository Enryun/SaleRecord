//
//  AppDelegate.swift
//  SalesRecord
//
//  Created by James Thang on 5/27/20.
//  Copyright © 2020 James Thang. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import RealmSwift
import DropDown
import GoogleMobileAds
import Purchases
import FirebaseFirestore


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        DropDown.startListeningToKeyboard()
    
        let _ = Firestore
            .firestore()
        
        do {
            _ = try Realm()
        } catch {
            print("Error initialize Realm, \(error)")
        }
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        GADMobileAds.sharedInstance().start(completionHandler: nil)
//        print(Realm.Configuration.defaultConfiguration.fileURL)
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "UEtrLMrABbDSdLXVfenOCzpvtcVtvxGb")
        
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


    

}

