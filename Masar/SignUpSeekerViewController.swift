
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpSeekerViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var applyAsProviderSwitch: UISwitch!

    let db = Firestore.firestore()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyAsProviderSwitch.setOn(false, animated: false)
    }

    // MARK: - Sign Up
    @IBAction func signUpBtn(_ sender: UIButton) {
        if applyAsProviderSwitch.isOn {
            showAlert("Please complete provider information first.")
            return
        }

        guard validateInputs() else { return }

        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!

        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                return
            }

            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                    return
                }

                guard let uid = result?.user.uid else { return }

                self.db.collection("users").document(uid).setData([
                    "uid": uid,
                    "name": name,
                    "email": email,
                    "username": username,
                    "phone": phone,
                    "role": "seeker"
                ]) { error in
                    if let error = error {
                        self.showAlert(error.localizedDescription)
                    } else {
                        self.showSuccessAndGoToSignIn()
                    }
                }
            }
        }
    }

    // MARK: - Apply As Provider
    @IBAction func switchBtn(_ sender: UISwitch) {
        guard sender.isOn else { return }

        guard validateInputs() else {
            sender.setOn(false, animated: true)
            return
        }

        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                sender.setOn(false, animated: true)
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let providerVC = storyboard.instantiateViewController(
                withIdentifier: "ApplyProviderTableViewController"
            ) as? ApplyProviderTableViewController else {
                sender.setOn(false, animated: true)
                self.showAlert("Provider screen not found. Check storyboard ID.")
                return
            }

            // ✅ PASS DATA
            providerVC.userName = name
            providerVC.userEmail = email
            providerVC.userPhone = phone

            self.navigationController?.pushViewController(providerVC, animated: true)
        }
    }

    // MARK: - Validation
    func validateInputs() -> Bool {
        if nameTextField.text?.isEmpty == true ||
            emailTextField.text?.isEmpty == true ||
            usernameTextField.text?.isEmpty == true ||
            phoneNumberTextField.text?.isEmpty == true ||
            passwordTextField.text?.isEmpty == true ||
            confirmPasswordTextField.text?.isEmpty == true {
            showAlert("All fields are required.")
            return false
        }

        if !isValidEmail(emailTextField.text!) {
            showAlert("Please enter a valid email.")
            return false
        }

        if passwordTextField.text! != confirmPasswordTextField.text! {
            showAlert("Passwords do not match.")
            return false
        }

        return true
    }

    // MARK: - Firestore Check
    func checkIfUserDataExists(
        email: String,
        username: String,
        phone: String,
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("users")
            .whereFilter(Filter.orFilter([
                Filter.whereField("email", isEqualTo: email),
                Filter.whereField("username", isEqualTo: username),
                Filter.whereField("phone", isEqualTo: phone)
            ]))
            .getDocuments { snapshot, _ in
                completion(!(snapshot?.documents.isEmpty ?? true))
            }
    }

    // MARK: - Alerts
    func showSuccessAndGoToSignIn() {
        let alert = UIAlertController(
            title: "Success",
            message: "Account created successfully.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
