import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    // Admin Credentials
    private let adminEmail = "admin@masar.com"
    private let adminUsername = "admin"
    private let adminPassword = "admin123"
    
    // Brand Color
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic Setup
        passwordTextField.isSecureTextEntry = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // 🔥 NEW: Configure Return Keys
        emailTextField.returnKeyType = .next  // Shows "Next" on keyboard
        passwordTextField.returnKeyType = .go // Shows "Go" on keyboard
        
        // Apply Design
        setupProfessionalUI()
        
        // 🔥 تطبيق التوسيط وتكبير الصورة (الإصلاح الجديد)
        centerContentProgrammatically()
    }
    
    // MARK: - 🔥 NEW: Handle Return Key Logic
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            // If user presses Next on email, go to password
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // If user presses Go on password, hide keyboard and Sign In
            textField.resignFirstResponder()
            signInPressed(signInButton)
        }
        return true
    }
    
    // MARK: - 🎨 Layout Fix
    private func centerContentProgrammatically() {
        guard let logo = logoImageView,
              let email = emailTextField,
              let pass = passwordTextField,
              let forgot = forgotPasswordButton,
              let signIn = signInButton,
              let register = registerButton else { return }
        
        // إيقاف القيود القديمة
        [logo, email, pass, forgot, signIn, register].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.removeFromSuperview()
        }
        
        // إنشاء StackView
        let stackView = UIStackView(arrangedSubviews: [logo, email, pass, forgot, signIn, register])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // تخصيص المسافات
        stackView.setCustomSpacing(30, after: logo) // قللت المسافة قليلاً لأن الشعار سيكبر
        stackView.setCustomSpacing(10, after: pass)
        stackView.setCustomSpacing(30, after: forgot)
        
        view.addSubview(stackView)
        
        // وضع القيود
        NSLayoutConstraint.activate([
            // توسيط عمودي
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // هوامش جانبية
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // 🔥 التعديل الجذري هنا:
            // 1. زيادة الارتفاع إلى 230 كما طلبت
            logo.heightAnchor.constraint(equalToConstant: 230),
            
            // ارتفاع الحقول والأزرار
            email.heightAnchor.constraint(equalToConstant: 50),
            pass.heightAnchor.constraint(equalToConstant: 50),
            signIn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 🔥 الحل السحري لتكبير الشعار:
        // scaleAspectFill: يكبر الصورة لتملأ الارتفاع 230، حتى لو انقصت الحواف الشفافة
        logo.contentMode = .scaleAspectFill
        logo.clipsToBounds = true // لضمان عدم خروج الصورة عن الإطار
    }
    
    // MARK: - 🎨 Professional UI Setup
    private func setupProfessionalUI() {
        // 1. Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // 2. Style TextFields
        styleTextField(emailTextField, iconName: "envelope", placeholder: "Username or Email")
        styleTextField(passwordTextField, iconName: "lock", placeholder: "Password")
        
        // 3. Style Sign In Button
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
        
        // 4. Style Secondary Buttons
        registerButton?.setTitleColor(brandColor, for: .normal)
        registerButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        forgotPasswordButton?.setTitleColor(.gray, for: .normal)
        forgotPasswordButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        forgotPasswordButton?.contentHorizontalAlignment = .right
        
        // 5. Style Logo
        if let logo = logoImageView {
            logo.layer.shadowColor = UIColor.clear.cgColor
            logo.backgroundColor = .clear
        }
    }
    
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

    // MARK: - Sign In Logic
    @IBAction func signInPressed(_ sender: UIButton) {
        guard let input = emailTextField.text, !input.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please fill all fields")
            return
        }

        // 1. Admin Check
        if (input == adminEmail || input == adminUsername), password == adminPassword {
            navigateToAdmin()
            return
        }

        // 2. User Login
        loginUser(emailOrUsername: input, password: password)
    }

    private func loginUser(emailOrUsername: String, password: String) {
        if emailOrUsername.contains("@") {
            firebaseLogin(email: emailOrUsername, password: password)
        } else {
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
            
            // Fetch User Data
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
                    
                    let status = data["status"] as? String ?? "Active"
                    let role = data["role"] as? String ?? ""
                    
                    print("👤 User status: \(status), role: \(role)")
                    
                    if status == "Ban" {
                        self.handleBanStatus()
                    } else {
                        self.redirectBasedOnRole(role: role)
                    }
                }
            }
        }
    }
    
    private func handleBanStatus() {
        print("🚫 User is banned - signing out")
        try? Auth.auth().signOut()
        
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
            let alert = UIAlertController(title: "Login Error", message: "The provided credentials are incorrect.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Navigation
    private func redirectBasedOnRole(role: String) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if role.lowercased() == "provider" {
                sceneDelegate.navigateToStoryboard("Provider")
            } else {
                sceneDelegate.navigateToStoryboard("Seeker")
            }
        }
    }

    private func navigateToAdmin() {
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
