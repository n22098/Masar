//
//  SignInViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//
import FirebaseAuth
import FirebaseFirestore

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func SignInBtn(_ sender: UIButton) {
        
        // Step 1: Validate inputs
        if usernameTextField.text?.isEmpty == true || passwordTextField.text?.isEmpty == true {
            showAlert("Please enter your email/username and password.")
            return
        }

        let input = usernameTextField.text!
        let password = passwordTextField.text!

        // Step 2: Check if input is an email
        if isValidEmail(input) {
            signInWithEmail(email: input, password: password)
        } else {
            signInWithUsername(username: input, password: password)
        }
    }

    // MARK: - Firebase Sign In (Email)
    func signInWithEmail(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(error.localizedDescription)
                return
            }

            // Navigate to Profile page after successful login
            self.navigateToProfile()
        }
    }

    // MARK: - Firebase Sign In (Username)
    // This function finds the email related to the username, then logs in
    func signInWithUsername(username: String, password: String) {

        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in

                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

                guard let document = snapshot?.documents.first,
                      let email = document.data()["email"] as? String else {
                    self.showAlert("Username not found.")
                    return
                }

                // Login using the retrieved email
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        self.showAlert("Incorrect password.")
                        return
                    }

                    self.navigateToProfile()
                }
            }
    }

    // MARK: - Navigation
    func navigateToProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController")
        profileVC.modalPresentationStyle = .fullScreen
        self.present(profileVC, animated: true)
    }

    // MARK: - Helpers

    // Email format validation
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    // Show alert message
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Sign In", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
