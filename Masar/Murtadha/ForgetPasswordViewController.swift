//
//  ForgetPasswordViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    // 👇 عناصر جديدة للتصميم (اربطهم في الستوري بورد)
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var submitButtonRef: UIButton!
    
    let db = Firestore.firestore()
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfessionalUI()
    }
    
    // MARK: - 🎨 UI Setup
    private func setupProfessionalUI() {
        // 1. إخفاء الكيبورد عند اللمس
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // 2. تصميم الحقل
        styleTextField(emailTextField, iconName: "envelope")
        
        // 3. تصميم الزر
        if let btn = submitButtonRef {
            btn.backgroundColor = brandColor
            btn.setTitle("Send Reset Link", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 12
            // ظل
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 6
        }
        
        // 4. تصميم الشعار
        if let logo = logoImageView {
            logo.contentMode = .scaleAspectFit
        }
    }
    
    // دالة مساعدة لتصميم الحقل (نفس تصميم الصفحات السابقة)
    private func styleTextField(_ textField: UITextField, iconName: String) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        textField.textColor = .black
        textField.placeholder = "Enter your registered email"
        
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconImageView = UIImageView(frame: CGRect(x: 12, y: 15, width: 20, height: 20))
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)
        
        textField.leftView = iconView
        textField.leftViewMode = .always
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Logic (لم يتغير)
    
    @IBAction func submitBtn(_ sender: UIButton)  {
        
        // Check empty email
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert("Please enter your email.")
            return
        }

        // Validate email format
        if !isValidEmail(email) {
            showAlert("Please enter a valid email address.")
            return
        }

        // Step 1: Check if email exists in Firestore
        checkIfEmailExists(email: email) { exists in

            if !exists {
                // Email not found in database
                self.showAlert("No user found with this email.")
                return
            }

            // Step 2: Send reset password email
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                } else {
                    self.showAlert("A password reset link has been sent to your email.")
                }
            }
        }
    }
    
    func checkIfEmailExists(email: String, completion: @escaping (Bool) -> Void) {

          db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in

                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }

                completion(!(snapshot?.documents.isEmpty ?? true))
            }
      }

      // MARK: - Helpers

      func isValidEmail(_ email: String) -> Bool {
          let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
          return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
      }

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
