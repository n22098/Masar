import UIKit
import SafariServices
import FirebaseFirestore

class ProviderRequestTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var skillsLevelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var requestUID: String?
    let db = Firestore.firestore()
    
    var idCardLink: String?
    var certificateLink: String?
    var portfolioLink: String?
    
    private var fullRequestData: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = requestUID {
            fetchRequestDetails(uid: uid)
        }
    }
    
    // MARK: - Firebase Fetching
    private func fetchRequestDetails(uid: String) {
        db.collection("provider_requests").document(uid).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data() else { return }
            self.fullRequestData = data
            
            self.providerNameLabel.text = data["name"] as? String
            self.emailLabel.text = data["email"] as? String
            self.phoneLabel.text = data["phone"] as? String
            self.categoryLabel.text = data["category"] as? String
            self.skillsLevelLabel.text = data["skillLevel"] as? String
            
            let status = data["status"] as? String ?? "pending"
            self.updateStatusUI(status: status) // ✅ تم إصلاح الخطأ هنا بإضافة الدالة بالأسفل
            
            self.idCardLink = data["idCardURL"] as? String
            self.certificateLink = data["certificateURL"] as? String
            self.portfolioLink = data["portfolioURL"] as? String
        }
    }

    // ✅ هذه هي الدالة التي كانت مفقودة وتسبب الخطأ
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

    // MARK: - Dual Archive Logic
    // دالة الأرشفة التي تحفظ في المجموعات القديمة والجديدة معاً
    private func finalizeDecision(isApproved: Bool) {
        guard let uid = requestUID, var archiveData = fullRequestData else { return }
        
        let batch = db.batch()
        let finalStatus = isApproved ? "approved" : "rejected"
        let userStatus = isApproved ? "Active" : "Rejected"
        
        // 1️⃣ تحديث المجموعات الأصلية لضمان عمل التطبيق الحالي
        let userRef = db.collection("users").document(uid)
        batch.updateData([
            "status": userStatus,
            "role": isApproved ? "provider" : "seeker"
        ], forDocument: userRef)
        
        let requestRef = db.collection("provider_requests").document(uid)
        batch.updateData(["status": finalStatus], forDocument: requestRef)
        
        // 2️⃣ الإضافة إلى كولكشن الأرشفة الجديد (معلومات كاملة للأدمن)
        archiveData["admin_decision_date"] = FieldValue.serverTimestamp()
        archiveData["final_status"] = finalStatus
        
        // إنشاء اسم الكولكشن الجديد حسب القرار
        let newPath = isApproved ? "archived_approved_requests" : "archived_rejected_requests"
        let archiveRef = db.collection(newPath).document(uid)
        
        batch.setData(archiveData, forDocument: archiveRef)
        
        batch.commit { [weak self] error in
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Actions
    @IBAction func approveTapped(_ sender: UIButton) {
        finalizeDecision(isApproved: true)
    }
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        finalizeDecision(isApproved: false)
    }
    
    // MARK: - Helpers
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // (دوال عرض الملفات تبقى كما هي...)
    @IBAction func viewIDCardTapped(_ sender: UIButton) { openLink(idCardLink) }
    @IBAction func viewCertificateTapped(_ sender: UIButton) { openLink(certificateLink) }
    @IBAction func viewPortfolioTapped(_ sender: UIButton) { openLink(portfolioLink) }
    
    private func openLink(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
