import UIKit
import QuickLook // Required for document viewing

class ProviderRequestTVC: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var skillsLevelLabel: UILabel!

    // MARK: - Properties
    // This array will hold the URLs for ID Card, Certificate, and Work Portfolio
    var documentURLs: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMockDocuments()
    }

    private func setupMockDocuments() {
        // Replace these with actual URLs from your data source/API
        // For now, we use a placeholder to prevent crashes
        if let placeholder = Bundle.main.url(forResource: "sample", withExtension: "pdf") {
            documentURLs = [placeholder, placeholder, placeholder]
        }
    }

    // MARK: - IBActions
    @IBAction func approveTapped(_ sender: UIButton) {
        statusLabel.text = "Approved"
        statusLabel.textColor = .systemGreen
    }

    @IBAction func rejectTapped(_ sender: UIButton) {
        statusLabel.text = "Rejected"
        statusLabel.textColor = .systemRed
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // "Uploaded Documents" is the 4th section (index 3) in your storyboard
        if indexPath.section == 3 {
            showPreview(for: indexPath.row)
        }
    }

    private func showPreview(for index: Int) {
        guard index < documentURLs.count else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = index
        present(previewController, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource
// ONLY keep these methods here. Remove any duplicates inside the main class.
extension ProviderRequestTVC: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return documentURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURLs[index] as QLPreviewItem
    }
}
