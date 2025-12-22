import UIKit
import UniformTypeIdentifiers

class ApplyProviderTableViewController: UITableViewController, UIDocumentPickerDelegate {

    // MARK: - Menus
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
        case idCard, certificate, portfolio
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenus()
        setupUploadLabels()
        updateRegisterButtonState()
    }

    // MARK: - UI Setup
    private func setupMenus() {

        skillLevelMenu.showsMenuAsPrimaryAction = true
        skillLevelMenu.menu = UIMenu(children: skillLevels.map { level in
            UIAction(title: level) { _ in
                self.selectedSkillLevel = level
                self.skillLevelMenu.setTitle(level, for: .normal)
                self.skillLevelMenu.setTitleColor(.systemBlue, for: .normal)
                self.updateRegisterButtonState()
            }
        })

        categoryMenu.showsMenuAsPrimaryAction = true
        categoryMenu.menu = UIMenu(children: categories.map { category in
            UIAction(title: category) { _ in
                self.selectedCategory = category
                self.categoryMenu.setTitle(category, for: .normal)
                self.categoryMenu.setTitleColor(.systemBlue, for: .normal)
                self.updateRegisterButtonState()
            }
        })
    }

    private func setupUploadLabels() {
        [idCardLabel, certificateLabel, portfolioLabel].forEach { label in
            label?.text = ""
            label?.font = .systemFont(ofSize: 15)
            label?.textColor = .systemBlue
            label?.textAlignment = .right
            label?.numberOfLines = 1
            label?.lineBreakMode = .byTruncatingMiddle
        }
    }

    // MARK: - Table Selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.section == 2 else { return }

        switch indexPath.row {
        case 0: currentUploadType = .idCard
        case 1: currentUploadType = .certificate
        case 2: currentUploadType = .portfolio
        default: return
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

        let fileName = url.lastPathComponent

        switch type {
        case .idCard:
            idCardURL = url
            idCardLabel.text = fileName

        case .certificate:
            certificateURL = url
            certificateLabel.text = fileName

        case .portfolio:
            portfolioURL = url
            portfolioLabel.text = fileName
        }

        updateRegisterButtonState()
    }

    // MARK: - Register Button
    private func updateRegisterButtonState() {
        registerBtn.isEnabled =
            selectedSkillLevel != nil &&
            selectedCategory != nil &&
            idCardURL != nil
    }

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
