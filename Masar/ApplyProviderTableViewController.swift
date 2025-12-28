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

    // MARK: - Cloudinary Configuration
    // ⚠️ REPLACE THESE WITH YOUR ACTUAL VALUES ⚠️
    private let cloudName = "dsjx9ehz2"  // Example: "dxxxxxxxxxxxx"
    private let apiKey = "598938434737516"  // Example: "123456789012345"
    private let apiSecret = "0Eyox42LzqrMjwvxpPbqx2SNk5Y"  // Example: "abcdefghijklmnopqrstuvwxyz"
    
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
        // Initialize with API credentials for signed uploads
        let config = CLDConfiguration(cloudName: cloudName, apiKey: apiKey, apiSecret: apiSecret, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
        print("✅ Cloudinary initialized with cloud: \(cloudName)")
    }

    // MARK: - UI Setup
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

    // MARK: - TextView Delegate (Placeholder)
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
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching categories: \(error.localizedDescription)")
                    return
                }
                
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

    // MARK: - Skill Menu
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

    // MARK: - Upload Handling
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
            picker.allowsMultipleSelection = false
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Photo/Image", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }

    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let originalURL = urls.first else { return }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(originalURL.lastPathComponent)

        do {
            try? FileManager.default.removeItem(at: tempURL)
            try FileManager.default.copyItem(at: originalURL, to: tempURL)
            handleFile(tempURL)
        } catch {
            showAlert("Failed to process file. Please try again.", title: "File Error")
        }
    }

    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.7) {

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")

            do {
                try data.write(to: tempURL)
                handleFile(tempURL)
            } catch {
                showAlert("Failed to save image. Please try again.", title: "Image Error")
            }
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

    // MARK: - Validation
    private func validateForm() -> String? {
        if userName?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            return "Please enter your name"
        }
        
        if userEmail?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            return "Please enter your email"
        }
        
        if userPhone?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
            return "Please enter your phone number"
        }
        
        let bioText = tellUsTxt.text.trimmingCharacters(in: .whitespaces)
        if bioText.isEmpty || bioText == "Tell us about yourself..." {
            return "Please tell us about yourself"
        }
        
        if selectedCategory == nil || selectedCategory?.isEmpty ?? true {
            return "Please select a category"
        }
        
        if selectedSkill == nil || selectedSkill?.isEmpty ?? true {
            return "Please select your skill level"
        }
        
        if idCardURL == nil {
            return "Please upload your ID Card"
        }
        
        if portfolioURL == nil {
            return "Please upload your Work Portfolio"
        }
        
        if certificateURL == nil {
            return "Please upload your Certificate"
        }
        
        return nil
    }

    // MARK: - Submit with Signed Upload (NO MORE 401 ERRORS!)
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        
        // Validate form first
        if let errorMessage = validateForm() {
            showAlert(errorMessage, title: "Missing Information")
            return
        }

        guard let uid = Auth.auth().currentUser?.uid ??
                userEmail?.replacingOccurrences(of: "@", with: "_at_")
                    .replacingOccurrences(of: ".", with: "_") else {
            showAlert("Unable to process request. Please try again.", title: "Error")
            return
        }

        // Disable button to prevent double submission
        registerBtn.isEnabled = false

        let loading = UIAlertController(title: nil, message: "Uploading documents...\nPlease wait", preferredStyle: .alert)
        present(loading, animated: true)

        let group = DispatchGroup()
        var uploaded: [String: String] = [:]
        var uploadErrors: [String] = []

        let files: [(key: String, url: URL?)] = [
            ("idCardURL", idCardURL),
            ("portfolioURL", portfolioURL),
            ("certificateURL", certificateURL)
        ]

        for (key, fileURL) in files {
            guard let fileURL = fileURL else {
                print("⚠️ No file for \(key)")
                continue
            }
            
            group.enter()
            print("📤 Uploading \(key): \(fileURL.lastPathComponent)")

            // Read file data
            guard let fileData = try? Data(contentsOf: fileURL) else {
                uploadErrors.append(formatUploadError(key: key, error: "Could not read file"))
                group.leave()
                continue
            }

            // Create signed upload parameters
            let params = CLDUploadRequestParams()
            params.setFolder("provider_applications/\(uid)")
            params.setResourceType(.auto)
            
            // SIGNED UPLOAD - No more 401 errors!
            cloudinary.createUploader().signedUpload(
                data: fileData,
                params: params,
                progress: { progress in
                    let percentage = Int(progress.fractionCompleted * 100)
                    print("⏳ \(key): \(percentage)%")
                }
            ) { result, error in
                
                if let error = error {
                    let errorMsg = error.localizedDescription
                    print("❌ Upload error for \(key): \(errorMsg)")
                    uploadErrors.append(self.formatUploadError(key: key, error: errorMsg))
                    group.leave()
                    return
                }
                
                if let result = result {
                    if let uploadedURL = result.secureUrl ?? result.url {
                        uploaded[key] = uploadedURL
                        print("✅ Successfully uploaded \(key)")
                        print("   URL: \(uploadedURL)")
                    } else {
                        let msg = "No URL returned"
                        print("⚠️ \(key): \(msg)")
                        uploadErrors.append(self.formatUploadError(key: key, error: msg))
                    }
                } else {
                    let msg = "Unknown error"
                    print("⚠️ \(key): \(msg)")
                    uploadErrors.append(self.formatUploadError(key: key, error: msg))
                }
                
                group.leave()
            }
        }

        group.notify(queue: .main) {
            loading.dismiss(animated: true) {
                self.registerBtn.isEnabled = true
                
                if !uploadErrors.isEmpty {
                    print("❌ Upload errors: \(uploadErrors)")
                    self.showUploadErrorAlert(errors: uploadErrors)
                    return
                }
                
                if uploaded.count < 3 {
                    self.showAlert("Failed to upload all documents. Please try again.", title: "Upload Incomplete")
                    return
                }
                
                print("✅ All uploads successful!")
                print("   ID Card: \(uploaded["idCardURL"] ?? "N/A")")
                print("   Portfolio: \(uploaded["portfolioURL"] ?? "N/A")")
                print("   Certificate: \(uploaded["certificateURL"] ?? "N/A")")
                
                self.saveRequest(uid: uid, urls: uploaded)
            }
        }
    }

    // Helper to format upload errors
    private func formatUploadError(key: String, error: String) -> String {
        let displayName: String
        switch key {
        case "idCardURL": displayName = "ID Card"
        case "portfolioURL": displayName = "Work Portfolio"
        case "certificateURL": displayName = "Certificate"
        default: displayName = key
        }
        
        if error.contains("401") || error.contains("Authentication") {
            return "\(displayName): Check your Cloudinary API credentials"
        } else if error.contains("400") {
            return "\(displayName): Invalid file format"
        } else if error.contains("network") || error.contains("internet") {
            return "\(displayName): Check your internet connection"
        } else {
            return "\(displayName): \(error)"
        }
    }

    // Show detailed upload error
    private func showUploadErrorAlert(errors: [String]) {
        let errorMessage = errors.joined(separator: "\n\n")
        
        let alert = UIAlertController(
            title: "Upload Failed",
            message: "Some files couldn't be uploaded:\n\n\(errorMessage)\n\nPlease check your configuration and try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Save to Firestore
    private func saveRequest(uid: String, urls: [String: String]) {

        print("💾 Saving to Firestore...")
        
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

        print("📝 Saving data with URLs:")
        print("   ID Card URL: \(data["idCardURL"] ?? "empty")")
        print("   Portfolio URL: \(data["portfolioURL"] ?? "empty")")
        print("   Certificate URL: \(data["certificateURL"] ?? "empty")")

        Firestore.firestore()
            .collection("provider_requests")
            .document(uid)
            .setData(data) { error in
                if let error = error {
                    print("❌ Firestore error: \(error.localizedDescription)")
                    self.showAlert("Failed to submit application.\n\(error.localizedDescription)", title: "Submission Error")
                } else {
                    print("✅ Successfully saved to Firestore!")
                    self.showSuccessAlert()
                }
            }
    }

    // MARK: - Alerts
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Application Submitted! ✓",
            message: """
            Congratulations! Your provider application has been submitted successfully.
            
            Your application is now under review by our admin team.
            
            You will receive a notification once your request is approved or if we need additional information.
            
            Thank you for your patience!
            """,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateToSignIn()
        })

        present(alert, animated: true)
    }

    private func navigateToSignIn() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }

    private func showAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
