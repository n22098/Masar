//
//  AppDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 04/12/2025.
//

import UIKit
import FirebaseCore   // ✅ REQUIRED
import Cloudinary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    class ViewController: UIViewController {

        let cloudName: String = "<your_cloudname>"

        var cloudinary: CLDCloudinary!

        override func viewDidLoad() {
            super.viewDidLoad()
            initCloudinary()
        }
        private func initCloudinary() {
            let config = CLDConfiguration(cloudName: cloudName, secure: true)
            cloudinary = CLDCloudinary(configuration: config)
        }

    }
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        FirebaseApp.configure()   // ✅ REQUIRED (Step 6)

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // No changes needed
    }
}
