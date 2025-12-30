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
    @IBOutlet weak var logoImageView: UIImageView! // اربط صورة اللوجو هنا

    // بيانات الأدمن الثابتة
    private let adminEmail = "admin@masar.com"
    private let adminUsername = "admin"
    private let adminPassword = "admin123"
    
    // ألوان الهوية البصرية (البنفسجي الخاص بمسار)
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // إعدادات المنطق الأصلية
        passwordTextField.isSecureTextEntry = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // 🔥 استدعاء دالة التصميم الجديد
        setupProfessionalUI()
    }
    
    // MARK: - 🎨 Professional UI Setup
    private func setupProfessionalUI() {
        // 1. إخفاء الكيبورد عند الضغط في أي مكان
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // 2. تحسين حقول الإدخال (TextFields)
        styleTextField(emailTextField, iconName: "envelope", placeholder: "Username or Email")
        styleTextField(passwordTextField, iconName: "lock", placeholder: "Password")
        
        // 3. تحسين زر تسجيل الدخول (Sign In)
        if let btn = signInButton {
            btn.backgroundColor = brandColor
            btn.setTitle("Sign In", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 12
            // إضافة ظل للزر
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 6
        }
        
        // 4. تحسين الأزرار الثانوية
        if let regBtn = registerButton {
            regBtn.setTitleColor(brandColor, for: .normal)
            regBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        
        if let forgotBtn = forgotPasswordButton {
            forgotBtn.setTitleColor(.gray, for: .normal)
            forgotBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
        
        // 5. تحسين الشعار (اختياري)
        if let logo = logoImageView {
            // إضافة ظل خفيف للشعار ليعطي عمقاً
            logo.layer.shadowColor = UIColor.black.cgColor
            logo.layer.shadowOpacity = 0.1
            logo.layer.shadowOffset = CGSize(width: 0, height: 5)
            logo.layer.shadowRadius = 5
        }
    }
    
    // دالة مساعدة لتصميم الحقول
    private func styleTextField(_ textField: UITextField, iconName: String, placeholder: String) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5) // لون رمادي فاتح جداً
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        
        // إضافة أيقونة
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
        let iconImageView = UIImageView(frame: CGRect(x: 10, y: 15, width: 20, height: 20))
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = brandColor // تلوين الأيقونة بلون البراند
        iconImageView.contentMode = .scaleAspectFit
        iconView.addSubview(iconImageView)
        
        textField.leftView = iconView
        textField.leftViewMode = .always
        
        // زيادة ارتفاع الحقل (يجب التأكد من الستوري بورد أن الارتفاع 50، لكن هذا الكود يضمن التصميم الداخلي)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Logic (لم يتم تغيير أي حرف هنا) 👇👇👇

    @IBAction func signInPressed(_ sender: UIButton) {

        guard let input = emailTextField.text, !input.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please fill all fields")
            return
        }

        // 1. التحقق إذا كان الحساب هو الأدمن
        if (input == adminEmail || input == adminUsername),
           password == adminPassword {
            navigateToAdmin()
            return
        }

        // 2. تسجيل دخول مستخدم عادي (Seeker أو Provider)
        loginUser(emailOrUsername: input, password: password)
    }

    private func loginUser(emailOrUsername: String, password: String) {
        if emailOrUsername.contains("@") {
            firebaseLogin(email: emailOrUsername, password: password)
        } else {
            fetchEmailFromUsername(username: emailOrUsername) { email in
                guard let email = email else {
                    self.showAlert("Username not found")
                    return
                }
                self.firebaseLogin(email: email, password: password)
            }
        }
    }

    private func firebaseLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if error != nil {
                // Here we triggered the custom alert instead of the system error
                self.showLoginError()
                return
            }
            // فحص الرول والتوجيه بعد نجاح تسجيل الدخول
            self.checkUserRoleAndRedirect()
        }
    }

    // New function to match the requested design exactly
    private func showLoginError() {
        let alert = UIAlertController(title: "Login Error", message: "The provided credentials are incorrect.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default))
        present(alert, animated: true)
    }

    private func checkUserRoleAndRedirect() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            
            if let error = error {
                self.showAlert("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let role = data["role"] as? String else {
                self.showAlert("User role not found in database.")
                return
            }

            // ✅ الوصول للـ SceneDelegate لتغيير الستوري بورد بالكامل
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                
                if role.lowercased() == "provider" {
                    // سيفتح ملف Provider.storyboard الحقيقي
                    sceneDelegate.navigateToStoryboard("Provider")
                } else {
                    // سيفتح ملف Seeker.storyboard الحقيقي
                    sceneDelegate.navigateToStoryboard("Seeker")
                }
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
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
