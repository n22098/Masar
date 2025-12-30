import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // بيانات الأدمن الثابتة
    private let adminEmail = "admin@masar.com"
    private let adminUsername = "admin"
    private let adminPassword = "admin123"

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

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
