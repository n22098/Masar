import UIKit
import QuickLook


class ProviderRequestTVC: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var skillsLevelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var documentURLs: [URL] = []
    
    // بيانات تجريبية
    var sampleRequest = ProviderRequest(
        name: "Jane Doe",
        email: "jane.doe@example.com",
        phone: "+1 (555) 123-4567",
        category: "Graphic Design",
        skillLevel: "Expert / 5+ Years",
        status: "Pending Review"
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMockDocuments()
    }
    
    private func setupUI() {
        // إعداد النصوص من البيانات
        providerNameLabel?.text = sampleRequest.name
        emailLabel?.text = sampleRequest.email
        phoneLabel?.text = sampleRequest.phone
        categoryLabel?.text = sampleRequest.category
        skillsLevelLabel?.text = sampleRequest.skillLevel
        
        // تحديث لون وحالة النص
        updateStatusUI(status: sampleRequest.status)
        
        // إعداد الجدول
        tableView.tableFooterView = UIView()
    }
    
    // دالة مساعدة لتحديث لون الحالة
    private func updateStatusUI(status: String) {
        statusLabel?.text = status
        
        switch status {
        case "Approved":
            statusLabel?.textColor = .systemGreen
        case "Rejected":
            statusLabel?.textColor = .systemRed
        default:
            statusLabel?.textColor = .systemOrange
        }
    }
    
    private func setupMockDocuments() {
        // أسماء ملفات PDF في المشروع
        let fileNames = ["id_sample", "certificate_sample", "portfolio_sample"]
        
        documentURLs = fileNames.compactMap { name in
            Bundle.main.url(forResource: name, withExtension: "pdf")
        }
        
        // استخدام ملف احتياطي في حال عدم وجود الملفات المحددة
        if documentURLs.isEmpty {
            if let fallback = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
                documentURLs = [fallback, fallback, fallback]
            }
        }
    }
    
    // MARK: - IBActions (Approve / Reject Logic)
    
    @IBAction func approveTapped(_ sender: UIButton) {
        // إظهار رسالة تأكيد القبول
        showAlert(title: "Confirm Approval",
                  message: "Are you sure you want to approve this provider?",
                  actionTitle: "Approve",
                  actionStyle: .default) { [weak self] in
            // ✅ الآن هذا السطر سيعمل لأن status أصبحت var
            self?.sampleRequest.status = "Approved"
            self?.updateStatusUI(status: "Approved")
        }
    }
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        // إظهار رسالة تأكيد الرفض
        showAlert(title: "Confirm Rejection",
                  message: "Are you sure you want to reject this provider?",
                  actionTitle: "Reject",
                  actionStyle: .destructive) { [weak self] in
            // ✅ الآن هذا السطر سيعمل لأن status أصبحت var
            self?.sampleRequest.status = "Rejected"
            self?.updateStatusUI(status: "Rejected")
        }
    }
    
    // MARK: - Helper Alert Function
    private func showAlert(title: String, message: String, actionTitle: String, actionStyle: UIAlertAction.Style, completion: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // زر الإلغاء
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // زر التأكيد
        alert.addAction(UIAlertAction(title: actionTitle, style: actionStyle, handler: { _ in
            completion()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Document View Actions
    
    @IBAction func viewIDCardTapped(_ sender: UIButton) {
        showPreview(for: 0)
    }
    
    @IBAction func viewCertificateTapped(_ sender: UIButton) {
        showPreview(for: 1)
    }
    
    @IBAction func viewPortfolioTapped(_ sender: UIButton) {
        showPreview(for: 2)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showPreview(for index: Int) {
        guard index < documentURLs.count else {
            let alert = UIAlertController(title: "No Document", message: "This document is not available for preview.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = index
        present(previewController, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource
extension ProviderRequestTVC: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return documentURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURLs[index] as QLPreviewItem
    }
}
