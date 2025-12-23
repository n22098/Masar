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

    @IBAction func signUpBtn(_ sender: UIButton) {
        if applyAsProviderSwitch.isOn {
            showAlert("Please complete provider information first.")
            return
        }
        guard validateInputs() else { return }
        // Seeker registration logic here...
    }

    @IBAction func switchBtn(_ sender: UISwitch) {
        guard sender.isOn else { return }
        guard validateInputs() else {
            sender.setOn(false, animated: true)
            return
        }

        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        checkIfUserDataExists(email: email, username: usernameTextField.text!, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                sender.setOn(false, animated: true)
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // This line crashes if you didn't set the Storyboard ID in the inspector!
            guard let providerVC = storyboard.instantiateViewController(withIdentifier: "ApplyProviderTableViewController") as? ApplyProviderTableViewController else {
                sender.setOn(false, animated: true)
                print("Error: Could not find ApplyProviderTableViewController in Storyboard.")
                return
            }

            // Pass the data to the next screen
            providerVC.userName = name
            providerVC.userEmail = email
            providerVC.userPhone = phone

            self.navigationController?.pushViewController(providerVC, animated: true)
        }
    }

    // MARK: - Helpers
    func validateInputs() -> Bool {
        let fields = [nameTextField, emailTextField, usernameTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        if fields.contains(where: { $0?.text?.isEmpty ?? true }) {
            showAlert("All fields are required.")
            return false
        }
        if passwordTextField.text != confirmPasswordTextField.text {
            showAlert("Passwords do not match.")
            return false
        }
        return true
    }

    func checkIfUserDataExists(email: String, username: String, phone: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").whereFilter(Filter.orFilter([
            Filter.whereField("email", isEqualTo: email),
            Filter.whereField("username", isEqualTo: username),
            Filter.whereField("phone", isEqualTo: phone)
        ])).getDocuments { snapshot, _ in
            completion(!(snapshot?.documents.isEmpty ?? true))
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
