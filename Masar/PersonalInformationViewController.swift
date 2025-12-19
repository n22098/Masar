//
//  PersonalInformationViewController.swift
//  Masar
//
//  Created by BP-36-201-13 on 19/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PersonalInformationViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    
    
    let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReadOnlyFields()
        fetchUserData()
    }
    func setupReadOnlyFields() {
           emailTextField.isUserInteractionEnabled = false
           usernameTextField.isUserInteractionEnabled = false
       }

       // MARK: - Fetch User Data
       // Loads current user data and fills text fields
       func fetchUserData() {

           guard let uid = uid else { return }

           db.collection("users").document(uid).getDocument { snapshot, error in

               if let error = error {
                   self.showAlert(error.localizedDescription)
                   return
               }

               guard let data = snapshot?.data() else { return }

               self.nameTextField.text = data["name"] as? String
               self.emailTextField.text = data["email"] as? String
               self.phoneNumberTextField.text = data["phone"] as? String
               self.usernameTextField.text = data["username"] as? String
           }
       }
    @IBAction func saveBtn(_ sender: UIButton) {
        
        guard let uid = uid else { return }

        // Validate editable fields only
        if nameTextField.text?.isEmpty == true ||
            phoneNumberTextField.text?.isEmpty == true {

            showAlert("Name and phone number are required.")
            return
        }

        let updatedName = nameTextField.text!
        let updatedPhone = phoneNumberTextField.text!

        // Update Firestore (ONLY name & phone)
        db.collection("users").document(uid).updateData([
            "name": updatedName,
            "phone": updatedPhone
        ]) { error in

            if let error = error {
                self.showAlert(error.localizedDescription)
            } else {
                self.showAlert("Profile updated successfully.")
            }
        }
    }

    // MARK: - Alert Helper
    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Personal Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
