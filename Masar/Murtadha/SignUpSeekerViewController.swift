// ===================================================================================
// SIGN UP SEEKER VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Handles registration for Seekers with strict password validation.
// NEW RULES: Password must be 8+ characters and contain at least one uppercase letter.
// ===================================================================================

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpSeekerViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    // MARK: - Programmatic UI Elements
    private let privacySwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.onTintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let privacyLabelButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(
            string: "I agree to the ",
            attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 14)]
        )
        attributedText.append(NSAttributedString(
            string: "Privacy Policy",
            attributes: [
                .foregroundColor: UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0),
                .font: UIFont.boldSystemFont(ofSize: 14),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        btn.setAttributedTitle(attributedText, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Data Constants
    private let privacyPolicyText = """
        Masar operates the Local Skills & Services Exchange application.
        This page is used to inform Masar users regarding our policies with the collection, use, and disclosure of personal information if anyone decides to use our Service.

        By using the Masar app, you agree to the collection and use of information in accordance with this policy. The personal information that we collect is used for providing, improving, and personalizing our Service. We will not use or share your information with anyone except as described in this Privacy Policy.

        Information Collection and Use
        To enhance your experience while using our Service, we may require you to provide certain personally identifiable information, including but not limited to your full name, phone number, location, and service preferences. The information we collect will be used to:
        • Help match users seeking skills or services with those providing them.
        • Facilitate communication between users.
        • Improve and personalize your experience in the app.

        Service Providers
        We may employ third-party companies and individuals for the following purposes:
        • To assist in improving our Service;
        • To provide the Service on our behalf;
        • To analyze app usage and performance.

        These third parties may have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.

        Security
        We value your trust in providing your personal information and strive to use commercially acceptable means to protect it. However, please remember that no method of transmission over the internet, or method of electronic storage, is 100% secure.

        Links to Other Sites
        Our Service may contain links to third-party sites. If you click on a third-party link, you will be directed to that site. We are not responsible for the content or privacy policies of these websites and strongly advise you to review their policies.

        Children's Privacy
        Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.

        Changes to This Privacy Policy
        We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes. Changes are effective immediately after being posted on this page.

        Contact Us
        If you have any questions or suggestions about our Privacy Policy, feel free to contact us at:
        Masar@gmail.com
        +973-39871234
        """

    let db = Firestore.firestore()
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupPasswordToggle(for: passwordTextField)
        setupPasswordToggle(for: confirmPasswordTextField)
        setupProfessionalUI()
        setupPrivacyUI()
    }

    // MARK: - UI Configuration
    private func setupProfessionalUI() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.backgroundColor = .systemBackground

        styleTextField(nameTextField, iconName: "person")
        styleTextField(emailTextField, iconName: "envelope")
        
        phoneNumberTextField.keyboardType = .numberPad
        styleTextField(phoneNumberTextField, iconName: "phone")
        
        styleTextField(usernameTextField, iconName: "at")
        styleTextField(passwordTextField, iconName: "lock")
        styleTextField(confirmPasswordTextField, iconName: "lock.shield")
        
        if let btn = signUpButton {
            btn.backgroundColor = brandColor
            btn.layer.cornerRadius = 14
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 8
        }
    }
    
    private func setupPrivacyUI() {
        view.addSubview(privacySwitch)
        view.addSubview(privacyLabelButton)
        privacyLabelButton.addTarget(self, action: #selector(showPrivacyPolicyText), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            privacySwitch.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            privacySwitch.leadingAnchor.constraint(equalTo: confirmPasswordTextField.leadingAnchor),
            privacyLabelButton.centerYAnchor.constraint(equalTo: privacySwitch.centerYAnchor),
            privacyLabelButton.leadingAnchor.constraint(equalTo: privacySwitch.trailingAnchor, constant: 10),
            privacyLabelButton.trailingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor)
        ])
    }
    
    private func styleTextField(_ textField: UITextField, iconName: String) {
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.4)
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 50))
        let iconView = UIImageView(frame: CGRect(x: 12, y: 14, width: 22, height: 22))
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = brandColor
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Validation & Sign Up Logic
    func validateInputs() -> Bool {
        let fields = [nameTextField, emailTextField, usernameTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        
        // Check 1: Empty Fields
        if fields.contains(where: { $0?.text?.isEmpty ?? true }) {
            showAlert("All fields are required.")
            return false
        }
        
        // Check 2: Password Length (8 characters)
        guard let password = passwordTextField.text, password.count >= 8 else {
            showAlert("Password must be at least 8 characters long.")
            return false
        }
        
        // Check 3: Uppercase Character Check
        let uppercaseRegex = ".*[A-Z].*"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        if !passwordTest.evaluate(with: password) {
            showAlert("Password must contain at least one uppercase letter.")
            return false
        }
        
        // Check 4: Passwords Match
        if passwordTextField.text != confirmPasswordTextField.text {
            showAlert("Passwords do not match.")
            return false
        }
        
        // Check 5: Privacy Agreement
        if !privacySwitch.isOn {
            showAlert("You must agree to the Privacy Policy.")
            return false
        }
        
        return true
    }

    @IBAction func signUpBtn(_ sender: UIButton) {
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
                        self.showAlert("Failed to save profile: \(error.localizedDescription)")
                    } else {
                        self.showSuccessAndRedirect()
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let textField = sender.superview as? UITextField {
            textField.isSecureTextEntry.toggle()
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

    func showSuccessAndRedirect() {
        let alert = UIAlertController(title: "Success!", message: "Account created successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let storyboard = UIStoryboard(name: "Seeker", bundle: nil)
            if let mainVC = storyboard.instantiateInitialViewController(),
               let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
                window.rootViewController = mainVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        })
        present(alert, animated: true)
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func showPrivacyPolicyText() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let textView = UITextView()
        textView.text = privacyPolicyText
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -10)
        ])
        present(vc, animated: true)
    }

    private func setupDelegates() {
        let textFields = [nameTextField, emailTextField, phoneNumberTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        for (index, textField) in textFields.enumerated() {
            textField?.delegate = self
            textField?.tag = index
            textField?.returnKeyType = (textField == confirmPasswordTextField) ? .go : .next
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextResponder = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signUpBtn(UIButton())
        }
        return true
    }
}
