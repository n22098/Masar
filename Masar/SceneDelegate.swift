import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private func showMainInterface() {
        let searchVC = ViewController()
        let historyVC = UIViewController()
        let messagesVC = MessagesListViewController()
        let profileVC = ProfileViewController()

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: searchVC),
            UINavigationController(rootViewController: historyVC),
            UINavigationController(rootViewController: messagesVC),
            UINavigationController(rootViewController: profileVC)
        ]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        AuthService.shared.signInIfNeeded {
            DispatchQueue.main.async {
                self.showMainInterface()
            }
        }
       
        // MARK: - Create View Controllers

        let searchVC = ViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        let historyVC = UIViewController()
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )

        let messagesVC = MessagesListViewController()
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        messagesNav.tabBarItem = UITabBarItem(
            title: "Messages",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )

        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            searchNav,
            historyNav,
            messagesNav,
            profileNav
        ]

        // MARK: - Tab Bar Appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.stackedLayoutAppearance.selected.iconColor =
            UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }

        // MARK: - Auth then show UI
        AuthService.shared.signInIfNeeded {
            DispatchQueue.main.async {
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        }
    }
}
