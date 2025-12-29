import UIKit
import FirebaseAuth
import FirebaseFirestore

class PersonalInformationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 245/255, green: 246/255, blue: 250/255, alpha: 1.0)
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 1. حماية من الانهيار
        guard nameTextField != nil, emailTextField != nil,
              phoneNumberTextField != nil, usernameTextField != nil,
              saveButton != nil else { return }
        
        view.backgroundColor = lightBg
        title = "Personal Information"
        
        // 2. إزالة جميع التسميات القديمة (بشكل عميق في كل التسلسل الهرمي)
        removeAllLabelsRecursively(from: view)
        
        // 3. إنشاء حاوية "البطاقة" (Card View)
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // 4. تنظيم الحقول داخل StackView
        let stackView = UIStackView(arrangedSubviews: [nameTextField, emailTextField, phoneNumberTextField, usernameTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        
        // 5. تنسيق زر الحفظ (Save Changes)
        saveButton.backgroundColor = brandColor
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.layer.shadowColor = brandColor.cgColor
        saveButton.layer.shadowOpacity = 0.3
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        saveButton.layer.shadowRadius = 10
        saveButton.addTarget(self, action: #selector(saveBtn(_:)), for: .touchUpInside)
        
        // 6. تطبيق ستايل الحقول
        styleListField(nameTextField, icon: "person.fill", placeholder: "Full Name")
        styleListField(emailTextField, icon: "envelope.fill", placeholder: "Email", isEnabled: false)
        styleListField(phoneNumberTextField, icon: "phone.fill", placeholder: "Phone Number")
        styleListField(usernameTextField, icon: "at", placeholder: "Username", isEnabled: false)
        
        // 7. القيود البرمجية (لضمان التوسيط ومنع التداخل)
        NSLayoutConstraint.activate([
            // البطاقة في منتصف الشاشة (إزاحة بسيطة للأعلى)
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            // محتويات البطاقة
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            // زر الحفظ تحت البطاقة مباشرة
            saveButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.9),
            saveButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func styleListField(_ textField: UITextField, icon: String, placeholder: String, isEnabled: Bool = true) {
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.isUserInteractionEnabled = isEnabled
        textField.textColor = isEnabled ? .black : .systemGray
        textField.font = .systemFont(ofSize: 16)
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 60))
        let iconView = UIImageView(frame: CGRect(x: 12, y: 20, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = brandColor.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        // إضافة الخط الفاصل
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
    
    // MARK: - Helper Method لإزالة جميع الـ Labels بشكل عميق
    private func removeAllLabelsRecursively(from view: UIView) {
        for subview in view.subviews {
            // إذا كان Label وليس له Tag 999، احذفه
            if subview is UILabel && subview.tag != 999 {
                subview.removeFromSuperview()
            } else {
                // ابحث في الطبقات الداخلية أيضاً
                removeAllLabelsRecursively(from: subview)
            }
        }
    }
    
    // MARK: - Logic (Firebase)
    func fetchUserData() {
        guard let uid = uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.nameTextField?.text = data["name"] as? String
                self.emailTextField?.text = data["email"] as? String
                self.phoneNumberTextField?.text = data["phone"] as? String
                self.usernameTextField?.text = data["username"] as? String
            }
        }
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        guard let uid = uid else { return }
        
        // التحقق من ملء جميع الحقول
        guard let name = nameTextField?.text, !name.isEmpty else {
            showPrompt(title: "Warning", message: "Please enter your name")
            return
        }
        
        guard let phone = phoneNumberTextField?.text, !phone.isEmpty else {
            showPrompt(title: "Warning", message: "Please enter your phone number")
            return
        }
        
        // تحديث البيانات في Firebase
        db.collection("users").document(uid).updateData(["name": name, "phone": phone]) { [weak self] error in
            if let error = error {
                self?.showPrompt(title: "Error", message: error.localizedDescription)
            } else {
                self?.showSuccessAndExit()
            }
        }
    }
    
    // MARK: - Alerts
    private func showPrompt(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAndExit() {
        let alert = UIAlertController(title: "Success", message: "Profile updated successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Great", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
