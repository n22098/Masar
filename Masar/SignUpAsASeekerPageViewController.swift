//
//  SignUpAsASeekerPageViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 14/12/2025.
//





        // MARK: - Outlets
      

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpAsASeekerPageViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!


    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    @IBAction func signUpBtn(_ sender: UIButton) {

        view.endEditing(true)
        
        // Gather inputs
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        // Validate
        guard !name.isEmpty,
              !email.isEmpty,
              !phone.isEmpty,
              !username.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields.")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Password Mismatch", message: "Password and Confirm Password do not match.")
            return
        }
        
        // Create account with Firebase Auth
        sender.isEnabled = false
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                sender.isEnabled = true
                self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else {
                sender.isEnabled = true
                self.showAlert(title: "Sign Up Failed", message: "Unable to retrieve user information.")
                return
            }
            
            // Prepare user data to match userInfoViewController expectations
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "phone": phone,
                "username": username,
                "createdAt": FieldValue.serverTimestamp(),
                "role": "seeker"
            ]
            
            // Save to Firestore in "users" collection with document ID = uid
            self.db.collection("users").document(uid).setData(userData) { err in
                sender.isEnabled = true
                if let err = err {
                    self.showAlert(title: "Error Saving Profile", message: err.localizedDescription)
                    return
                }
                
                // Success
                self.showAlert(title: "Welcome", message: "Your account has been created.") { _ in
                    // Default action: dismiss or pop
                    if self.presentingViewController != nil {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(ac, animated: true)
    }
}
