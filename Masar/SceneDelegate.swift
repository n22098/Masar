//
//  SceneDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 05/12/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    )
    {
        
        AuthService.shared.signInIfNeeded {
            print("Signed in with uid:", AuthService.shared.currentUserId ?? "")
        }

        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        let searchVC = ViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)

        let historyVC = UIViewController()
        let historyNav = UINavigationController(rootViewController: historyVC)
        historyNav.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock"), selectedImage: nil)

        let messagesVC = MessagesListViewController()
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        messagesNav.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), selectedImage: nil)

        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        let providerHubVC = UIViewController()
        let providerHubNav = UINavigationController(rootViewController: providerHubVC)
        providerHubNav.tabBarItem = UITabBarItem(
            title: "Provider Hub",
            image: UIImage(systemName: "briefcase"),
            selectedImage: UIImage(systemName: "briefcase.fill")
        )
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        historyNav.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )

        messagesNav.tabBarItem = UITabBarItem(
            title: "Messages",
            image: UIImage(systemName: "message"),
            selectedImage: UIImage(systemName: "message.fill")
        )

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
            providerHubNav,
            profileNav
        ]
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

        // Remove top shadow line
        appearance.shadowColor = nil

        let tabBar = tabBarController.tabBar
        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }


        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}
