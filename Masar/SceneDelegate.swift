import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

var window: UIWindow?

<<<<<<< HEAD
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        // 🔵 Global Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1)

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

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
=======
func scene(_ scene: UIScene,
willConnectTo session: UISceneSession,
options connectionOptions: UIScene.ConnectionOptions) {

guard let _ = (scene as? UIWindowScene) else { return }

// 🔵 Global Navigation Bar Appearance
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()

appearance.backgroundColor = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1)

appearance.titleTextAttributes = [
.foregroundColor: UIColor.white
]

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
>>>>>>> fa754bb3a27e79a75e127c4fc270122daa250b0b
