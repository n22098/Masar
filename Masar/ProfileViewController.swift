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
            withIdentifier: "PersonalInfoViewController"
        )
        self.navigationController?.pushViewController(personalInfoVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {

            // Confirmation alert
            let alert = UIAlertController(
                title: "Log Out",
                message: "Do you want to log out?",
                preferredStyle: .alert
            )

            // Stay on profile page
            alert.addAction(UIAlertAction(title: "No", style: .cancel))

            // Log out and go to Sign In page
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                do {
                    try Auth.auth().signOut()
                    self.navigateToSignIn()
                } catch {
                    self.showAlert("Failed to log out. Please try again.")
                }
            })

            present(alert, animated: true)
        }

        // MARK: - Navigation
        func navigateToSignIn() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(
                withIdentifier: "SignInViewController"
            )
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true)
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
