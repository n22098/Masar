//
//  SceneDelegate.swift
//  Masar
//
//  Created by BP-36-201-13 on 04/12/2025.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

var window: UIWindow?

func scene(_ scene: UIScene,
willConnectTo session: UISceneSession,
options connectionOptions: UIScene.ConnectionOptions) {

guard let _ = (scene as? UIWindowScene) else { return }

// 🔵 Global Navigation Bar Appearance
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()

appearance.backgroundColor = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1)


appearance.largeTitleTextAttributes = [
.foregroundColor: UIColor.white
]

UINavigationBar.appearance().standardAppearance = appearance
UINavigationBar.appearance().scrollEdgeAppearance = appearance
UINavigationBar.appearance().compactAppearance = appearance

UINavigationBar.appearance().tintColor = .white

}

func sceneDidDisconnect(_ scene: UIScene) { }
func sceneDidBecomeActive(_ scene: UIScene) { }
func sceneWillResignActive(_ scene: UIScene) { }
func sceneWillEnterForeground(_ scene: UIScene) { }
func sceneDidEnterBackground(_ scene: UIScene) { }
}
