import UIKit
import FirebaseAuth
import FirebaseFirestore

/// SceneDelegate: Manages the lifecycle of the app's window and its initial state.
/// OOD Principle: Routing/Coordination - This class decides which Storyboard to load
/// based on the user's authentication state and role.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Called when a new scene is being added to the app.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Ensure the scene is a UIWindowScene
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Manual Window Setup (Encapsulation)
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Start the logic to check if the user is already logged in
        checkPersistentLogin()
    }
    
    /// navigateToDashboard: Switches the entire app flow based on user role (Admin, Provider, Seeker).
    /// OOD Note: By changing the 'rootViewController', we clear the previous navigation stack from memory.
    func navigateToDashboard(role: String) {
        DispatchQueue.main.async {
            guard let window = self.window else { return }
            
            // 🔄 Flexible Recovery: OOD State Restoration
            // If the user was on a specific page before the app closed, return them there.
            if let savedState = AuthManager.shared.lastSavedState {
                let sb = UIStoryboard(name: savedState.sb, bundle: nil)
                if let targetVC = try? sb.instantiateViewController(withIdentifier: savedState.vc) {
                    // Wrap in a Navigation Controller to allow further navigation
                    window.rootViewController = UINavigationController(rootViewController: targetVC)
                    window.makeKeyAndVisible()
                    return
                }
            }
            
            // 🏠 Default Path Logic: Polymorphism based on User Roles
            let storyboardName: String
            switch role.lowercased() {
            case "admin":
                storyboardName = "admin"
            case "provider":
                storyboardName = "Provider"
            default:
                storyboardName = "Seeker"
            }
            
            // Instantiate the correct Storyboard and make it the primary view
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()
            window.makeKeyAndVisible()
        }
    }

    /// checkPersistentLogin: Checks local storage (UserDefaults) to see if a session exists.
    /// This prevents the user from having to log in every single time they open the app.
    private func checkPersistentLogin() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        let role = UserDefaults.standard.string(forKey: "userRole") ?? ""
        
        // Ternary operator for clean decision making
        isLoggedIn && !role.isEmpty ? navigateToDashboard(role: role) : navigateToLogin()
    }

    /// navigateToLogin: Sets the root view to the Sign-In screen.
    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        window?.rootViewController = UINavigationController(rootViewController: loginVC)
        window?.makeKeyAndVisible()
    }

    /// Helper function to translate Storyboard names into roles for navigation.
    /// OOD Principle: Abstraction - Simplifies the call from other controllers.
    func navigateToStoryboard(_ storyboardName: String) {
        let role = storyboardName == "Provider" ? "provider" : (storyboardName == "admin" ? "admin" : "seeker")
        navigateToDashboard(role: role)
    }
}
