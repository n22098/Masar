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

    // MARK: - Configuration
    private let cloudName = "dsjx9ehz2"
    private let apiKey = "598938434737516"
    private let apiSecret = "0Eyox42LzqrMjwvxpPbqx2SNk5Y" // Note: Keep secrets safe!
    private let uploadPreset = "ml_default"

    private var cloudinary: CLDCloudinary!
    
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Data Variables
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var userUsername: String?
    var userPassword: String?

    private var categories: [String] = []
    private var selectedCategory: String?
    private var selectedSkill: String?

    // Files
    private var idCardURL: URL?
    private var portfolioURL: URL?
    private var certificateURL: URL?

    private var currentUploadType = 0
    private var submitButton: UIButton?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCloudinary()
        fetchCategoriesFromAdmin()
        setupSkillMenu()
        setupLabelTaps()
        setupProfessionalDesign()
        addSubmitButton()
    }
    
    // MARK: - Professional Design Setup
    private func setupProfessionalDesign() {
        title = "Apply as Provider"
        // Safety check if outlet is connected
        if let regBtn = registerBtn {
            regBtn.isEnabled = true
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        headerView.backgroundColor = .clear
        tableView.tableHeaderView = headerView
        
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        nameLabel?.text = userName
        emailLabel?.text = userEmail
        phoneLabel?.text = userPhone
        
        [nameLabel, emailLabel, phoneLabel].forEach {
            $0?.font = .systemFont(ofSize: 16, weight: .medium)
            $0?.textColor = .darkGray
        }
        
        tellUsTxt.delegate = self
        tellUsTxt.text = "Tell us about yourself..."
        tellUsTxt.textColor = .placeholderText
        tellUsTxt.layer.cornerRadius = 14
        tellUsTxt.layer.borderWidth = 1
        tellUsTxt.layer.borderColor = UIColor.systemGray5.cgColor
        tellUsTxt.backgroundColor = .white
        tellUsTxt.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tellUsTxt.layer.shadowColor = UIColor.black.cgColor
        tellUsTxt.layer.shadowOpacity = 0.05
        tellUsTxt.layer.shadowOffset = CGSize(width: 0, height: 3)
        tellUsTxt.layer.shadowRadius = 5
        
        categoryMenu.setTitle("Select Category", for: .normal)
        skillLevelMenu.setTitle("Skill Level", for: .normal)
        styleMenuButton(categoryMenu)
        styleMenuButton(skillLevelMenu)
        
        [idUpload, workPortfolioUpload, certificateUpload].forEach {
            $0?.text = "Upload"
            $0?.textColor = brandColor
            $0?.isUserInteractionEnabled = true
            $0?.font = .systemFont(ofSize: 16, weight: .bold)
        }
    }
    
    private func styleMenuButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = brandColor
        button.semanticContentAttribute = .forceRightToLeft
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        button.configuration = config
        button.contentHorizontalAlignment = .fill
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.05
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 5
    }

    // MARK: - Add Submit Button (Footer)
    private func addSubmitButton() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        footerView.backgroundColor = .clear
        
        let submitBtn = UIButton(type: .system)
        submitBtn.frame = CGRect(x: 20, y: 30, width: tableView.frame.width - 40, height: 55)
        submitBtn.setTitle("Submit Application", for: .normal)
        submitBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        submitBtn.backgroundColor = brandColor
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.layer.cornerRadius = 14
        
        submitBtn.layer.shadowColor = brandColor.cgColor
        submitBtn.layer.shadowOpacity = 0.4
        submitBtn.layer.shadowOffset = CGSize(width: 0, height: 6)
        submitBtn.layer.shadowRadius = 10
        
        submitBtn.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        footerView.addSubview(submitBtn)
        tableView.tableFooterView = footerView
        submitButton = submitBtn
    }

    // MARK: - Cloudinary Init
    private func initCloudinary() {
        let config = CLDConfiguration(cloudName: cloudName, apiKey: apiKey, apiSecret: apiSecret, secure: true)
        cloudinary = CLDCloudinary(configuration: config)
    }

    // MARK: - TextView Delegate
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

    // MARK: - Data Fetching
    private func fetchCategoriesFromAdmin() {
        Firestore.firestore().collection("categories").getDocuments { [weak self] snapshot, _ in
            guard let self = self else { return }
            self.categories = snapshot?.documents.compactMap { $0["name"] as? String } ?? []
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

    private func setupSkillMenu() {
        let levels = ["Beginner", "Intermediate", "Advanced", "Expert"]
        let actions = levels.map { level in
            UIAction(title: level) { [weak self] _ in
                guard let self = self else { return }
                self.selectedSkill = level
                self.skillLevelMenu.setTitle(level, for: .normal)
            }
        }
        self.skillLevelMenu.menu = UIMenu(children: actions)
        self.skillLevelMenu.showsMenuAsPrimaryAction = true
    }

    // MARK: - Upload Logic (UI)
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

        alert.addAction(UIAlertAction(title: "PDF Document", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Photo/Image", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Document & Image Pickers Delegates
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first { handleFile(url) }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.7) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? data.write(to: tempURL)
            handleFile(tempURL)
        }
    }

    private func handleFile(_ url: URL) {
        let name = url.lastPathComponent
        let checkMark = "✓ \(name)"
        switch currentUploadType {
        case 0: idCardURL = url; idUpload.text = checkMark; idUpload.textColor = .systemGreen
        case 1: portfolioURL = url; workPortfolioUpload.text = checkMark; workPortfolioUpload.textColor = .systemGreen
        case 2: certificateURL = url; certificateUpload.text = checkMark; certificateUpload.textColor = .systemGreen
        default: break
        }
    }

    // MARK: - MAIN SUBMIT ACTION
    @objc private func submitButtonTapped() {
        print("🔘 Submit button tapped!")
        // Pass the UIBarButtonItem securely
        registerTapped(registerBtn ?? self)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        print("🚀 registerTapped called")
        
        // Validate form first
        if let errorMessage = validateForm() {
            print("❌ Validation failed: \(errorMessage)")
            showAlert(errorMessage, title: "Missing Information")
            return
        }
        
        print("✅ Validation passed")
        
        // Disable buttons
        registerBtn?.isEnabled = false
        submitButton?.isEnabled = false
        submitButton?.backgroundColor = .systemGray
        
        // Show loading
        let loading = UIAlertController(title: nil, message: "Submitting Application...", preferredStyle: .alert)
        present(loading, animated: true)
        
        print("📤 Starting submission process...")
        
        // Get current user ID or generate one for new user
        let uid = Auth.auth().currentUser?.uid ?? UUID().uuidString
        print("🆔 Using UID: \(uid)")
        
        // Upload files
        uploadFiles(uid: uid, loadingAlert: loading)
    }
    
    private func resetButtons() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.registerBtn?.isEnabled = true
            self.submitButton?.isEnabled = true
            self.submitButton?.backgroundColor = self.brandColor
        }
    }

    // MARK: - Upload Logic
    private func uploadFiles(uid: String, loadingAlert: UIAlertController) {
        print("📁 Starting file uploads...")
        
        let group = DispatchGroup()
        var uploadedUrls: [String: String] = [:]
        var uploadError = false
        let files = [("idCardURL", idCardURL), ("portfolioURL", portfolioURL), ("certificateURL", certificateURL)]

        for (key, fileURL) in files {
            guard let fileURL = fileURL else {
                print("⚠️ No file for \(key)")
                continue
            }
            
            print("⬆️ Uploading \(key)...")
            group.enter()
            
            let isPDF = fileURL.pathExtension.lowercased() == "pdf"
            var isAccessing = false
            if isPDF { isAccessing = fileURL.startAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: fileURL)
                print("📦 Data loaded for \(key): \(data.count) bytes")
                
                // Use [weak self] inside closure to prevent leaks
                cloudinary.createUploader().upload(data: data, uploadPreset: uploadPreset) { result, error in
                    if isPDF && isAccessing { fileURL.stopAccessingSecurityScopedResource() }
                    
                    if let url = result?.secureUrl {
                        uploadedUrls[key] = url
                        print("✅ \(key) uploaded: \(url)")
                    } else {
                        uploadError = true
                        print("❌ Failed to upload \(key): \(error?.localizedDescription ?? "unknown")")
                    }
                    group.leave()
                }
            } catch {
                uploadError = true
                print("❌ Error reading file \(key): \(error)")
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            print("📊 All uploads completed. Success: \(!uploadError)")
            
            if uploadError {
                loadingAlert.dismiss(animated: true)
                self.resetButtons()
                self.showAlert("Failed to upload documents.", title: "Upload Error")
            } else {
                self.saveRequest(uid: uid, urls: uploadedUrls, loadingAlert: loadingAlert)
            }
        }
    }

    // MARK: - Firestore Saving
    private func saveRequest(uid: String, urls: [String: String], loadingAlert: UIAlertController) {
        print("💾 Saving to Firestore...")
        
        let bioText = tellUsTxt.textColor == .placeholderText ? "" : tellUsTxt.text ?? ""
        let db = Firestore.firestore()
        
        // Create provider request data
        let requestData: [String: Any] = [
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
        
        print("📝 Request data: \(requestData)")
        
        // Save to provider_requests collection
        db.collection("provider_requests").document(uid).setData(requestData) { [weak self] error in
            guard let self = self else { return }
            loadingAlert.dismiss(animated: true)
            
            if let error = error {
                print("❌ Firestore error: \(error.localizedDescription)")
                self.resetButtons()
                self.showAlert(error.localizedDescription, title: "Database Error")
            } else {
                print("✅ Application saved successfully!")
                
                // If user is logged in, update their status
                if Auth.auth().currentUser != nil {
                    db.collection("users").document(uid).updateData([
                        "providerRequestStatus": "pending"
                    ]) { error in
                        if let error = error {
                            print("⚠️ Could not update user status: \(error)")
                        }
                    }
                }
                
                self.showSuccessAlert()
            }
        }
    }

    // MARK: - Helpers
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Application Submitted ✓",
            message: "Your provider application has been submitted successfully. Please wait until the admin approves your request.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            
            // Navigate to login screen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // ENSURE LoginViewController ID exists in Storyboard
                if let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? UIViewController {
                    loginVC.modalPresentationStyle = .fullScreen
                    window.rootViewController = loginVC
                    window.makeKeyAndVisible()
                }
            }
        })
        present(alert, animated: true)
    }

    private func showAlert(_ message: String, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func validateForm() -> String? {
        if selectedCategory == nil { return "Please select a category" }
        if selectedSkill == nil { return "Please select your skill level" }
        if idCardURL == nil { return "Please upload your ID Card" }
        if portfolioURL == nil { return "Please upload your Work Portfolio" }
        if certificateURL == nil { return "Please upload your Certificate" }
        return nil
    }
}
