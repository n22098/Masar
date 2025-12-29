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

    // MARK: - Cloudinary Config
    // Ensure these match your Dashboard exactly
    private let cloudName = "dsjx9ehz2"
    private let apiKey = "598938434737516"
    private let apiSecret = "0Eyox42LzqrMjwvxpPbqx2SNk5Y"
    private let uploadPreset = "ml_default" // ✅ Must be Unsigned in Dashboard

    private var cloudinary: CLDCloudinary!

    // MARK: - Data from Previous Screen
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var userUsername: String? // ✅ Username passed from Sign Up
    var userPassword: String?

    // MARK: - Local Data
    private var categories: [String] = []
    private var selectedCategory: String?
    private var selectedSkill: String?

    // Local File URLs
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

    // MARK: - Fetch Data
    private func fetchCategoriesFromAdmin() {
        Firestore.firestore().collection("categories").getDocuments { snapshot, _ in
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
            UIAction(title: level) { _ in
                self.selectedSkill = level
                self.skillLevelMenu.setTitle(level, for: .normal)
            }
        }
        skillLevelMenu.menu = UIMenu(children: actions)
        skillLevelMenu.showsMenuAsPrimaryAction = true
    }

    // MARK: - File Upload Selection
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

    // MARK: - Document & Image Pickers
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            handleFile(url)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

    // MARK: - MAIN SUBMIT ACTION
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        
        if let errorMessage = validateForm() {
            showAlert(errorMessage, title: "Missing Information")
            return
        }

        registerBtn.isEnabled = false
        let loading = UIAlertController(title: nil, message: "Creating Account & Uploading...", preferredStyle: .alert)
        present(loading, animated: true)
        
        guard let email = userEmail, let password = userPassword else {
            loading.dismiss(animated: true)
            showAlert("User data missing", title: "Error")
            return
        }

        // 1. Create User in Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                loading.dismiss(animated: true)
                self.registerBtn.isEnabled = true
                self.showAlert(error.localizedDescription, title: "Auth Error")
                return
            }

            guard let uid = authResult?.user.uid else { return }
            
            // 2. Start Uploading Files to Cloudinary
            self.uploadFiles(uid: uid, loadingAlert: loading)
        }
    }

    // MARK: - Upload Logic
    private func uploadFiles(uid: String, loadingAlert: UIAlertController) {
        
        let group = DispatchGroup()
        var uploadedUrls: [String: String] = [:]
        var uploadError = false

        let files = [
            ("idCardURL", idCardURL),
            ("portfolioURL", portfolioURL),
            ("certificateURL", certificateURL)
        ]

        for (key, fileURL) in files {
            guard let fileURL = fileURL else { continue }
            group.enter()
            
            // Check if PDF to handle security permissions
            let isPDF = fileURL.pathExtension.lowercased() == "pdf"
            var isAccessing = false
            if isPDF {
                isAccessing = fileURL.startAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                
                // Upload to Cloudinary
                cloudinary.createUploader().upload(data: data, uploadPreset: uploadPreset) { result, error in
                    
                    // Release security access
                    if isPDF && isAccessing {
                        fileURL.stopAccessingSecurityScopedResource()
                    }
                    
                    // ✅ CRITICAL: Get the Secure URL (HTTPS)
                    if let url = result?.secureUrl {
                        uploadedUrls[key] = url
                        print("✅ Uploaded \(key): \(url)")
                    } else {
                        print("❌ Error uploading \(key): \(error?.localizedDescription ?? "Unknown")")
                        uploadError = true
                    }
                    group.leave()
                }
            } catch {
                print("❌ Failed to read file data: \(error)")
                uploadError = true
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if uploadError {
                loadingAlert.dismiss(animated: true)
                self.registerBtn.isEnabled = true
                self.showAlert("Failed to upload some documents. Check internet/permissions.", title: "Upload Error")
            } else {
                // 3. Save URLs and User Data to Firestore
                self.saveRequest(uid: uid, urls: uploadedUrls, loadingAlert: loadingAlert)
            }
        }
    }

    // MARK: - Firestore Saving
    private func saveRequest(uid: String, urls: [String: String], loadingAlert: UIAlertController) {

        let bioText = tellUsTxt.textColor == .placeholderText ? "" : tellUsTxt.text ?? ""
        
        let batch = Firestore.firestore().batch()
        
        // 1. User Document
        let userRef = Firestore.firestore().collection("users").document(uid)
        let userData: [String: Any] = [
            "uid": uid,
            "name": self.userName ?? "",
            "username": self.userUsername ?? "", // ✅ Saving Username
            "email": self.userEmail ?? "",
            "phone": self.userPhone ?? "",
            "role": "seeker",
            "providerRequestStatus": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        batch.setData(userData, forDocument: userRef)

        // 2. Provider Request Document (with URLs)
        let requestRef = Firestore.firestore().collection("provider_requests").document(uid)
        let requestData: [String: Any] = [
            "uid": uid,
            "name": userName ?? "",
            "email": userEmail ?? "",
            "phone": userPhone ?? "",
            "category": selectedCategory ?? "",
            "skillLevel": selectedSkill ?? "",
            "bio": bioText,
            "idCardURL": urls["idCardURL"] ?? "",         // ✅ Full HTTPS URL
            "portfolioURL": urls["portfolioURL"] ?? "",   // ✅ Full HTTPS URL
            "certificateURL": urls["certificateURL"] ?? "", // ✅ Full HTTPS URL
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        batch.setData(requestData, forDocument: requestRef)

        batch.commit { error in
            loadingAlert.dismiss(animated: true)
            if let error = error {
                self.registerBtn.isEnabled = true
                self.showAlert(error.localizedDescription, title: "Database Error")
            } else {
                self.showSuccessAlert()
            }
        }
    }

    // MARK: - Helpers
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Request Submitted Successfully ✓",
            message: "Your request is under review. You can login as a Seeker for now.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Go to Login", style: .default) { _ in
            self.navigateToSignIn()
        })

        present(alert, animated: true)
    }

    private func navigateToSignIn() {
        if let nav = self.navigationController {
            nav.popToRootViewController(animated: true)
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") {
                 if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let delegate = windowScene.delegate as? SceneDelegate {
                     delegate.window?.rootViewController = vc
                 }
            }
        }
    }

    private func showAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
