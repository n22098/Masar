import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // ✅ تحميل تفضيلات Dark Mode عند فتح التطبيق
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light

        // ✅ تطبيق اتجاه الواجهة حسب اللغة (RTL للعربي، LTR للإنجليزي)
        if let language = UserDefaults.standard.string(forKey: "appLanguage") {
            if language == "ar" {
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
                UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
            } else {
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
                UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
            }
        }

        // ✅ تحميل صفحة تسجيل الدخول من الستوري بورد
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        
        let nav = UINavigationController(rootViewController: signInVC)
        nav.setNavigationBarHidden(true, animated: false)

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    // ✅ دالة الانتقال للصفحة الرئيسية (بعد تسجيل الدخول)
    func showMainTabBar() {
        guard let window = self.window else { return }
        
        let tabBar = makeMainTabBarController()
        
        // تطبيق Dark Mode على الشاشة الجديدة
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBar
        }, completion: nil)
    }

    // ✅ دالة لتبديل الشاشات بين Seeker و Provider
    func navigateToStoryboard(_ storyboardName: String) {
        guard let window = self.window else { return }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let mainVC = storyboard.instantiateInitialViewController() {
            // تطبيق Dark Mode على الشاشة الجديدة
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainVC
            }, completion: nil)
        } else {
            print("❌ خطأ: لم يتم العثور على Initial View Controller في \(storyboardName).storyboard")
        }
    }

    // MARK: - Main Tab Bar Construction
    private func makeMainTabBarController() -> UITabBarController {

        // Search
        let searchVC = UIViewController()
        searchVC.view.backgroundColor = .systemBackground
        searchVC.title = NSLocalizedString("Search", comment: "")
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Search", comment: ""),
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        // History
        let historyVC = UIViewController()
        historyVC.view.backgroundColor = .systemBackground
        historyVC.title = NSLocalizedString("History", comment: "")
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("History", comment: ""),
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )

        // Messages
        let messagesVC = UIViewController()
        messagesVC.view.backgroundColor = .systemBackground
        messagesVC.title = NSLocalizedString("Messages", comment: "")
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        messagesNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Messages", comment: ""),
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )

        // Profile - تحميل من الستوري بورد
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Profile", comment: ""),
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let tabBar = UITabBarController()
        tabBar.viewControllers = [searchNav, historyNav, messagesNav, profileNav]
        
        // لون التحديد (بنفسجي)
        tabBar.tabBar.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

        return tabBar
    }
    
    // MARK: - Scene Lifecycle
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // ✅ تحميل Dark Mode عند الرجوع للتطبيق (على جميع النوافذ)
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}
