//
//  ResetPasswordViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//
import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
    @IBAction func resetPasswordBtn(_ sender: UIButton){
        
        // Validate empty fields
        if currentPasswordTextField.text?.isEmpty == true ||
            newPasswordTextField.text?.isEmpty == true ||
            confirmPasswordTextField.text?.isEmpty == true {

            showAlert("All fields are required.")
            return
        }

        let currentPassword = currentPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let confirmPassword = confirmPasswordTextField.text!

        // Check new password match
        if newPassword != confirmPassword {
            showAlert("New passwords do not match.")
            return
        }

        // Validate password strength
        if !isStrongPassword(newPassword) {
            showAlert("Password must be at least 8 characters and include uppercase, lowercase, number, and special character.")
            return
        }

        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            showAlert("User not authenticated.")
            return
        }

        // Re-authenticate user
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: currentPassword
        )

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                self.showAlert("Current password is incorrect.")
                return
            }

            // Update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                } else {
                    self.showAlert("Password updated successfully.")
                }
            }
        }
    }

    // MARK: - Helpers

    func isStrongPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Reset Password",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
