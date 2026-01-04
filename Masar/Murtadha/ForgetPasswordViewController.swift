// ===================================================================================
// FORGET PASSWORD VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Handles the password recovery process.
//
// KEY FEATURES:
// 1. User Interface: Professional styling with shadows, icons, and brand colors.
// 2. Validation: Ensures the email format is correct and the field is not empty.
// 3. Security Check: Verifies that the email actually exists in the database.
// 4. Firebase Auth: Sends a secure password reset link to the user's email.
// ===================================================================================

import UIKit
import FirebaseAuth      // For sending the reset email
import FirebaseFirestore // For checking if the user exists in the database

class ForgetPasswordViewController: UIViewController {

    // MARK: - Outlets
    // Connections to UI elements in the Storyboard
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var submitButtonRef: UIButton!
    
    // MARK: - Properties
    // Database reference and theme color
    let db = Firestore.firestore()
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfessionalUI() // Apply visual styling when screen loads
    }
    
    // MARK: - UI Configuration
    private func setupProfessionalUI() {
        // 1. Dismiss Keyboard Gesture
        // Allows the user to tap anywhere on the screen to close the keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // 2. Style Input Field
        // Adds icon, border, and rounded corners
        styleTextField(emailTextField, iconName: "envelope")
        
        // 3. Style Submit Button
        // Applies brand color, shadow, and rounded corners
        if let btn = submitButtonRef {
            btn.backgroundColor = brandColor
            btn.setTitle("Send Reset Link", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 12
            
            // Add Shadow
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 6
        }
        
        // 4. Logo Configuration
        if let logo = logoImageView {
            logo.contentMode = .scaleAspectFit
        }
    }
    
    // Helper method to apply consistent styling to text fields
    private func styleTextField(_ textField: UITextField, iconName: String) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        textField.textColor = .black
        textField.placeholder = "Enter your registered email"
        
        // Create Icon Container
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconImageView = UIImageView(frame: CGRect(x: 12, y: 15, width: 20, height: 20))
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)
        
        // Add Icon to Left Side
        textField.leftView = iconView
        textField.leftViewMode = .always
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Core Logic
    
    // Triggered when the user taps "Send Reset Link"
    @IBAction func submitBtn(_ sender: UIButton)  {
        
        // 1. Check for empty input
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert("Please enter your email.")
            return
        }

        // 2. Validate email format (Regex)
        if !isValidEmail(email) {
            showAlert("Please enter a valid email address.")
            return
        }

        // 3. Check Database: Does this email exist?
        checkIfEmailExists(email: email) { exists in

            if !exists {
                // Email not found in database, do not send reset link
                self.showAlert("No user found with this email.")
                return
            }

            // 4. Send Password Reset Email via Firebase Auth
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                } else {
                    self.showAlert("A password reset link has been sent to your email.")
                }
            }
        }
    }
    
    // Asynchronous check against Firestore users collection
    func checkIfEmailExists(email: String, completion: @escaping (Bool) -> Void) {
          db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in

                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }

                // If documents are found, the email exists
                completion(!(snapshot?.documents.isEmpty ?? true))
            }
      }

      // MARK: - Helper Methods

      // Regex validation for email format
      func isValidEmail(_ email: String) -> Bool {
          let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
          return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
      }

      // Displays a standard alert pop-up
      func showAlert(_ message: String) {
          let alert = UIAlertController(
              title: "Forgot Password",
              message: message,
              preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
}
