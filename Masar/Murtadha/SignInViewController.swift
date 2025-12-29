//
//  SignInViewController.swift
//  Masar
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the eye icon for the password field
        setupPasswordToggle(for: passwordTextField)
    }

    @IBAction func SignInBtn(_ sender: UIButton) {

        // 1️⃣ Validate inputs
        guard
            let input = usernameTextField.text, !input.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            showAlert("Please enter your email/username and password.")
            return
        }

        // 2️⃣ Decide login type
        if isValidEmail(input) {
            signInWithEmail(email: input, password: password)
        } else {
            signInWithUsername(username: input, password: password)
        }
    }

    // MARK: - Password Visibility Logic
    
    private func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        
        // Using SF Symbols for the eye
        let eyeImage = UIImage(systemName: "eye.slash")
        let eyeOpenImage = UIImage(systemName: "eye")
        
        button.setImage(eyeImage, for: .normal)
        button.setImage(eyeOpenImage, for: .selected)
        button.tintColor = .systemGray
        
        // Frame and Padding inside the text field
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true // Hidden by default
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if let textField = sender.superview as? UITextField {
            textField.isSecureTextEntry.toggle()
            
            // Fix to prevent cursor jumping or font reset
            if let text = textField.text {
                textField.text = nil
                textField.text = text
            }
        }
    }

    // MARK: - Sign In With Email
    func signInWithEmail(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error as NSError? {

                guard let code = AuthErrorCode(rawValue: error.code) else {
                    self.showAlert("Something went wrong. Please try again.")
                    return
                }

                switch code {
                case .userNotFound:
                    self.showAlert("Email is not registered.")
                case .wrongPassword:
                    self.showAlert("Incorrect password.")
                case .invalidEmail:
                    self.showAlert("Invalid email format.")
                default:
                    self.showAlert("Login failed. Please try again.")
                }
                return
            }

            self.navigateToProfile()
        }
    }

    // MARK: - Sign In With Username
    func signInWithUsername(username: String, password: String) {

        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in

                if let _ = error {
                    self.showAlert("Something went wrong. Please try again.")
                    return
                }

                guard
                    let document = snapshot?.documents.first,
                    let email = document.data()["email"] as? String
                else {
                    self.showAlert("Username not found.")
                    return
                }

                Auth.auth().signIn(withEmail: email, password: password) { _, error in
                    if let error = error as NSError? {

                        guard let code = AuthErrorCode(rawValue: error.code) else {
                            self.showAlert("Login failed.")
                            return
                        }

                        switch code {
                        case .wrongPassword:
                            self.showAlert("Incorrect password.")
                        default:
                            self.showAlert("Login failed. Please try again.")
                        }
                        return
                    }

                    self.navigateToProfile()
                }
            }
    }

    // MARK: - Navigation
    func navigateToProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(
            withIdentifier: "ProfileTableViewController"
        )

        profileVC.modalPresentationStyle = .fullScreen
        present(profileVC, animated: true)
    }

    // MARK: - Helpers
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Sign In",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
