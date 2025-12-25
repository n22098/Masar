import UIKit
import QuickLook

// MARK: - Data Model


class ProviderRequestTVC: UITableViewController {

    // MARK: - IBOutlets
        @IBOutlet weak var providerNameLabel: UILabel!
        @IBOutlet weak var emailLabel: UILabel!
        @IBOutlet weak var phoneLabel: UILabel!
        @IBOutlet weak var categoryLabel: UILabel!
        @IBOutlet weak var skillsLevelLabel: UILabel!
        @IBOutlet weak var statusLabel: UILabel! // <--- أضف هذا السطر وقم بربطه في الـ Storyboard
    // MARK: - Properties
    var documentURLs: [URL] = []
    
    // Sample Data Instance
    var sampleRequest = ProviderRequest(
        name: "Jane Doe",
        email: "jane.doe@example.com",
        phone: "+1 (555) 123-4567",
        category: "Graphic Design",
        skillLevel: "Expert / 5+ Years",
        status: "Pending Review"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMockDocuments()
    }

    private func setupUI() {
        // Optional chaining (?) prevents crashes if Storyboard outlets are disconnected
        providerNameLabel?.text = sampleRequest.name
        emailLabel?.text = sampleRequest.email
        phoneLabel?.text = sampleRequest.phone
        categoryLabel?.text = sampleRequest.category
        skillsLevelLabel?.text = sampleRequest.skillLevel
        statusLabel?.text = sampleRequest.status
        statusLabel?.textColor = .systemOrange
    }

    private func setupMockDocuments() {
        // Names of PDF files you should add to your Xcode project
        let fileNames = ["id_sample", "certificate_sample", "portfolio_sample"]
        
        documentURLs = fileNames.compactMap { name in
            Bundle.main.url(forResource: name, withExtension: "pdf")
        }
        
        // Fallback: uses 'sample.pdf' if specific files aren't found
        if documentURLs.isEmpty {
            if let fallback = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
                documentURLs = [fallback, fallback, fallback]
            }
        }
    }

    // MARK: - IBActions (Approve/Reject)
    @IBAction func approveTapped(_ sender: UIButton) {
        statusLabel?.text = "Approved"
        statusLabel?.textColor = .systemGreen
    }

    @IBAction func rejectTapped(_ sender: UIButton) {
        statusLabel?.text = "Rejected"
        statusLabel?.textColor = .systemRed
    }

    // MARK: - Document View Actions
    // Connect these to the "View" buttons in your Storyboard
    
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

        // Logic for tapping the row itself (Section 3)
        if indexPath.section == 3 {
            if indexPath.row < documentURLs.count {
                showPreview(for: indexPath.row)
            }
        }
    }

    private func showPreview(for index: Int) {
        guard index < documentURLs.count else {
            print("Error: Document at index \(index) not found.")
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
