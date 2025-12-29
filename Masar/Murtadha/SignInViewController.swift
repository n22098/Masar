import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - Admin Credentials (بيانات الأدمن الثابتة)
    // يمكنك تغيير هذه البيانات لما يناسبك
    private let adminEmail = "admin@masar.com"
    private let adminUsername = "admin" // اختياري إذا كنت تريد الدخول باليوزر
    private let adminPassword = "admin123"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // إعدادات حقول النص (اختياري)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        // إعداد أيقونة العين للباسورد
        setupPasswordToggle()
    }

    // MARK: - Actions
    @IBAction func signInPressed(_ sender: UIButton) {
        
        guard let input = emailTextField.text, !input.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please fill in all fields.")
            return
        }

        // 1. التحقق أولاً: هل هو الأدمن؟
        if (input == adminEmail || input == adminUsername) && password == adminPassword {
            print("👑 Admin Login Detected!")
            navigateToAdminDashboard()
            return
        }

        // 2. إذا لم يكن أدمن، أكمل تسجيل الدخول العادي عبر Firebase
        loginUser(emailOrUsername: input, password: password)
    }

    @IBAction func registerPressed(_ sender: UIButton) {
        // الانتقال لصفحة التسجيل (هذا الكود موجود عندك مسبقاً في الستوري بورد غالباً)
    }

    @IBAction func forgetPasswordPressed(_ sender: UIButton) {
        // كود نسيت كلمة المرور
    }

    // MARK: - Login Logic
    private func loginUser(emailOrUsername: String, password: String) {
        
        // التحقق هل المدخل إيميل أم اسم مستخدم
        if emailOrUsername.contains("@") {
            // تسجيل دخول بالإيميل مباشرة
            performFirebaseAuth(email: emailOrUsername, password: password)
        } else {
            // تسجيل دخول باسم المستخدم (يحتاج بحث عن الإيميل أولاً)
            fetchEmailFromUsername(username: emailOrUsername) { email in
                guard let email = email else {
                    self.showAlert("Username not found.")
                    return
                }
                self.performFirebaseAuth(email: email, password: password)
            }
        }
    }

    private func performFirebaseAuth(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(error.localizedDescription)
                return
            }
            
            // نجح الدخول، الآن نفحص الرول (Role) لتوجيه المستخدم
            self.checkUserRoleAndRedirect()
        }
    }
    
    // MARK: - Navigation & Redirects
    
    // دالة توجيه الأدمن 👑
    private func navigateToAdminDashboard() {
        // تأكد أن اسم ملف الستوري بورد هو "admin" (حرف صغير أو كبير حسب الملف عندك)
        let storyboard = UIStoryboard(name: "admin", bundle: nil)
        
        // الخيار الأول: إذا كان هو الـ Initial View Controller (عليه سهم دخول)
        if let adminVC = storyboard.instantiateInitialViewController() {
            setRootViewController(adminVC)
        }
        // الخيار الثاني: إذا كنت معطيه Storyboard ID (مثلاً "AdminHome")
        // else if let adminVC = storyboard.instantiateViewController(withIdentifier: "AdminHome") {
        //    setRootViewController(adminVC)
        // }
        else {
            showAlert("Could not find Admin Dashboard. Check Storyboard name.")
        }
    }

    // دالة توجيه المستخدمين العاديين (Seeker/Provider)
    private func checkUserRoleAndRedirect() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.showAlert("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(), let role = data["role"] as? String else {
                self.showAlert("User role not found.")
                return
            }
            
            if role == "provider" {
                self.navigateToStoryboard(name: "Provider")
            } else {
                self.navigateToStoryboard(name: "Seeker")
            }
        }
    }
    
    private func navigateToStoryboard(name: String) {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            setRootViewController(vc)
        }
    }
    
    private func setRootViewController(_ vc: UIViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = windowScene.delegate as? SceneDelegate,
           let window = delegate.window {
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    // MARK: - Helpers
    
    // دالة البحث عن الإيميل باستخدام اسم المستخدم
    private func fetchEmailFromUsername(username: String, completion: @escaping (String?) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let document = snapshot?.documents.first {
                    let email = document.data()["email"] as? String
                    completion(email)
                } else {
                    completion(nil)
                }
            }
    }

    private func setupPasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        
        // إضافة مسافة للهامش الأيمن
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        containerView.addSubview(button)
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }
    
    @objc private func togglePassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
