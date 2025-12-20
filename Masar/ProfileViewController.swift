//
//  ProfileViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//
import FirebaseAuth

import UIKit

class ProfileViewController: UIViewController {

    @IBAction func resetPsswordBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resetVC = storyboard.instantiateViewController(
            withIdentifier: "ResetPasswordViewController"
        )
        self.navigationController?.pushViewController(resetVC, animated: true)
    }
    
    @IBAction func personalInfoBtn(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let personalInfoVC = storyboard.instantiateViewController(
            withIdentifier: "PersonalInformationViewController"
        )
        self.navigationController?.pushViewController(personalInfoVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutBtn(_ sender: UIButton){
        
        let alert = UIAlertController(
            title: "Log Out",
            message: "Do you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                self.goToSignIn()
            } catch {
                self.showAlert("Failed to log out. Please try again.")
            }
        })

        present(alert, animated: true)
    }

    // MARK: - Navigation to Sign In (Root change)
    func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(
            withIdentifier: "SignInViewController"
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            window.rootViewController = signInVC
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Alert Helper
    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Profile",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
