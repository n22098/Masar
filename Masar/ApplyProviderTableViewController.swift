import UIKit
import UniformTypeIdentifiers

class ApplyProviderTableViewController: UITableViewController, UIDocumentPickerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var skillLevelMenu: UIButton!
    @IBOutlet weak var categoryMenu: UIButton!
    @IBOutlet weak var registerBtn: UIBarButtonItem!
    @IBOutlet weak var tellusTxtField: UITextView!

    // MARK: - Data
    private let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    private let categories = ["IT Teaching", "Digital Services"]

    private var selectedSkillLevel: String?
    private var selectedCategory: String?

    private var idCardURL: URL?
    private var certificateURL: URL?
    private var portfolioURL: URL?

    private var currentUploadType: UploadType?

    enum UploadType {
        case idCard
        case certificate
        case portfolio
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenus()
        registerBtn.isEnabled = false
    }

    // MARK: - Setup Menus
    private func setupMenus() {

        // Skill Level Menu
        let skillActions = skillLevels.map { level in
            UIAction(title: level) { _ in
                self.selectedSkillLevel = level
                self.skillLevelMenu.setTitle(level, for: .normal)
                self.updateRegisterButtonState()
            }
        }
        skillLevelMenu.menu = UIMenu(children: skillActions)
        skillLevelMenu.showsMenuAsPrimaryAction = true

        // Category Menu
        let categoryActions = categories.map { category in
            UIAction(title: category) { _ in
                self.selectedCategory = category
                self.categoryMenu.setTitle(category, for: .normal)
                self.updateRegisterButtonState()
            }
        }
        categoryMenu.menu = UIMenu(children: categoryActions)
        categoryMenu.showsMenuAsPrimaryAction = true
    }

    // MARK: - Table Selection (Uploads)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        // Section 2 = Upload Documents
        guard indexPath.section == 2 else { return }

        switch indexPath.row {
        case 0:
            currentUploadType = .idCard
        case 1:
            currentUploadType = .certificate
        case 2:
            currentUploadType = .portfolio
        default:
            return
        }

        openDocumentPicker()
    }

    // MARK: - Document Picker
    private func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .image],
            asCopy: true
        )
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let url = urls.first,
              let type = currentUploadType else { return }

        switch type {
        case .idCard:
            idCardURL = url
            updateCell(section: 2, row: 0, text: url.lastPathComponent)

        case .certificate:
            certificateURL = url
            updateCell(section: 2, row: 1, text: url.lastPathComponent)

        case .portfolio:
            portfolioURL = url
            updateCell(section: 2, row: 2, text: url.lastPathComponent)
        }

        updateRegisterButtonState()
    }

    // MARK: - Helpers
    private func updateCell(section: Int, row: Int, text: String) {
        let indexPath = IndexPath(row: row, section: section)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = text
            cell.detailTextLabel?.textColor = .systemBlue
        }
    }

    private func updateRegisterButtonState() {
        registerBtn.isEnabled =
            selectedSkillLevel != nil &&
            selectedCategory != nil &&
            idCardURL != nil
    }

    // MARK: - Register
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "Success",
            message: "Provider request submitted successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
