import UIKit
import UniformTypeIdentifiers

class ApplyProviderTableViewController: UITableViewController, UIDocumentPickerDelegate {

    // MARK: - IBOutlets (Menus)
    @IBOutlet weak var skillLevelMenu: UIButton!
    @IBOutlet weak var categoryMenu: UIButton!
    @IBOutlet weak var registerBtn: UIBarButtonItem!
    @IBOutlet weak var tellusTxtField: UITextView!

    // MARK: - Upload Labels
    @IBOutlet weak var idCardLabel: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!
    @IBOutlet weak var portfolioLabel: UILabel!

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
        setupLabels()
        updateRegisterButtonState()
    }

    // MARK: - Setup
    private func setupMenus() {

        let skillActions = skillLevels.map { level in
            UIAction(title: level) { _ in
                self.selectedSkillLevel = level
                self.skillLevelMenu.setTitle(level, for: .normal)
                self.updateRegisterButtonState()
            }
        }
        skillLevelMenu.menu = UIMenu(children: skillActions)
        skillLevelMenu.showsMenuAsPrimaryAction = true

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

    private func setupLabels() {
        [idCardLabel, certificateLabel, portfolioLabel].forEach {
            $0?.text = "No file"
            $0?.textColor = .systemGray
            $0?.textAlignment = .right
        }
    }

    // MARK: - Upload Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 2 {
            switch indexPath.row {
            case 0: currentUploadType = .idCard
            case 1: currentUploadType = .certificate
            case 2: currentUploadType = .portfolio
            default: return
            }
            openDocumentPicker()
        }
    }

    // MARK: - Document Picker
    private func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.pdf, UTType.image],
            asCopy: true
        )
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let type = currentUploadType else { return }

        let fileName = url.lastPathComponent

        switch type {
        case .idCard:
            idCardURL = url
            idCardLabel.text = fileName
            idCardLabel.textColor = .systemBlue

        case .certificate:
            certificateURL = url
            certificateLabel.text = fileName
            certificateLabel.textColor = .systemBlue

        case .portfolio:
            portfolioURL = url
            portfolioLabel.text = fileName
            portfolioLabel.textColor = .systemBlue
        }

        updateRegisterButtonState()
    }

    // MARK: - Register Button State
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
