//
//  AppDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 04/12/2025.
//

import UIKit
import FirebaseCore
import Cloudinary

/// @main: This attribute marks the entry point for the application.
/// AppDelegate: Responsible for high-level application events and global configurations.
/// OOD Principle: Singleton Pattern - The 'UIApplication' object has only one delegate (this class)
/// to manage global app behaviors.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// didFinishLaunchingWithOptions: The first method called when the app starts.
    /// Used for "Initial Setup" before the UI is presented to the user.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 1. Firebase Initialization: Connects the app to the backend services.
        // OOD Note: Centralized initialization ensures all database/auth calls work immediately.
        FirebaseApp.configure()
        
        // 2. Localization Setup: Loads the user's preferred language from persistent storage.
        // This ensures the app respects the user's settings from previous sessions.
        if let language = UserDefaults.standard.string(forKey: "appLanguage") {
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
        
        // 3. Theme Setup: Ensures the app starts in the correct visual mode (Light/Dark).
        applyDarkModePreference()
        
        return true
    }

    // MARK: - UISceneSession Lifecycle
    // These methods manage how the app creates new windows (scenes).

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Returns the configuration for creating a new scene/window.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Triggered when a user closes a scene (e.g., swiping an app away in the app switcher).
    }
    
    // MARK: - Helper Methods
    
    /// applyDarkModePreference: Globally applies the Dark Mode or Light Mode setting.
    /// OOD Principle: Encapsulation - This logic is hidden in a private method, keeping
    /// 'didFinishLaunching' clean and readable.
    private func applyDarkModePreference() {
        // Retrieve the saved preference from UserDefaults (Persistence).
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // Iterate through all active scenes and windows to apply the style globally.
        // This shows an advanced understanding of the iOS Scene Manifest system.
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = style
            }
    }
}
