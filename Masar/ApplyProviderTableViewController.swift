import UIKit
import UniformTypeIdentifiers

class ApplyProviderTableViewController: UITableViewController, UIDocumentPickerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var skillLevelMenu: UIButton!
    @IBOutlet weak var categoryMenu: UIButton!
    @IBOutlet weak var registerBtn: UIBarButtonItem!
    
    @IBOutlet weak var idCardLabel: UILabel!
    @IBOutlet weak var certificateLabel: UILabel!
    @IBOutlet weak var portfolioLabel: UILabel!

    // MARK: - User Data Properties (passed from SignUp)
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var userUsername: String?
    var userPassword: String?

    // MARK: - Properties
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
        configureAppearance()
        displayUserData()
        setupMenus()
        setupUploadLabels()
        updateRegisterButtonState()
    }

    // MARK: - Display User Data
    private func displayUserData() {
        nameLabel.text = userName ?? "N/A"
        emailLabel.text = userEmail ?? "N/A"
        phoneLabel.text = userPhone ?? "N/A"
    }

    // MARK: - Appearance Configuration
    private func configureAppearance() {
        // Table view styling
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // Navigation bar
        title = "Become a Provider"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Register button styling
        registerBtn.tintColor = .systemBlue
    }

    // MARK: - UI Setup
    private func setupMenus() {
        // Skill Level Menu
        configureMenuButton(
            skillLevelMenu,
            placeholder: "Select Skill Level",
            options: skillLevels
        ) { [weak self] level in
            self?.selectedSkillLevel = level
            self?.updateMenuButton(self?.skillLevelMenu, title: level)
        }

        // Category Menu
        configureMenuButton(
            categoryMenu,
            placeholder: "Select Category",
            options: categories
        ) { [weak self] category in
            self?.selectedCategory = category
            self?.updateMenuButton(self?.categoryMenu, title: category)
        }
    }
    
    private func configureMenuButton(
        _ button: UIButton,
        placeholder: String,
        options: [String],
        handler: @escaping (String) -> Void
    ) {
        button.setTitle(placeholder, for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.showsMenuAsPrimaryAction = true
        
        button.menu = UIMenu(children: options.map { option in
            UIAction(title: option) { _ in
                handler(option)
            }
        })
        
        // Add chevron indicator
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .trailing
        config.imagePadding = 8
        button.configuration = config
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .systemGray2
    }
    
    private func updateMenuButton(_ button: UIButton?, title: String) {
        button?.setTitle(title, for: .normal)
        button?.setTitleColor(.label, for: .normal)
        button?.tintColor = .systemBlue
        updateRegisterButtonState()
    }

    private func setupUploadLabels() {
        [idCardLabel, certificateLabel, portfolioLabel].forEach { label in
            label?.text = "Upload"
            label?.font = .systemFont(ofSize: 15, weight: .medium)
            label?.textColor = .systemBlue
            label?.textAlignment = .right
            label?.numberOfLines = 1
            label?.lineBreakMode = .byTruncatingMiddle
        }
    }

    // MARK: - Table View Delegate
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .secondarySystemGroupedBackground
    }

    // MARK: - Document Picker
    private func openDocumentPicker() {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .image],
            asCopy: true
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
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
            updateUploadLabel(idCardLabel, fileName: fileName)

        case .certificate:
            certificateURL = url
            updateUploadLabel(certificateLabel, fileName: fileName)

        case .portfolio:
            portfolioURL = url
            updateUploadLabel(portfolioLabel, fileName: fileName)
        }

        updateRegisterButtonState()
    }
    
    private func updateUploadLabel(_ label: UILabel, fileName: String) {
        label.text = fileName
        label.textColor = .systemGreen
        
        // Add checkmark icon
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen)
        attachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
        
        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " \(fileName)"))
        
        label.attributedText = attributedString
    }

    // MARK: - Register Button
    private func updateRegisterButtonState() {
        let isValid = selectedSkillLevel != nil &&
                      selectedCategory != nil &&
                      idCardURL != nil
        
        registerBtn.isEnabled = isValid
        registerBtn.tintColor = isValid ? .systemBlue : .systemGray
    }

    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Here you would normally create the provider account with Firebase
        // using the stored user data (userName, userEmail, etc.)
        // and provider-specific info (skillLevel, category, documents)
        
        let alert = UIAlertController(
            title: "Success",
            message: "Your provider request has been submitted successfully. We'll review your application and get back to you soon.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Go back to sign in screen (pop to root)
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Section Headers
extension ApplyProviderTableViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Your Information"
        case 1: return "Request Details"
        case 2: return "Required Documents"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2: return "ID Card is required. Certificate and portfolio are optional but recommended."
        default: return nil
        }
    }
}
