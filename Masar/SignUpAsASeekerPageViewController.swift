//
//  SignUpAsASeekerPageViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 14/12/2025.
//



    import UIKit
import FirebaseAuth
import FirebaseFirestore

    class SignUpAsASeekerPageViewController: UIViewController {

        // MARK: - Outlets
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
        private func showSuccessAndGoBack() {

            DispatchQueue.main.async {

                let alert = UIAlertController(
                    title: "Warning",
                    message: "Registration successful.\nTap OK to return to the Sign In page.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true)
                })

                self.present(alert, animated: true)
            }
        }


            // MARK: - Actions
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

                guard password == confirmPassword else {
                    showAlert(title: "Error", message: "Passwords do not match.")
                    return
                }

                // 🔍 1️⃣ Check USERNAME uniqueness
                db.collection("users")
                    .whereField("username", isEqualTo: username.lowercased())
                    .getDocuments { snapshot, error in

                        if let _ = error {
                            self.showAlert(title: "Error", message: "Something went wrong.")
                            return
                        }

                        if let snapshot = snapshot, !snapshot.documents.isEmpty {
                            self.showAlert(title: "Username Taken", message: "Please choose another username.")
                            return
                        }

                        // 🔍 2️⃣ Check PHONE uniqueness
                        self.db.collection("users")
                            .whereField("phone", isEqualTo: phone)
                            .getDocuments { snapshot, error in

                                if let _ = error {
                                    self.showAlert(title: "Error", message: "Something went wrong.")
                                    return
                                }

                                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                                    self.showAlert(title: "Phone Used", message: "Phone number already registered.")
                                    return
                                }

                                // ✅ 3️⃣ Create user in Firebase Auth
                                Auth.auth().createUser(withEmail: email, password: password) { result, error in

                                    if let error = error {
                                        self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                                        return
                                    }

                                    guard let uid = result?.user.uid else { return }

                                    // 💾 4️⃣ Save data in Firestore
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

                                        //  Success → Alert → Back to Sign In
                                    }
                                    
                                    self.showSuccessAndGoBack()

                                }
                            }
                    }
            }

            // MARK: - Success Alert + Navigation
        // MARK: - Success Alert + Navigation
        // MARK: - Success Alert + Navigation
        // MARK: - Warning Alert + Navigation




            // MARK: - Alert Helper
            private func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
