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
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let searchVC = UIViewController()
        searchVC.view.backgroundColor = .systemBackground
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 0
        )

        let historyVC = UIViewController()
        historyVC.view.backgroundColor = .systemBackground
        historyVC.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "clock.arrow.circlepath"),
            tag: 1
        )

        let messagesListVC = MessagesListViewController()
        let messagesNav = UINavigationController(rootViewController: messagesListVC)
        messagesNav.setNavigationBarHidden(true, animated: false)
        messagesNav.tabBarItem = UITabBarItem(
            title: "Messages",
            image: UIImage(systemName: "ellipsis.bubble"),
            tag: 2
        )

        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            tag: 3
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [searchVC, historyVC, messagesNav, profileVC]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
