//
//  ForgetPasswordViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

import UIKit

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
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
