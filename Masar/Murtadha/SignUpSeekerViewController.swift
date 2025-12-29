import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpSeekerViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var applyAsProviderSwitch: UISwitch!

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup text field delegates for animations
        setupDelegates()
        
        // Initialize the eye icons
        setupPasswordToggle(for: passwordTextField)
        setupPasswordToggle(for: confirmPasswordTextField)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyAsProviderSwitch.setOn(false, animated: false)
    }

    // MARK: - Keyboard & Delegate Setup
    
    private func setupDelegates() {
        let textFields = [nameTextField, emailTextField, phoneNumberTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        
        for (index, textField) in textFields.enumerated() {
            textField?.delegate = self
            textField?.tag = index // Tagging them in order
            
            // Set keyboard return key type
            if textField == confirmPasswordTextField {
                textField?.returnKeyType = .go
            } else {
                textField?.returnKeyType = .next
            }
        }
    }

    // This function handles the "Next" animation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = self.view.viewWithTag(nextTag) as? UITextField {
            // Animate moving to next field
            nextResponder.becomeFirstResponder()
        } else {
            // If it's the last field, trigger the sign up action
            textField.resignFirstResponder()
            signUpBtn(UIButton())
        }
        return true
    }

    // MARK: - Actions
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        if applyAsProviderSwitch.isOn {
            showAlert("Please complete provider information first.")
            return
        }

        guard validateInputs() else { return }

        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                return
            }

            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert("Error: \(error.localizedDescription)")
                    return
                }

                guard let uid = authResult?.user.uid else { return }

                let userData: [String: Any] = [
                    "uid": uid,
                    "name": name,
                    "email": email,
                    "username": username,
                    "phone": phone,
                    "role": "seeker",
                    "createdAt": FieldValue.serverTimestamp()
                ]

                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        self.showAlert("Account created but failed: \(error.localizedDescription)")
                    } else {
                        self.showSuccessAndRedirect()
                    }
                }
            }
        }
    }

    @IBAction func switchBtn(_ sender: UISwitch) {
        guard sender.isOn else { return }
        
        // التحقق من صحة المدخلات قبل الانتقال
        guard validateInputs() else {
            sender.setOn(false, animated: true)
            return
        }

        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) // ✅ Capture Username
        let password = passwordTextField.text!

        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                sender.setOn(false, animated: true)
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let providerVC = storyboard.instantiateViewController(withIdentifier: "ApplyProviderTableViewController") as? ApplyProviderTableViewController else {
                sender.setOn(false, animated: true)
                return
            }

            // تمرير البيانات للصفحة التالية
            providerVC.userName = name
            providerVC.userEmail = email
            providerVC.userPhone = phone
            providerVC.userUsername = username // ✅ Pass Username
            providerVC.userPassword = password

            self.navigationController?.pushViewController(providerVC, animated: true)
        }
    }

    // MARK: - Navigation
    
    func showSuccessAndRedirect() {
        let alert = UIAlertController(title: "Success!", message: "Account created successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            
            // الانتقال مباشرة إلى Seeker Storyboard
            let storyboard = UIStoryboard(name: "Seeker", bundle: nil)
            if let mainVC = storyboard.instantiateInitialViewController() {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    window.rootViewController = mainVC
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true)
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
        if (passwordTextField.text?.count ?? 0) < 6 {
            showAlert("Password must be at least 6 characters.")
            return false
        }
        return true
    }

    private func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = button
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let textField = sender.superview as? UITextField {
            textField.isSecureTextEntry.toggle()
            if let text = textField.text {
                textField.text = nil
                textField.text = text
            }
        }
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
