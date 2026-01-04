// ===================================================================================
// SIGN UP SEEKER VIEW CONTROLLER
// ===================================================================================
// PURPOSE: This screen handles the registration process for new users (Seekers)
// who want to join the Masar platform to find and book services.
//
// KEY FEATURES:
// 1. User input validation (name, email, phone, username, password)
// 2. Privacy policy agreement requirement (Programmatic UI)
// 3. Secure password handling with show/hide toggle
// 4. Firebase Authentication (Auth) integration
// 5. Firestore database storage for user profiles
// 6. Professional UI styling (Icons, Rounded Corners, Brand Colors)
// ===================================================================================

import UIKit
import FirebaseAuth      // Imports the Auth SDK to handle Sign Up/Login logic
import FirebaseFirestore // Imports the Database SDK to store user details (Name, Role, etc.)

// The class inherits from UIViewController to manage the view,
// and adopts UITextFieldDelegate to handle keyboard interactions (Return key, focus).
class SignUpSeekerViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Storyboard Outlets
    // These connections link the visual elements in the Interface Builder to our code.
    
    @IBOutlet weak var nameTextField: UITextField!              // Input: User's legal name
    @IBOutlet weak var emailTextField: UITextField!             // Input: Email for Authentication
    @IBOutlet weak var phoneNumberTextField: UITextField!       // Input: Contact number
    @IBOutlet weak var usernameTextField: UITextField!          // Input: Unique handle
    @IBOutlet weak var passwordTextField: UITextField!          // Input: Secret password
    @IBOutlet weak var confirmPasswordTextField: UITextField!   // Input: Verification to prevent typos
    
    // ❌ ApplyAsProviderSwitch removed as per previous request
    
    @IBOutlet weak var signUpButton: UIButton!      // Action: Triggers the registration process
    @IBOutlet weak var logoImageView: UIImageView!  // Visual: Displays App Branding

    // MARK: - Programmatic UI Elements
    // These elements are created using code (not Storyboard) to demonstrate
    // dynamic UI capabilities and handling constraints programmatically.
    
    // 1. The Toggle Switch for Privacy Policy
    private let privacySwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false // Start as OFF so the user is forced to toggle it manually
        toggle.onTintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0) // Matches Brand Color
        toggle.translatesAutoresizingMaskIntoConstraints = false // REQUIRED for Auto Layout constraints
        return toggle
    }()
    
    // 2. The Interactive Label Button
    // Uses Attributed String to make "Privacy Policy" look like a clickable link (Bold + Underline)
    private let privacyLabelButton: UIButton = {
        let btn = UIButton(type: .system)
        
        // Creating a rich text string with different styles
        let attributedText = NSMutableAttributedString(
            string: "I agree to the ",
            attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 14)]
        )
        attributedText.append(NSAttributedString(
            string: "Privacy Policy",
            attributes: [
                .foregroundColor: UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0), // Brand Purple
                .font: UIFont.boldSystemFont(ofSize: 14),
                .underlineStyle: NSUnderlineStyle.single.rawValue // Adds the underline
            ]
        ))
        
        btn.setAttributedTitle(attributedText, for: .normal)
        btn.contentHorizontalAlignment = .left  // Aligns text naturally
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Data Constants
    // Hardcoded text for the Privacy Policy modal.
    // In a production app, this might be fetched from a server to keep it updated.
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

    // Database Reference: Initialize Firestore
    let db = Firestore.firestore()
    
    // Color Constant: Defines the purple theme used in code
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - View Lifecycle
    // viewDidLoad is the entry point. It runs once when the screen loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Logic and Delegates
        setupDelegates()                                      // Connects text fields to this class (for keyboard handling)
        
        // 2. Setup Password Security UI
        setupPasswordToggle(for: passwordTextField)           // Adds the "eye" icon logic
        setupPasswordToggle(for: confirmPasswordTextField)
        
        // 3. Setup Styling
        setupProfessionalUI()                                 // Applies borders, icons, and shadows
        
        // 4. Setup Programmatic UI
        setupPrivacyUI()                                      // Adds the privacy switch/label to the view hierarchy
    }

    // MARK: - UI Configuration Methods
    
    // Configures general UI aesthetics (Colors, Shadows, Icons)
    private func setupProfessionalUI() {
        // Gesture Recognizer: Allows tapping anywhere on the background to dismiss the keyboard
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.backgroundColor = .systemBackground  // Adapts to Light/Dark mode automatically

        // Apply custom styling (Icon + Borders) to each field
        styleTextField(nameTextField, iconName: "person")
        styleTextField(emailTextField, iconName: "envelope")
        
        // Specific setup for Phone Number to ensure numeric input
        phoneNumberTextField.keyboardType = .numberPad
        styleTextField(phoneNumberTextField, iconName: "phone")
        
        styleTextField(usernameTextField, iconName: "at")           // "@" symbol
        styleTextField(passwordTextField, iconName: "lock")
        styleTextField(confirmPasswordTextField, iconName: "lock.shield")
        
        // Button Styling: Adds shadow and corner radius for a modern look
        if let btn = signUpButton {
            btn.backgroundColor = brandColor
            btn.setTitle("Sign Up", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 14
            
            // Drop Shadow logic
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 8
        }
        
        logoImageView?.contentMode = .scaleAspectFit
    }
    
    // Adds the Programmatic Privacy elements to the view and sets constraints
    private func setupPrivacyUI() {
        // Essential step: Add the views to the screen hierarchy
        view.addSubview(privacySwitch)
        view.addSubview(privacyLabelButton)
        
        // Connect the button to the function that shows the policy text
        privacyLabelButton.addTarget(self, action: #selector(showPrivacyPolicyText), for: .touchUpInside)
        
        // Activate Auto Layout Constraints (Anchors)
        // This replaces the "Blue Lines" you usually see in Storyboard
        NSLayoutConstraint.activate([
            // Place Switch 20 points below the Confirm Password field
            privacySwitch.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 20),
            privacySwitch.leadingAnchor.constraint(equalTo: confirmPasswordTextField.leadingAnchor),
            
            // Place Label vertically centered with the switch, and 10 points to the right
            privacyLabelButton.centerYAnchor.constraint(equalTo: privacySwitch.centerYAnchor),
            privacyLabelButton.leadingAnchor.constraint(equalTo: privacySwitch.trailingAnchor, constant: 10),
            privacyLabelButton.trailingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor)
        ])
    }
    
    // Helper function to prevent code repetition when styling text fields
    private func styleTextField(_ textField: UITextField, iconName: String) {
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.4)
        textField.textColor = .label
        
        // Create a wrapper view for the icon to add padding
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 50))
        let iconView = UIImageView(frame: CGRect(x: 12, y: 14, width: 22, height: 22))
        
        // Use SFSymbols (Apple's system icons)
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = brandColor
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        
        // Set the icon container to the Left side of the input field
        textField.leftView = iconContainer
        textField.leftViewMode = .always
    }
    
    // Selector method to close keyboard
    @objc func dismissKeyboard() { view.endEditing(true) }

    // MARK: - TextField Delegates
    // This section controls how the keyboard behaves (Next vs Go buttons)
    private func setupDelegates() {
        let textFields = [nameTextField, emailTextField, phoneNumberTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        
        for (index, textField) in textFields.enumerated() {
            textField?.delegate = self  // Tell the field "Ask this controller how to behave"
            textField?.tag = index      // Assign a number to track order (0, 1, 2...)
            
            // If it's the last field, show "Go", otherwise show "Next"
            if textField == confirmPasswordTextField {
                textField?.returnKeyType = .go
            } else {
                textField?.returnKeyType = .next
            }
        }
    }

    // Triggered when user presses "Return" or "Next" on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        // Find the next text field based on the tag
        if let nextResponder = self.view.viewWithTag(nextTag) as? UITextField {
            nextResponder.becomeFirstResponder() // Move focus to next field
        } else {
            textField.resignFirstResponder() // Hide keyboard
            // Logic: If it's the last field, try to Sign Up immediately for better UX
            signUpBtn(UIButton())
        }
        return true
    }
    
    // Input Validation: Ensures only Numbers are typed into the Phone field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            let allowedCharacters = CharacterSet.decimalDigits // 0-9 only
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    // MARK: - User Actions
    
    // Action: Triggered when "Privacy Policy" label is tapped
    @objc func showPrivacyPolicyText() {
        // Create a temporary view controller to show the text
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Privacy Policy"
        
        let textView = UITextView()
        textView.text = privacyPolicyText
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isEditable = false // Read-only
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(textView)
        
        // Constraints for the text view inside the modal
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -10)
        ])
        
        // Present as a standard iOS sheet
        present(vc, animated: true)
    }

    // Action: The MAIN Sign Up Logic
    @IBAction func signUpBtn(_ sender: UIButton) {
        
        // 1. Client-Side Validation (Check empty fields, password match, etc.)
        guard validateInputs() else { return }

        // 2. Clean inputs (remove whitespace) to prevent database errors
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        // 3. Database Check: Verify uniqueness of Email, Username, and Phone
        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                return
            }
            
            // 4. Firebase Auth: Create the Authentication Account
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert("Error: \(error.localizedDescription)")
                    return
                }
                
                // Get the unique ID (UID) generated by Firebase
                guard let uid = authResult?.user.uid else { return }
            
                // 5. Firestore: Create the User Profile Document
                // We store the Role "seeker" here to distinguish from Providers
                let userData: [String: Any] = [
                    "uid": uid,
                    "name": name,
                    "email": email,
                    "username": username,
                    "phone": phone,
                    "role": "seeker",
                    "createdAt": FieldValue.serverTimestamp() // Server time for accuracy
                ]
                
                // Write to "users" collection
                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        self.showAlert("Failed: \(error.localizedDescription)")
                    } else {
                        // 6. Success: Redirect to Main App
                        self.showSuccessAndRedirect()
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods
    
    // Handles the transition to the main app after successful signup
    func showSuccessAndRedirect() {
        let alert = UIAlertController(title: "Success!", message: "Account created successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Switch Storyboards programmatically
            let storyboard = UIStoryboard(name: "Seeker", bundle: nil)
            
            // Set the Window's Root View Controller (resets the app navigation stack)
            if let mainVC = storyboard.instantiateInitialViewController(),
               let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window {
                window.rootViewController = mainVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        })
        present(alert, animated: true)
    }
    
    // Performs validation checks before sending data to Firebase
    func validateInputs() -> Bool {
        let fields = [nameTextField, emailTextField, usernameTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        
        // Check 1: Are any fields empty?
        if fields.contains(where: { $0?.text?.isEmpty ?? true }) {
            showAlert("All fields are required.")
            return false
        }
        
        // Check 2: Phone number validation
        if let phone = phoneNumberTextField.text, phone.count < 8 {
            showAlert("Phone number must be at least 8 digits.")
            return false
        }
        
        // Check 3: Password Matching
        if passwordTextField.text != confirmPasswordTextField.text {
            showAlert("Passwords do not match.")
            return false
        }
        
        // Check 4: Password Strength
        if (passwordTextField.text?.count ?? 0) < 6 {
            showAlert("Password must be at least 6 characters.")
            return false
        }
        
        // Check 5: Legal Agreement
        if !privacySwitch.isOn {
            showAlert("You must agree to the Privacy Policy to sign up.")
            return false
        }
        
        return true
    }

    // Adds the "Eye" button to toggle password visibility
    private func setupPasswordToggle(for textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)   // Hidden icon
        button.setImage(UIImage(systemName: "eye"), for: .selected)       // Visible icon
        button.tintColor = .systemGray
        
        // Button configuration
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 10)
        button.configuration = config
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        
        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        
        // Add to the right side of the text field
        textField.rightView = button
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true // Default to hidden
    }

    // Toggles the isSecureTextEntry property when the eye button is clicked
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle() // Switch button state
        
        // Determine which text field owns this button and toggle its security
        if let textField = sender.superview as? UITextField {
            textField.isSecureTextEntry.toggle()
        } else if sender == passwordTextField.rightView as? UIButton {
            passwordTextField.isSecureTextEntry.toggle()
        } else if sender == confirmPasswordTextField.rightView as? UIButton {
            confirmPasswordTextField.isSecureTextEntry.toggle()
        }
    }

    // Asynchronous check against Firestore to prevent duplicate users
    func checkIfUserDataExists(email: String, username: String, phone: String, completion: @escaping (Bool) -> Void) {
        // Advanced Firestore Query: Uses 'OR' filter to check 3 fields in one query
        db.collection("users").whereFilter(Filter.orFilter([
            Filter.whereField("email", isEqualTo: email),
            Filter.whereField("username", isEqualTo: username),
            Filter.whereField("phone", isEqualTo: phone)
        ])).getDocuments { snapshot, _ in
            // If documents are found (snapshot not empty), user exists
            completion(!(snapshot?.documents.isEmpty ?? true))
        }
    }

    // Standard method to show pop-up alerts to the user
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
