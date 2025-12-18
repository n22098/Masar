

    // MARK: - Outlets
    
    
///////
    ///////////
    //import UIKit

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct UserProfile: Codable {
    let uid: String
    let name: String
    let email: String
    let phone: String
    let username: String
    let role: String?
    
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.role = data["role"] as? String
    }
}
    class SignInPageViewController: UIViewController {
        @IBOutlet weak var usernameField: UITextField!
        @IBOutlet weak var passwordField: UITextField!
        @IBOutlet weak var signInBtn: UIButton!

        private let db = Firestore.firestore()

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        @IBAction func signInBtnTapped(_ sender: UIButton) {
            // Dismiss keyboard
            view.endEditing(true)
            
            // Gather inputs (assume usernameField is email)
            let email = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let password = passwordField.text ?? ""
            
            // Validate
            guard !email.isEmpty, !password.isEmpty else {
                showAlert(title: "Missing Information", message: "Please enter your email and password.")
                return
            }
            
            // Disable button to prevent multiple taps
            sender.isEnabled = false
            
            // Firebase Auth sign-in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    sender.isEnabled = true
                    self.showAlert(title: "Sign In Failed", message: error.localizedDescription)
                    return
                }
                
                guard let uid = result?.user.uid else {
                    sender.isEnabled = true
                    self.showAlert(title: "Sign In Failed", message: "Unable to retrieve user information.")
                    return
                }
                
                // Fetch user profile from Firestore and pass to ProfilePageViewController
                self.db.collection("users").document(uid).getDocument { snapshot, err in
                    sender.isEnabled = true
                    if let err = err {
                        self.showAlert(title: "Profile Error", message: err.localizedDescription)
                        return
                    }
                    
                    let data = snapshot?.data() ?? [:]
                    let profile = UserProfile(uid: uid, data: data)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfilePageViewController") as! ProfilePageViewController
                    profileVC.userProfile = profile
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
        
        // MARK: - Helpers
        private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
            present(ac, animated: true)
        }
    }
