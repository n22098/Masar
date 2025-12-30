import UIKit
import SafariServices // لفتح الروابط (صور/PDF)
import FirebaseFirestore

class ProviderRequestTVC: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var skillsLevelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var requestUID: String? // رقم المستخدم القادم من الصفحة السابقة
    let db = Firestore.firestore()
    
    // لتخزين الروابط القادمة من الفايربيس
    var idCardLink: String?
    var certificateLink: String?
    var portfolioLink: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let uid = requestUID {
            fetchRequestDetails(uid: uid)
        }
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        // تفريغ الحقول لحين التحميل
        providerNameLabel.text = "Loading..."
        emailLabel.text = ""
        phoneLabel.text = ""
        categoryLabel.text = ""
        skillsLevelLabel.text = ""
        statusLabel.text = ""
    }
    
    // جلب التفاصيل الحية
    private func fetchRequestDetails(uid: String) {
        db.collection("provider_requests").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            self.providerNameLabel.text = data["name"] as? String
            self.emailLabel.text = data["email"] as? String
            self.phoneLabel.text = data["phone"] as? String
            self.categoryLabel.text = data["category"] as? String
            self.skillsLevelLabel.text = data["skillLevel"] as? String
            
            let status = data["status"] as? String ?? "pending"
            self.updateStatusUI(status: status)
            
            // حفظ الروابط
            self.idCardLink = data["idCardURL"] as? String
            self.certificateLink = data["certificateURL"] as? String
            self.portfolioLink = data["portfolioURL"] as? String
        }
    }
    
    private func updateStatusUI(status: String) {
        statusLabel.text = status.capitalized
        
        switch status.lowercased() {
        case "approved":
            statusLabel.textColor = .systemGreen
        case "rejected":
            statusLabel.textColor = .systemRed
        default:
            statusLabel.textColor = .systemOrange
        }
    }
    
    // MARK: - Actions (Approve / Reject Logic)
    
    @IBAction func approveTapped(_ sender: UIButton) {
        showAlert(title: "Confirm Approval",
                  message: "Approve this provider?",
                  actionTitle: "Approve",
                  actionStyle: .default) {
            self.updateRequestStatus(status: "approved")
        }
    }
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        showAlert(title: "Confirm Rejection",
                  message: "Reject this provider?",
                  actionTitle: "Reject",
                  actionStyle: .destructive) {
            self.updateRequestStatus(status: "rejected")
        }
    }
    
    // تحديث الحالة في الفايربيس
    private func updateRequestStatus(status: String) {
        guard let uid = requestUID else { return }
        
        let batch = db.batch()
        
        // 1. تحديث حالة الطلب
        let requestRef = db.collection("provider_requests").document(uid)
        batch.updateData(["status": status], forDocument: requestRef)
        
        // 2. إذا تم القبول، نحدث حالة المستخدم في جدول Users ليصبح Provider
        if status == "approved" {
            let userRef = db.collection("users").document(uid)
            batch.updateData([
                "role": "provider",
                "providerRequestStatus": "approved"
            ], forDocument: userRef)
        } else if status == "rejected" {
             let userRef = db.collection("users").document(uid)
             batch.updateData([
                 "providerRequestStatus": "rejected"
             ], forDocument: userRef)
        }
        
        // تنفيذ التحديثات
        batch.commit { error in
            if let error = error {
                print("Error updating status: \(error)")
            } else {
                print("Successfully updated status to \(status)")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Document Viewing (Opening URLs)
    
    @IBAction func viewIDCardTapped(_ sender: UIButton) {
        openLink(idCardLink)
    }
    
    @IBAction func viewCertificateTapped(_ sender: UIButton) {
        openLink(certificateLink)
    }
    
    @IBAction func viewPortfolioTapped(_ sender: UIButton) {
        openLink(portfolioLink)
    }
    
    private func openLink(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            let alert = UIAlertController(title: "No Document", message: "Document link is missing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // فتح الرابط في متصفح سفاري داخل التطبيق
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String, actionTitle: String, actionStyle: UIAlertAction.Style, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: actionTitle, style: actionStyle, handler: { _ in
            completion()
        }))
        present(alert, animated: true)
    }
}
