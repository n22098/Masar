import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReportIssueTVC: UITableViewController {

    // MARK: - IBOutlets
    // ملاحظة: تأكد من تغيير نوع الـ Outlets في الـ Storyboard لتتوافق مع الأنواع الجديدة
    @IBOutlet weak var reportIDLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel! // سيعرض اسم المستخدم الحالي
    @IBOutlet weak var emailLabel: UILabel!    // سيعرض إيميل المستخدم الحالي
    
    @IBOutlet weak var subjectTextField: UITextField! // تم تغييره ليصبح حقل إدخال
    @IBOutlet weak var descriptionTextView: UITextView! // تم تغييره ليصبح مساحة نصية للكتابة

    // ألوان الهوية البصرية
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
    
    let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModernUI()
        loadUserProfile() // جلب بيانات المستخدم من Firebase
        generateReportID()
    }

    // MARK: - 🎨 Modern UI Setup
    private func setupModernUI() {
        self.title = "Report Issue"
        
        // إعداد النافيجيشن بار
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // إعداد الجدول
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none
        
        // تحسين مظهر TextView الوصف
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.text = "" // البدء بمساحة فارغة للكتابة
        
        // إضافة زر إرسال في النافيجيشن بار
        let submitButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitReport))
        navigationItem.rightBarButtonItem = submitButton
    }

    private func generateReportID() {
        let randomID = Int.random(in: 1000...9999)
        reportIDLabel.text = "#RM-\(randomID)"
    }

    // جلب بيانات المستخدم من Firebase Profile
    private func loadUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.reporterLabel.text = data?["fullName"] as? String ?? "Unknown User"
                self.emailLabel.text = data?["email"] as? String ?? "No Email"
            }
        }
    }

    // MARK: - Firebase Actions
    @objc private func submitReport() {
        guard let subject = subjectTextField.text, !subject.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(message: "Please fill in the subject and description.")
            return
        }

        let reportData: [String: Any] = [
            "reportID": reportIDLabel.text ?? "",
            "reporter": reporterLabel.text ?? "",
            "email": emailLabel.text ?? "",
            "subject": subject,
            "description": description,
            "timestamp": FieldValue.serverTimestamp(),
            "status": "New"
        ]

        // إرسال البيانات إلى مجموعة "reports" ليراها الأدمن
        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                self.showAlert(message: "Error submitting report: \(error.localizedDescription)")
            } else {
                let alert = UIAlertController(title: "Success", message: "Your issue has been reported.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Navigation
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
