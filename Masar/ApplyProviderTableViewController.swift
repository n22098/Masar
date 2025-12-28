import UIKit
import UniformTypeIdentifiers
import FirebaseAuth
import FirebaseFirestore
import Cloudinary

class ApplyProviderTableViewController: UITableViewController,
                                       UIImagePickerControllerDelegate,
                                       UINavigationControllerDelegate,
                                       UIDocumentPickerDelegate,
                                       UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tellUsTxt: UITextView!

    @IBOutlet weak var categoryMenu: UIButton!
    @IBOutlet weak var skillLevelMenu: UIButton!
    @IBOutlet weak var registerBtn: UIBarButtonItem!

    @IBOutlet weak var idUpload: UILabel!
    @IBOutlet weak var workPortfolioUpload: UILabel!
    @IBOutlet weak var certificateUpload: UILabel!

    // MARK: - Cloudinary
    private let cloudName = "dsjx9ehz2"
    private let apiKey = "598938434737516"
    private let apiSecret = "0Eyox42LzqrMjwvxpPbqx2SNk5Y"

    private var cloudinary: CLDCloudinary!

    // MARK: - Data
    var userName: String?
    var userEmail: String?
    var userPhone: String?

    private var categories: [String] = []
    private var selectedCategory: String?
    private var selectedSkill: String?

    private var idCardURL: URL?
    private var portfolioURL: URL?
    private var certificateURL: URL?

    private var currentUploadType = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initCloudinary()
        setupUI()
        setupSkillMenu()
        setupLabelTaps()
        fetchCategoriesFromAdmin()
    }

    private func initCloudinary() {
        let config = CLDConfiguration(
            cloudName: cloudName,
            apiKey: apiKey,
            apiSecret: apiSecret,
            secure: true
        )
        cloudinary = CLDCloudinary(configuration: config)
    }

    // MARK: - UI
    private func setupUI() {
        title = "Apply as Provider"
        registerBtn.isEnabled = true

        nameLabel.text = userName
        emailLabel.text = userEmail
        phoneLabel.text = userPhone

        tellUsTxt.delegate = self
        tellUsTxt.layer.cornerRadius = 8
        tellUsTxt.layer.borderWidth = 0.5
        tellUsTxt.layer.borderColor = UIColor.systemGray4.cgColor
        tellUsTxt.text = "Tell us about yourself..."
        tellUsTxt.textColor = .placeholderText

        categoryMenu.setTitle("Select Category", for: .normal)
        skillLevelMenu.setTitle("Skill Level", for: .normal)

        [idUpload, workPortfolioUpload, certificateUpload].forEach {
            $0?.text = "Upload"
            $0?.textColor = .systemBlue
            $0?.isUserInteractionEnabled = true
        }
    }

    // MARK: - TextView Placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about yourself..."
            textView.textColor = .placeholderText
        }
    }

    // MARK: - Categories
    private func fetchCategoriesFromAdmin() {
        Firestore.firestore()
            .collection("categories")
            .getDocuments { snapshot, _ in
                self.categories = snapshot?.documents.compactMap {
                    $0["name"] as? String
                } ?? []

                let actions = self.categories.map { category in
                    UIAction(title: category) { _ in
                        self.selectedCategory = category
                        self.categoryMenu.setTitle(category, for: .normal)
                    }
                }

                self.categoryMenu.menu = UIMenu(children: actions)
                self.categoryMenu.showsMenuAsPrimaryAction = true
            }
    }

    // MARK: - Skills
    private func setupSkillMenu() {
        let levels = ["Beginner", "Intermediate", "Advanced", "Expert"]
        let actions = levels.map { level in
            UIAction(title: level) { _ in
                self.selectedSkill = level
                self.skillLevelMenu.setTitle(level, for: .normal)
            }
        }
        skillLevelMenu.menu = UIMenu(children: actions)
        skillLevelMenu.showsMenuAsPrimaryAction = true
    }

    // MARK: - Upload
    private func setupLabelTaps() {
        idUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(idTapped)))
        workPortfolioUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(portfolioTapped)))
        certificateUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(certTapped)))
    }

    @objc private func idTapped() { currentUploadType = 0; showUploadMenu() }
    @objc private func portfolioTapped() { currentUploadType = 1; showUploadMenu() }
    @objc private func certTapped() { currentUploadType = 2; showUploadMenu() }

    private func showUploadMenu() {
        let alert = UIAlertController(title: "Upload Document", message: "Choose file type", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "PDF Document", style: .default) { _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Photo/Image", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            handleFile(url)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.7) {

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: tempURL)
            handleFile(tempURL)
        }
    }

    private func handleFile(_ url: URL) {
        let name = url.lastPathComponent
        switch currentUploadType {
        case 0:
            idCardURL = url
            idUpload.text = "✓ \(name)"
            idUpload.textColor = .systemGreen
        case 1:
            portfolioURL = url
            workPortfolioUpload.text = "✓ \(name)"
            workPortfolioUpload.textColor = .systemGreen
        case 2:
            certificateURL = url
            certificateUpload.text = "✓ \(name)"
            certificateUpload.textColor = .systemGreen
        default: break
        }
    }

    // MARK: - Submit
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {

        if let errorMessage = validateForm() {
            showAlert(errorMessage, title: "Missing Information")
            return
        }

        let uid = Auth.auth().currentUser?.uid ??
        userEmail!.replacingOccurrences(of: "@", with: "_at_")
            .replacingOccurrences(of: ".", with: "_")

        registerBtn.isEnabled = false

        let loading = UIAlertController(title: nil, message: "Uploading documents...\nPlease wait", preferredStyle: .alert)
        present(loading, animated: true)

        let group = DispatchGroup()
        var uploaded: [String: String] = [:]

        let files = [
            ("idCardURL", idCardURL),
            ("portfolioURL", portfolioURL),
            ("certificateURL", certificateURL)
        ]

        for (key, fileURL) in files {
            guard let fileURL = fileURL else { continue }
            group.enter()

            let params = CLDUploadRequestParams()
            params.setFolder("provider_applications/\(uid)")

            let ext = fileURL.pathExtension.lowercased()
            if ext == "pdf" {
                params.setResourceType(.raw)
            } else {
                params.setResourceType(.image)
            }

            let data = try! Data(contentsOf: fileURL)

            cloudinary.createUploader().signedUpload(data: data, params: params) { result, _ in
                if let url = result?.secureUrl ?? result?.url {
                    uploaded[key] = url
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            loading.dismiss(animated: true) {
                self.saveRequest(uid: uid, urls: uploaded)
            }
        }
    }

    // MARK: - Firestore
    private func saveRequest(uid: String, urls: [String: String]) {

        let bioText = tellUsTxt.textColor == .placeholderText ? "" : tellUsTxt.text ?? ""

        let data: [String: Any] = [
            "uid": uid,
            "name": userName ?? "",
            "email": userEmail ?? "",
            "phone": userPhone ?? "",
            "category": selectedCategory ?? "",
            "skillLevel": selectedSkill ?? "",
            "bio": bioText,
            "idCardURL": urls["idCardURL"] ?? "",
            "portfolioURL": urls["portfolioURL"] ?? "",
            "certificateURL": urls["certificateURL"] ?? "",
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        Firestore.firestore()
            .collection("provider_requests")
            .document(uid)
            .setData(data) { _ in
                self.showSuccessAlert()
            }
    }

    // MARK: - Success Alert (formatted)
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Request Submitted Successfully ✓",
            message: """
            Your account is still active as a Seeker.

            Your request to become a Provider has been sent successfully and is currently under review by our admin team.

            Once your request is approved, your provider features will be activated automatically.

            Thank you for your patience.
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateToSignIn()
        })

        present(alert, animated: true)
    }

    private func navigateToSignIn() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }

    private func showAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Validation
    private func validateForm() -> String? {
        if selectedCategory == nil { return "Please select a category" }
        if selectedSkill == nil { return "Please select your skill level" }
        if idCardURL == nil { return "Please upload your ID Card" }
        if portfolioURL == nil { return "Please upload your Work Portfolio" }
        if certificateURL == nil { return "Please upload your Certificate" }
        return nil
    }
}
