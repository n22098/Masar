//
//  AppDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 04/12/2025.
//

import UIKit
import FirebaseCore
import Cloudinary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // تهيئة Firebase
        FirebaseApp.configure()
        
        // تحميل اللغة المحفوظة
        if let language = UserDefaults.standard.string(forKey: "appLanguage") {
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        
        // 🔥 FIXED: تطبيق Dark Mode فور تشغيل التطبيق
        applyDarkModePreference()
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    
    // MARK: - 🔥 FIXED: Dark Mode Helper
    private func applyDarkModePreference() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // تطبيق على جميع النوافذ الموجودة
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = style
            }
    }
}
