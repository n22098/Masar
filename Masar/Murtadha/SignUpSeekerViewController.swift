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
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    let db = Firestore.firestore()
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupPasswordToggle(for: passwordTextField)
        setupPasswordToggle(for: confirmPasswordTextField)
        setupProfessionalUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // إعادة السويتش لوضعه الطبيعي عند العودة لهذه الصفحة
        applyAsProviderSwitch.setOn(false, animated: false)
    }
    
    // MARK: - 🎨 Professional UI Setup
    private func setupProfessionalUI() {
        // إخفاء الكيبورد عند الضغط في الخارج
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.backgroundColor = .systemBackground

        // تنسيق الحقول
        styleTextField(nameTextField, iconName: "person")
        styleTextField(emailTextField, iconName: "envelope")
        styleTextField(phoneNumberTextField, iconName: "phone")
        styleTextField(usernameTextField, iconName: "at")
        styleTextField(passwordTextField, iconName: "lock")
        styleTextField(confirmPasswordTextField, iconName: "lock.shield")
        
        // تنسيق زر التسجيل
        if let btn = signUpButton {
            btn.backgroundColor = brandColor
            btn.setTitle("Sign Up", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            btn.layer.cornerRadius = 14
            btn.layer.shadowColor = brandColor.cgColor
            btn.layer.shadowOpacity = 0.4
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 8
        }
        
        // لون زر التبديل
        applyAsProviderSwitch.onTintColor = brandColor
        
        // تنسيق الشعار
        logoImageView?.contentMode = .scaleAspectFit
    }
    
    private func styleTextField(_ textField: UITextField, iconName: String) {
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.4)
        textField.textColor = .label
        
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

    // MARK: - Delegates Setup
    private func setupDelegates() {
        let textFields = [nameTextField, emailTextField, phoneNumberTextField, usernameTextField, passwordTextField, confirmPasswordTextField]
        for (index, textField) in textFields.enumerated() {
            textField?.delegate = self
            textField?.tag = index
            if textField == confirmPasswordTextField {
                textField?.returnKeyType = .go
            } else {
                textField?.returnKeyType = .next
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = self.view.viewWithTag(nextTag) as? UITextField {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            // إذا ضغط Enter في آخر حقل، يحاول التسجيل
            signUpBtn(UIButton())
        }
        return true
    }
    
    // MARK: - Actions

    // 1. زر التسجيل العادي (للسيكر)
    @IBAction func signUpBtn(_ sender: UIButton) {
        // إذا كان السويتش مفعلاً، نمنع التسجيل من هنا ونطلب منه استخدام السويتش للانتقال
        if applyAsProviderSwitch.isOn {
            showAlert("Please wait while we redirect you to provider application, or turn off the switch to register as a regular user.")
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
            // إنشاء المستخدم في Firebase Auth
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert("Error: \(error.localizedDescription)")
                    return
                }
                guard let uid = authResult?.user.uid else { return }
                
                // حفظ البيانات في Firestore كـ Seeker
                let userData: [String: Any] = [
                    "uid": uid, "name": name, "email": email, "username": username, "phone": phone,
                    "role": "seeker", "createdAt": FieldValue.serverTimestamp()
                ]
                self.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        self.showAlert("Failed: \(error.localizedDescription)")
                    } else {
                        self.showSuccessAndRedirect()
                    }
                }
            }
        }
    }

    // 2. زر التبديل (للانتقال لصفحة البروفايدر) - 🔥 تم التعديل هنا 🔥
    @IBAction func switchBtn(_ sender: UISwitch) {
        // إذا أغلق المستخدم السويتش، لا تفعل شيئاً
        guard sender.isOn else { return }
        
        // التحقق من صحة البيانات أولاً
        guard validateInputs() else {
            sender.setOn(false, animated: true) // إرجاع الزر لوضعه الطبيعي
            return
        }

        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneNumberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!

        // التحقق من عدم وجود المستخدم مسبقاً
        checkIfUserDataExists(email: email, username: username, phone: phone) { exists in
            if exists {
                self.showAlert("Email, Username, or Phone Number is already in use.")
                sender.setOn(false, animated: true)
                return
            }
            
            // 🔥 الانتقال للصفحة التالية باستخدام Storyboard ID
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // تأكد من وضع ID للشاشة الثانية باسم "ApplyProviderTableViewController" في الستوري بورد
            if let providerVC = storyboard.instantiateViewController(withIdentifier: "ApplyProviderTableViewController") as? ApplyProviderTableViewController {
                
                // نقل البيانات
                providerVC.userName = name
                providerVC.userEmail = email
                providerVC.userPhone = phone
                providerVC.userUsername = username
                providerVC.userPassword = password
                
                // محاولة الانتقال (Push أو Modal)
                if let nav = self.navigationController {
                    nav.pushViewController(providerVC, animated: true)
                } else {
                    providerVC.modalPresentationStyle = .fullScreen
                    self.present(providerVC, animated: true, completion: nil)
                }
                
            } else {
                // رسالة خطأ للمطور إذا نسيت وضع الـ ID
                self.showAlert("Development Error: Please set Storyboard ID 'ApplyProviderTableViewController' in Main.storyboard")
                sender.setOn(false, animated: true)
            }
        }
    }
    
    // MARK: - Helpers
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
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 10)
        button.configuration = config
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
        } else if sender == passwordTextField.rightView as? UIButton {
            passwordTextField.isSecureTextEntry.toggle()
        } else if sender == confirmPasswordTextField.rightView as? UIButton {
            confirmPasswordTextField.isSecureTextEntry.toggle()
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
