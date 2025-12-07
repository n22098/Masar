//
//  SignUpPageViewController.swift
//  Masar
//

import UIKit

// Temporary local storage (simulate database)
var registeredNames: [String] = []
var registeredUsernames: [String] = []
var registeredEmails: [String] = []
var registeredPhones: [String] = []
var registeredPasswords: [String] = []

class SignUpPageViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    
    // MARK: - Sign Up Button
    @IBAction func signUpBtn(_ sender: UIButton) {
        validateForm()
    }
    ///////////////////////////////////////////////ffffff
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // secure password
        passwordField.isSecureTextEntry = true
        confirmPasswordField.isSecureTextEntry = true
        
        enablePasswordToggle(passwordField)
        enablePasswordToggle(confirmPasswordField)
        
        setupKeyboardTypes()
        setupDelegates()
        
        // Close keyboard on tap
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(dismissKeyboard)))
    }
    
    
    // MARK: - Setup
    func setupDelegates() {
        nameField.delegate = self
        usernameField.delegate = self
        emailField.delegate = self
        phoneNumberField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    func setupKeyboardTypes() {
        nameField.keyboardType = .default
        
        usernameField.autocorrectionType = .no
        usernameField.autocapitalizationType = .none
        
        emailField.keyboardType = .emailAddress
        
        phoneNumberField.keyboardType = .numberPad
        
        passwordField.autocorrectionType = .no
        confirmPasswordField.autocorrectionType = .no
    }
    
    
    // MARK: - Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Validation
    func validateForm() {
        
        guard let name = nameField.text?.trimmingCharacters(in: .whitespaces),
              !name.isEmpty else {
            return showAlert(msg: "Name is empty!")
        }
        guard isValidName(name) else {
            return showAlert(msg: "Name must contain letters only.")
        }
        
        guard let username = usernameField.text?.lowercased(),
              !username.isEmpty else {
            return showAlert(msg: "Username is empty!")
        }
        guard isValidUsername(username) else {
            return showAlert(msg: "Username must contain letters/numbers only.")
        }
        guard !registeredUsernames.contains(username) else {
            return showAlert(msg: "Username already exists.")
        }
        
        guard let email = emailField.text?.lowercased(),
              !email.isEmpty else {
            return showAlert(msg: "Email is empty!")
        }
        guard isValidEmail(email) else {
            return showAlert(msg: "Invalid email format.")
        }
        guard !registeredEmails.contains(email) else {
            return showAlert(msg: "Email already exists.")
        }
        
        guard let phone = phoneNumberField.text,
              !phone.isEmpty else {
            return showAlert(msg: "Phone is empty!")
        }
        guard isValidPhone(phone) else {
            return showAlert(msg: "Phone must be 8 digits.")
        }
        guard !registeredPhones.contains(phone) else {
            return showAlert(msg: "Phone already used.")
        }
        
        guard let pass = passwordField.text,
              !pass.isEmpty else {
            return showAlert(msg: "Password is empty!")
        }
        guard isValidPassword(pass) else {
            return showAlert(msg: "Password must be at least 8 chars including upper/lower/number.")
        }
        
        guard let confirm = confirmPasswordField.text,
              !confirm.isEmpty else {
            return showAlert(msg: "Confirm password is empty!")
        }
        guard confirm == pass else {
            return showAlert(msg: "Passwords don't match.")
        }
        
        
        // MARK: - Save user
        registeredNames.append(name)
        registeredUsernames.append(username)
        registeredEmails.append(email)
        registeredPhones.append(phone)
        registeredPasswords.append(pass)
        
        showAlert(msg: "Registered Successfully!")
        clearFields()
    }
    
    
    // MARK: - Clear after success
    func clearFields() {
        nameField.text = ""
        usernameField.text = ""
        emailField.text = ""
        phoneNumberField.text = ""
        passwordField.text = ""
        confirmPasswordField.text = ""
    }
    
    
    // MARK: - Eye Toggle
    func enablePasswordToggle(_ textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.addTarget(self,
                         action: #selector(togglePassword(_:)),
                         for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
    }
    
    @objc func togglePassword(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        confirmPasswordField.isSecureTextEntry.toggle()
        
        let icon = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    
    // MARK: - Alerts
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
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: name)
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let regex = "^[A-Za-z0-9]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let regex = "^[0-9]{8}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    
    // MARK: - Return Key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            usernameField.becomeFirstResponder()
        case usernameField:
            emailField.becomeFirstResponder()
        case emailField:
            phoneNumberField.becomeFirstResponder()
        case phoneNumberField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            validateForm()
        }
        return true
    }
}
