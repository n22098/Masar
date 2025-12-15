

    // MARK: - Outlets
    
    
///////
    ///////////
    //import UIKit


 

    import UIKit
    import FirebaseAuth
    import FirebaseFirestore

    class SignInPageViewController: UIViewController {
        @IBOutlet weak var usernameField: UITextField!
        @IBOutlet weak var passwordField: UITextField!
        @IBOutlet weak var signInBtn: UIButton!

        private let db = Firestore.firestore()

        override func viewDidLoad() {
            super.viewDidLoad()
            passwordField.isSecureTextEntry = true
        }

        @IBAction func signInBtnTapped(_ sender: UIButton) {

            guard
                let input = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !input.isEmpty,
                let password = passwordField.text,
                !password.isEmpty
            else {
                showAlert(title: "Warning", message: "Please fill in all fields.")
                return
            }

            if input.contains("@") {
                // 📧 Email login
                signInWithEmail(email: input, password: password)
            } else {
                // 👤 Username login
                signInWithUsername(username: input.lowercased(), password: password)
            }
        }

        // MARK: - Email Login
        private func signInWithEmail(email: String, password: String) {
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let _ = error {
                    self.showAlert(title: "Login Failed", message: "Invalid email or password.")
                    return
                }
                self.goToProfilePage()
            }
        }

        // MARK: - Username Login
        private func signInWithUsername(username: String, password: String) {
            db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments { snapshot, error in

                    if let _ = error {
                        self.showAlert(title: "Error", message: "Something went wrong.")
                        return
                    }

                    guard
                        let document = snapshot?.documents.first,
                        let email = document["email"] as? String
                    else {
                        self.showAlert(title: "Login Failed", message: "Username not found.")
                        return
                    }

                    self.signInWithEmail(email: email, password: password)
                }
        }

        // MARK: - Navigation
        private func goToProfilePage() {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToProfile", sender: self)
            }
        }

        // MARK: - Alert
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
