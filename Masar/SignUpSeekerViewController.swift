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
    
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpBtn(_ sender: UIButton) {
        
        // Step 1: Validate inputs
        guard validateInputs() else { return }

        let name = nameTextField.text!
        let email = emailTextField.text!
        let username = usernameTextField.text!
        let phone = phoneNumberTextField.text!
        let password = passwordTextField.text!

        // Step 2: Check if username or phone already exists
        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                return
            }

            // Step 3: Create user with Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

                guard let uid = result?.user.uid else { return }

                // Step 4: Save user data in Firestore
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
                        self.showAlert("Account created successfully.")
                    }
                }
            }
        }
    }

    // MARK: - Validation
    // This function validates all text fields and password policy
    func validateInputs() -> Bool {

        // Check empty fields
        if nameTextField.text?.isEmpty == true ||
            emailTextField.text?.isEmpty == true ||
            usernameTextField.text?.isEmpty == true ||
            phoneNumberTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
            confirmPasswordTextField.text?.isEmpty == true {

            showAlert("All fields are required.")
            return false
        }

        // Validate email format
        if !isValidEmail(emailTextField.text!) {
            showAlert("Please enter a valid email address.")
            return false
        }

        // Validate password strength
        if !isStrongPassword(passwordTextField.text!) {
            showAlert("Password must be at least 8 characters, include uppercase, lowercase, number, and special character.")
            return false
        }

        // Check password match
        if passwordTextField.text! != confirmPasswordTextField.text! {
            showAlert("Passwords do not match.")
            return false
        }

        return true
    }

    // MARK: - Firebase Checks
    // Check if email, username, or phone already exists in Firestore
    func checkIfUserDataExists(email: String, username: String, phone: String, completion: @escaping (Bool) -> Void) {

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

    // MARK: - Helpers

    // Email validation using regex
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    // Strong password validation
    func isStrongPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // Show alert message
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


