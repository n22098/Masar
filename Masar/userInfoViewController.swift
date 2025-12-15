//
//  userInfoViewController.swift
//  Masar
//


        //
        //  userInfoViewController.swift
        //  Masar
        //
        //  Created by BP-36-201-10 on 15/12/2025.
        //

        import UIKit
        import FirebaseAuth
        import FirebaseFirestore

        class userInfoViewController: UIViewController {

            // MARK: - Outlets
          
            @IBOutlet weak var saveBtn: UIBarButtonItem!
            @IBOutlet weak var usernameTextField: UITextField!
            @IBOutlet weak var phoneNumberTextField: UITextField!
            @IBOutlet weak var emailTextField: UITextField!
            @IBOutlet weak var nameTextField: UITextField!
            
            // MARK: - Properties
            private let db = Firestore.firestore()

            // MARK: - Lifecycle
            override func viewDidLoad() {
                super.viewDidLoad()
                loadUserData()
            }

            // MARK: - Load User Data
            private func loadUserData() {

                guard let uid = Auth.auth().currentUser?.uid else {
                    print("❌ No logged-in user")
                    return
                }

                db.collection("users").document(uid).getDocument { snapshot, error in

                    if let error = error {
                        print("❌ Error fetching user:", error.localizedDescription)
                        return
                    }

                    guard let data = snapshot?.data() else {
                        print("❌ No user data found")
                        return
                    }

                    DispatchQueue.main.async {
                        self.nameTextField.text = data["name"] as? String
                        self.emailTextField.text = data["email"] as? String
                        self.phoneNumberTextField.text = data["phone"] as? String
                        self.usernameTextField.text = data["username"] as? String
                    }
                }
            }
        }
