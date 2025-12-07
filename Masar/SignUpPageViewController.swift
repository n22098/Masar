//
//  SignUpPageViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 07/12/2025.
//

import UIKit

// Local temporary storage (arrays must have same index)
var registeredEmails: [String] = []
var registeredUsernames: [String] = []
var registeredPasswords: [String] = []   // <<< IMPORTANT

class SignUpPageViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    // MARK: - Sign Up Action
    @IBAction func signUpBtn(_ sender: UIButton) {
        validateForm()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide password
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        
        // Show/Hide eye
        enablePasswordToggle(passwordField)
        enablePasswordToggle(confirmPasswordField)
        
        // Keyboard types
        setupKeyboardTypes()
        
        // Delegates
        nameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        // Tap outside to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Hide keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Keyboard Types
    func setupKeyboardTypes() {
        nameField.keyboardType = .default
        
        usernameField.keyboardType = .default
        usernameField.autocorrectionType = .no
        
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        
        passwordField.autocorrectionType = .no
        confirmPasswordField.autocorrectionType = .no
    }
    
    
    // MARK: - Validation Logic
    func validateForm() {
        
        // Name
        if nameField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            showAlert(msg: "You left the name field empty.")
            return
        }
        if !isValidName(nameField.text!) {
            showAlert(msg: "Name must contain letters only.")
            return
        }
        
        // Username
        if usernameField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            showAlert(msg: "You left the username field empty.")
            return
        }
        if !isValidUsername(usernameField.text!) {
            showAlert(msg: "Username must contain letters/numbers only with no spaces.")
            return
        }
        
        let newUsername = usernameField.text!.lowercased()
        if registeredUsernames.contains(newUsername) {
            showAlert(msg: "This username is already taken.")
            return
        }
        
        // Email
        if emailField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            showAlert(msg: "You left the email field empty.")
            return
        }
        if !isValidEmail(emailField.text!) {
            showAlert(msg: "Invalid email format.")
            return
        }
        
        let newEmail = emailField.text!.lowercased()
        if registeredEmails.contains(newEmail) {
            showAlert(msg: "This email is already registered.")
            return
        }
        
        // Password
        if passwordField.text!.isEmpty {
            showAlert(msg: "You left the password field empty.")
            return
        }
        if !isValidPassword(passwordField.text!) {
            showAlert(msg: "Password must be at least 8 characters, include uppercase, lowercase & number.")
            return
        }
        
        // Confirm Password
        if confirmPasswordField.text!.isEmpty {
            showAlert(msg: "You left the confirm password field empty.")
            return
        }
        if confirmPasswordField.text! != passwordField.text! {
            showAlert(msg: "Passwords do not match.")
            return
        }
        
        
        // ---------------------------------
        // SUCCESS — Save into arrays
        // Same index = same user
        // ---------------------------------
        
        registeredUsernames.append(newUsername)
        registeredEmails.append(newEmail)
        registeredPasswords.append(passwordField.text!)  // <<< HERE
        
        showAlert(msg: "Registration Successful!")
        
        // TODO: go to sign in page
        // performSegue(withIdentifier: "goToSignIn", sender: self)
    }
    
    
    // MARK: - Toggle Eye Icon
    func enablePasswordToggle(_ textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)),
                         for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        
        button.tag = (textField == passwordField) ? 1 : 2
    }
    
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        if sender.tag == 1 {
            passwordField.isSecureTextEntry.toggle()
            let icon = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: icon), for: .normal)
        } else {
            confirmPasswordField.isSecureTextEntry.toggle()
            let icon = confirmPasswordField.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: icon), for: .normal)
        }
    }
    
    
    // MARK: - Alert Helper
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Warning",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - Validation Helpers
    func isValidName(_ name: String) -> Bool {
        let regex = "^[A-Za-z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: name)
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let regex = "^[A-Za-z0-9]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: username)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: password)
    }
    
    
    // MARK: - Move Between Fields Using "Next"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            usernameField.becomeFirstResponder()
        } else if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            validateForm()
        }
        return true
    }
}
