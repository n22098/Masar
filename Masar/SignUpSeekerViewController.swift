//
//  SignUpViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//
import FirebaseAuth
import FirebaseFirestore

import UIKit

class SignUpSeekerViewController: UIViewController {

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    // MARK: - Firestore
    let db = Firestore.firestore()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func signUpBtn(_ sender: UIButton) {
        
        // 1️⃣ Validate inputs
        guard validateInputs() else { return }

        let name = nameTextField.text!
        let email = emailTextField.text!
        let username = usernameTextField.text!
        let phone = phoneNumberTextField.text!
        let password = passwordTextField.text!

        // 2️⃣ Check if email / username / phone already exists
        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                return
            }

            // 3️⃣ Create user with Firebase Auth
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

                guard let uid = result?.user.uid else { return }

                // 4️⃣ Save user data in Firestore
                self.db.collection("users").document(uid).setData([
                    "name": name,
                    "email": email,
                    "username": username,
                    "phone": phone,
                    "uid": uid
                ]) { error in
                    if let error = error {
                        self.showAlert(error.localizedDescription)
                    } else {
                        // ✅ Success → go back to Sign In after OK
                        self.showSuccessAndGoToSignIn()
                    }
                }
            }
        }
    }

    // MARK: - Validation
    func validateInputs() -> Bool {

        if nameTextField.text?.isEmpty == true ||
            emailTextField.text?.isEmpty == true ||
            usernameTextField.text?.isEmpty == true ||
            phoneNumberTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
            confirmPasswordTextField.text?.isEmpty == true {

            showAlert("All fields are required.")
            return false
        }

        if !isValidEmail(emailTextField.text!) {
            showAlert("Please enter a valid email address.")
            return false
        }

        if !isStrongPassword(passwordTextField.text!) {
            showAlert("Password must be at least 8 characters and include uppercase, lowercase, number, and special character.")
            return false
        }

        if passwordTextField.text! != confirmPasswordTextField.text! {
            showAlert("Passwords do not match.")
            return false
        }

        return true
    }

    // MARK: - Check Existing User Data
    func checkIfUserDataExists(
        email: String,
        username: String,
        phone: String,
        completion: @escaping (Bool) -> Void
    ) {

        db.collection("users")
            .whereFilter(Filter.orFilter([
                Filter.whereField("email", isEqualTo: email),
                Filter.whereField("username", isEqualTo: username),
                Filter.whereField("phone", isEqualTo: phone)
            ]))
            .getDocuments { snapshot, error in

                if let error = error {
                    print(error.localizedDescription)
                    completion(true)
                    return
                }

                completion(!(snapshot?.documents.isEmpty ?? true))
            }
    }

    // MARK: - Success Alert + Navigation
    func showSuccessAndGoToSignIn() {

        let alert = UIAlertController(
            title: "Success",
            message: "Account created successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Return to Sign In page
            self.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Helpers

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    func isStrongPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
