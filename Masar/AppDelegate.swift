//
//  AppDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 04/12/2025.
//

import UIKit
import FirebaseCore // ١. إضافة مكتبة الفايربيز الأساسية

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // ٢. إضافة كود تهيئة الفايربيز عند تشغيل التطبيق
        FirebaseApp.configure()
        
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
