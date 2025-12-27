import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton! // هذا هو زر الحفظ
    
    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 245/255, green: 246/255, blue: 250/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        guard currentPasswordTextField != nil, newPasswordTextField != nil,
              confirmPasswordTextField != nil, resetButton != nil else { return }
        
        view.backgroundColor = lightBg
        title = "Reset Password"
        
        // 1. حاوية البطاقة (Card View)
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // 2. تنظيم الحقول داخل StackView
        let stackView = UIStackView(arrangedSubviews: [currentPasswordTextField, newPasswordTextField, confirmPasswordTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        
        // 3. تنسيق الزر (Save & Reset)
        resetButton.backgroundColor = brandColor
        resetButton.setTitle("Update Password", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 25
        resetButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.layer.shadowColor = brandColor.cgColor
        resetButton.layer.shadowOpacity = 0.3
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        resetButton.layer.shadowRadius = 10
        
        // 4. ستايل الحقول
        styleListField(currentPasswordTextField, icon: "lock.fill", placeholder: "Current Password")
        styleListField(newPasswordTextField, icon: "key.fill", placeholder: "New Password")
        styleListField(confirmPasswordTextField, icon: "checkmark.shield.fill", placeholder: "Confirm New Password")
        
        // 5. قيود التصميم (توسيط ورفع للأعلى)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            resetButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 35),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.9),
            resetButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func styleListField(_ textField: UITextField, icon: String, placeholder: String) {
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.placeholder = placeholder
        textField.textColor = .black
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 60))
        let iconView = UIImageView(frame: CGRect(x: 12, y: 20, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = brandColor.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.systemGray6
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 45),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @IBAction func resetPasswordBtn(_ sender: UIButton) {
        performUpdateLogic()
    }
    
    private func performUpdateLogic() {
        guard let currentPw = currentPasswordTextField.text, !currentPw.isEmpty,
              let newPw = newPasswordTextField.text, !newPw.isEmpty,
              let confirmPw = confirmPasswordTextField.text, !confirmPw.isEmpty else {
            showPrompt(title: "تنبيه", message: "يرجى ملء جميع الحقول")
            return
        }
        
        if newPw != confirmPw {
            showPrompt(title: "تنبيه", message: "كلمات المرور الجديدة غير متطابقة")
            return
        }
        
        // منطق Firebase لتغيير كلمة المرور
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPw)
        
        // إعادة التحقق من كلمة المرور القديمة أولاً
        user?.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                self?.showPrompt(title: "خطأ", message: "كلمة المرور الحالية غير صحيحة")
                print(error.localizedDescription)
                return
            }
            
            // تحديث كلمة المرور
            user?.updatePassword(to: newPw) { error in
                if let error = error {
                    self?.showPrompt(title: "خطأ", message: error.localizedDescription)
                } else {
                    self?.showSuccessAndExit()
                }
            }
        }
    }
    
    // MARK: - Alerts
    private func showPrompt(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "حسناً", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAndExit() {
        let alert = UIAlertController(title: "تم بنجاح", message: "تم تحديث كلمة المرور بنجاح!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ممتاز", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
