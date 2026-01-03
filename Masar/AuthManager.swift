import Foundation
import UIKit
import FirebaseAuth

/// Centralized Authentication Manager
class AuthManager {
    
    static let shared = AuthManager()
    private init() {}
    
    // MARK: - 📍 Flexible Persistence
        func saveCurrentState(storyboardName: String, viewControllerId: String) {
            UserDefaults.standard.set(storyboardName, forKey: "lastStoryboardName")
            UserDefaults.standard.set(viewControllerId, forKey: "lastViewControllerId")
            UserDefaults.standard.synchronize()
        }

        var lastSavedState: (sb: String, vc: String)? {
            guard let sb = UserDefaults.standard.string(forKey: "lastStoryboardName"),
                  let vc = UserDefaults.standard.string(forKey: "lastViewControllerId") else { return nil }
            return (sb, vc)
        }
    
    // MARK: - 🚪 Logout Function
    
    func signOut(completion: ((Bool, String?) -> Void)? = nil) {
        // مسح بيانات الدخول والحالة المحفوظة
        let keys = ["isUserLoggedIn", "userId", "userRole", "userEmail", "lastStoryboardName", "lastViewControllerId"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.synchronize()
        
        try? Auth.auth().signOut()
        navigateToLoginScreen()
        completion?(true, nil)
    }
    
    private func navigateToLoginScreen() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                let nav = UINavigationController(rootViewController: loginVC)
                nav.setNavigationBarHidden(true, animated: false)
                window.rootViewController = nav
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
    
    // MARK: - 👤 Current User Info
    var currentUserId: String? { return UserDefaults.standard.string(forKey: "userId") }
    var currentUserEmail: String? { return UserDefaults.standard.string(forKey: "userEmail") }
    var currentUserRole: String? { return UserDefaults.standard.string(forKey: "userRole") }
    var isUserLoggedIn: Bool { return UserDefaults.standard.bool(forKey: "isUserLoggedIn") }
}
