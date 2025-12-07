//
//  SignInPageViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 07/12/2025.
//

import UIKit

class SignInPageViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!  // username OR email
    @IBOutlet weak var passwordField: UITextField!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Keyboard settings
        setupKeyboard()
        
        // Hide password
        passwordField.isSecureTextEntry = true
        
        // Eye toggle
        enablePasswordToggle(passwordField)
        
        // delegates
        usernameField.delegate = self
        passwordField.delegate = self
        
        // tap dismiss
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    // MARK: - Keyboard
    func setupKeyboard() {
        usernameField.keyboardType = .default
        usernameField.autocorrectionType = .no
        usernameField.autocapitalizationType = .none
        usernameField.textContentType = .username
        
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.textContentType = .password
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    // MARK: - Sign In Logic
    @IBAction func signInBtn(_ sender: UIButton) {
        
        let loginUser = usernameField.text!.lowercased()
        let loginPass = passwordField.text!
        
        // Empty fields
        if loginUser.isEmpty {
            showAlert(msg: "Please enter your email or username.")
            return
        }
        
        if loginPass.isEmpty {
            showAlert(msg: "Please enter your password.")
            return
        }
        
        // Search for username or email
        var index: Int? = nil
        
        // Try username
        if let found = registeredUsernames.firstIndex(of: loginUser) {
            index = found
        }
        // Try email
        else if let found = registeredEmails.firstIndex(of: loginUser) {
            index = found
        }
        
        // if no index → user not found
        guard let foundIndex = index else {
            showAlert(msg: "Account not found.")
            return
        }
        
        // Password check
        if registeredPasswords[foundIndex] != loginPass {
            showAlert(msg: "Wrong password.")
            return
        }
        
        // SUCCESS
        showAlert(msg: "Sign In Successful!")
        
        // TODO: navigate to next page
        // performSegue(withIdentifier: "goToHome", sender: self)
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
        let icon = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    
    // MARK: - Alert Helper
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Warning", message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)
    }
    
    
    // MARK: - Next Button on Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInBtn(UIButton())  // call login
        }
        return true
    }
}
