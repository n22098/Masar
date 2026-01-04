// ===================================================================================
// SIGN IN VIEW CONTROLLER
// ===================================================================================
// PURPOSE: This screen handles the user authentication process.
//
// KEY FEATURES:
// 1. Dual Login Support: Users can sign in with Email OR Username.
// 2. Admin Portal Access: hardcoded check for administrator credentials.
// 3. Role-Based Redirection: Directs Seekers and Providers to different screens.
// 4. Ban System: Prevents suspended users from logging in.
// 5. Session Persistence: Saves login state to UserDefaults (Auto-login support).
// 6. Dynamic UI: Programmatically centers content using StackViews.
// ===================================================================================

import UIKit
import FirebaseAuth      // Firebase SDK for handling Login/Logout
import FirebaseFirestore // Firebase SDK for fetching user details (Role, Status)

class SignInViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    // Connections to the Interface Builder (Storyboard) elements
    @IBOutlet weak var emailTextField: UITextField!         // Input: Accepts Email OR Username
    @IBOutlet weak var passwordTextField: UITextField!      // Input: Password
    @IBOutlet weak var signInButton: UIButton!              // Action: Triggers Login
    @IBOutlet weak var registerButton: UIButton!            // Navigation: Go to Sign Up
    @IBOutlet weak var forgotPasswordButton: UIButton!      // Navigation: Password Recovery
    @IBOutlet weak var logoImageView: UIImageView!          // Visual: App Branding

    // MARK: - Admin Configuration
    // Hardcoded credentials for the System Administrator.
    // In a real-world app, these might be stored more securely, but this serves the project requirements.
    private let adminEmail = "admin@masar.com"
    private let adminUsername = "admin"
    private let adminPassword = "admin123"
    
    // Theme Color (Brand Purple)
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Input Configuration
        passwordTextField.isSecureTextEntry = true // Hides password characters
        emailTextField.delegate = self             // Handle "Next" key
        passwordTextField.delegate = self          // Handle "Go" key
        
        // 2. Keyboard Setup
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .go
        
        // 3. UI Initialization
        setupProfessionalUI()          // Applies styling (Shadows, Borders)
        centerContentProgrammatically() // Fixes layout alignment
    }
    
    // MARK: - Keyboard Delegate Methods
    // Controls what happens when the user presses "Return" on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() // Move focus to Password field
        } else if textField == passwordTextField {
            textField.resignFirstResponder()         // Hide keyboard
            signInPressed(signInButton)              // Auto-click Sign In
        }
        return true
    }
    
    // MARK: - Programmatic Layout
    // This method takes the existing UI elements, removes them from the view,
    // and re-adds them inside a UIStackView to ensure they are perfectly centered.
    private func centerContentProgrammatically() {
        // Ensure all views exist
        guard let logo = logoImageView,
              let email = emailTextField,
              let pass = passwordTextField,
              let forgot = forgotPasswordButton,
              let signIn = signInButton,
              let register = registerButton else { return }
        
        // Remove from current layout to prepare for StackView insertion
        [logo, email, pass, forgot, signIn, register].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.removeFromSuperview()
        }
        
        // Create Vertical StackView
        let stackView = UIStackView(arrangedSubviews: [logo, email, pass, forgot, signIn, register])
        stackView.axis = .vertical
        stackView.spacing = 20          // Standard spacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Custom Spacing for specific elements to improve visual flow
        stackView.setCustomSpacing(30, after: logo)
        stackView.setCustomSpacing(10, after: pass)
        stackView.setCustomSpacing(30, after: forgot)
        
        view.addSubview(stackView)
        
        // Set Constraints for the StackView (Center in screen)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Force specific heights for UI consistency
            logo.heightAnchor.constraint(equalToConstant: 230),
            email.heightAnchor.constraint(equalToConstant: 50),
            pass.heightAnchor.constraint(equalToConstant: 50),
            signIn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        logo.contentMode = .scaleAspectFill
        logo.clipsToBounds = true
    }
    
    // MARK: - Professional UI Styling
    // Applies the brand colors, rounded corners, and shadows
    private func setupProfessionalUI() {
        // Dismiss keyboard when tapping background
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Style Inputs with Icons
        styleTextField(emailTextField, iconName: "envelope", placeholder: "Username or Email")
        styleTextField(passwordTextField, iconName: "lock", placeholder: "Password")
        
        // Style Sign In Button (Shadow + Corner Radius)
        if let btn = signInButton {
            btn.backgroundColor = brandColor
            btn.setTitle("Sign In", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 12
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 6
        }
        
        // Style Secondary Buttons
        registerButton?.setTitleColor(brandColor, for: .normal)
        registerButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        forgotPasswordButton?.setTitleColor(.gray, for: .normal)
        forgotPasswordButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        forgotPasswordButton?.contentHorizontalAlignment = .right
        
        if let logo = logoImageView {
            logo.layer.shadowColor = UIColor.clear.cgColor
            logo.backgroundColor = .clear
        }
    }
    
    // Helper to add icons inside TextFields
    private func styleTextField(_ textField: UITextField, iconName: String, placeholder: String) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        // Icon Container View
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconImageView = UIImageView(frame: CGRect(x: 10, y: 15, width: 20, height: 20))
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)
        
        textField.leftView = iconView
        textField.leftViewMode = .always
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Main Login Action
    @IBAction func signInPressed(_ sender: UIButton) {
        // 1. Validation
        guard let input = emailTextField.text, !input.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please fill all fields")
            return
        }

        // 2. Admin Login Check
        // If input matches Admin credentials, bypass Firebase and go to Admin Panel
        if (input == adminEmail || input == adminUsername), password == adminPassword {
            navigateToAdmin()
            return
        }

        // 3. Regular User Login
        loginUser(emailOrUsername: input, password: password)
    }

    // Logic to determine if input is Email or Username
    private func loginUser(emailOrUsername: String, password: String) {
        if emailOrUsername.contains("@") {
            // It's an Email -> Direct Login
            firebaseLogin(email: emailOrUsername, password: password)
        } else {
            // It's a Username -> Fetch Email first, then Login
            fetchEmailFromUsername(username: emailOrUsername) { [weak self] email in
                guard let self = self else { return }
                guard let email = email else {
                    self.showAlert("Username not found")
                    return
                }
                self.firebaseLogin(email: email, password: password)
            }
        }
    }

    // MARK: - Firebase Authentication
    private func firebaseLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Login error: \(error.localizedDescription)")
                self.showLoginError()
                return
            }
            
            guard let uid = authResult?.user.uid else {
                self.showAlert("Failed to get user ID")
                return
            }
            
            print("✅ User logged in successfully: \(uid)")
            
            // Fetch User Details from Firestore (Role & Status)
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        self.showAlert("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let document = document, document.exists,
                          let data = document.data() else {
                        self.showAlert("User data not found in database.")
                        return
                    }
                    
                    // Retrieve Role and Status
                    let status = data["status"] as? String ?? "Active"
                    let role = data["role"] as? String ?? ""
                    
                    print("👤 User status: \(status), role: \(role)")
                    
                    // Check for Ban
                    if status == "Ban" {
                        self.handleBanStatus()
                    } else {
                        self.redirectBasedOnRole(role: role)
                    }
                }
            }
        }
    }
    
    // Security: Handle Banned Users
    private func handleBanStatus() {
        print("🚫 User is banned - signing out")
        try? Auth.auth().signOut() // Force logout immediately
        
        // Clear session data
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        let alert = UIAlertController(
            title: "Account Banned",
            message: "Your account has been banned by the administrator. Please contact support.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func showLoginError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Login Failed",
                message: "Username or password are incorrect.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }


    // MARK: - Navigation & Session Management
    private func redirectBasedOnRole(role: String) {
        // 1. Session Persistence: Save that user is logged in
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        
        // 2. Save Role: To recall permissions later
        UserDefaults.standard.set(role, forKey: "userRole")
        UserDefaults.standard.synchronize()
        print("✅ User role saved: \(role), Login State: Active")
        
        // 3. Navigate: Switch Storyboard based on Role
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if role.lowercased() == "provider" {
                sceneDelegate.navigateToStoryboard("Provider")
            } else {
                sceneDelegate.navigateToStoryboard("Seeker")
            }
        }
    }

    private func navigateToAdmin() {
        // Admin Session Persistence
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("admin", forKey: "userRole")
        UserDefaults.standard.synchronize()
        print("✅ Admin role saved")
        
        // Switch to Admin Storyboard
        let storyboard = UIStoryboard(name: "admin", bundle: nil)
        if let adminVC = storyboard.instantiateInitialViewController() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let delegate = windowScene.delegate as? SceneDelegate,
               let window = delegate.window {
                
                window.rootViewController = adminVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }

    // Helper: Database Query to find Email by Username
    private func fetchEmailFromUsername(username: String, completion: @escaping (String?) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, _ in
                completion(snapshot?.documents.first?.data()["email"] as? String)
            }
    }

    private func showAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
