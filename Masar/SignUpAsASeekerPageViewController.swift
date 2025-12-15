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

        guard
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
            let phone = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty,
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty
        else {
            showAlert(title: "Warning", message: "Please fill in all fields.")
            return
        }

        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email.")
            return
        }

        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match.")
            return
        }

        // 1) Check USERNAME unique
        db.collection("users").whereField("username", isEqualTo: username.lowercased())
            .getDocuments { snapshot, error in

                if error != nil {
                    self.showAlert(title: "Error", message: "Something went wrong.")
                    return
                }

                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.showAlert(title: "Username Taken", message: "Please choose another username.")
                    return
                }

                // 2) Check PHONE unique
                self.db.collection("users").whereField("phone", isEqualTo: phone)
                    .getDocuments { snapshot, error in

                        if error != nil {
                            self.showAlert(title: "Error", message: "Something went wrong.")
                            return
                        }

                        if let snapshot = snapshot, !snapshot.documents.isEmpty {
                            self.showAlert(title: "Phone Used", message: "Phone number already registered.")
                            return
                        }

                        // 3) Create Auth user
                        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { result, error in

                            if let error = error {
                                self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                                return
                            }

                            guard let uid = result?.user.uid else { return }

                            // 4) Save in Firestore
                            self.db.collection("users").document(uid).setData([
                                "uid": uid,
                                "name": name,
                                "email": email.lowercased(),
                                "username": username.lowercased(),
                                "phone": phone,
                                "createdAt": Timestamp()
                            ]) { error in

                                if let error = error {
                                    self.showAlert(title: "Database Error", message: error.localizedDescription)
                                    return
                                }

                                // ✅ Success: alert then back to Sign In
                                self.showSuccessAndGoBack()
                            }
                        }
                    }
            }
    }

    private func showSuccessAndGoBack() {
        let alert = UIAlertController(
            title: "Success",
            message: "Registration successful.\nTap OK to return to Sign In.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
