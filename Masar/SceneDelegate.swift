import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        checkPersistentLogin()
    }
    
    // ✅ تم حذف كلمة private لكي تظهر الدالة في صفحة تسجيل الدخول وتنهي الإيرور
    func navigateToDashboard(role: String) {
        DispatchQueue.main.async {
            guard let window = self.window else { return }
            
            // 🔄 الاستعادة المرنة: العودة لآخر صفحة كان فيها المستخدم
            if let savedState = AuthManager.shared.lastSavedState {
                let sb = UIStoryboard(name: savedState.sb, bundle: nil)
                if let targetVC = try? sb.instantiateViewController(withIdentifier: savedState.vc) {
                    window.rootViewController = UINavigationController(rootViewController: targetVC)
                    window.makeKeyAndVisible()
                    return
                }
            }
            
            // 🏠 المسار الافتراضي (فقط إذا لم تكن هناك صفحة محفوظة)
            let storyboardName: String
            switch role.lowercased() {
            case "admin": storyboardName = "admin"
            case "provider": storyboardName = "Provider"
            default: storyboardName = "Seeker"
            }
            
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            window.rootViewController = storyboard.instantiateInitialViewController()
            window.makeKeyAndVisible()
        }
    }

    private func checkPersistentLogin() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        let role = UserDefaults.standard.string(forKey: "userRole") ?? ""
        isLoggedIn && !role.isEmpty ? navigateToDashboard(role: role) : navigateToLogin()
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        window?.rootViewController = UINavigationController(rootViewController: loginVC)
        window?.makeKeyAndVisible()
    }

    // ✅ دالة مساعدة لحل مشكلة SignInViewController
    func navigateToStoryboard(_ storyboardName: String) {
        let role = storyboardName == "Provider" ? "provider" : (storyboardName == "admin" ? "admin" : "seeker")
        navigateToDashboard(role: role)
    }
}
