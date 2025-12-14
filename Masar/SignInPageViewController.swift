import UIKit
import FirebaseAuth

class SignInPageViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
    }

    // MARK: - Actions
    @IBAction func signInBtnTapped(_ sender: UIButton) {

        guard
            let email = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !email.isEmpty,
            let password = passwordField.text,
            !password.isEmpty
        else {
            showAlert(title: "Warning", message: "Please fill in all fields.")
            return
        }

        // 🔎 Email format validation
        guard isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        // 🔐 Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { _, error in

            DispatchQueue.main.async {

                if let _ = error {
                    // ❌ Wrong credentials
                    self.showAlert(
                        title: "Login Failed",
                        message: "Email or password is incorrect."
                    )
                    return
                }

                // ✅ Correct credentials → stay on same page
                self.showAlert(
                    title: "Success",
                    message: "Login successful ✅"
                )
            }
        }
    }

    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
