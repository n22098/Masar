import UIKit
import UniformTypeIdentifiers
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
        setupUI()
        setupSkillMenu()
        setupLabelTaps()
        fetchCategoriesFromAdmin()
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

        categoryMenu.setTitle("Select Category", for: .normal)
        skillLevelMenu.setTitle("Skill Level", for: .normal)

        [idUpload, workPortfolioUpload, certificateUpload].forEach {
            $0?.text = "Upload"
            $0?.textColor = .systemBlue
            $0?.isUserInteractionEnabled = true
        }
    }

    // MARK: - Categories (Admin)
    private func fetchCategoriesFromAdmin() {
        Firestore.firestore()
            .collection("categories")
            .getDocuments { snapshot, _ in
                self.categories = snapshot?.documents.compactMap {
                    $0.data()["name"] as? String
                } ?? []
                self.setupCategoryMenu()
            }
    }

    private func setupCategoryMenu() {
        let actions = categories.map { category in
            UIAction(title: category) { [weak self] _ in
                self?.selectedCategory = category
                self?.categoryMenu.setTitle(category, for: .normal)
            }
        }
        categoryMenu.menu = UIMenu(children: actions)
        categoryMenu.showsMenuAsPrimaryAction = true
    }

    // MARK: - Skill Menu
    private func setupSkillMenu() {
        let levels = ["Beginner", "Intermediate", "Advanced", "Expert"]
        let actions = levels.map { level in
            UIAction(title: level) { [weak self] _ in
                self?.selectedSkill = level
                self?.skillLevelMenu.setTitle(level, for: .normal)
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
        let alert = UIAlertController(title: "Upload", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "PDF", style: .default) { _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Photo", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Pickers
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        if let url = urls.first { handleFile(url) }
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
        case 0: idCardURL = url; idUpload.text = "✓ \(name)"
        case 1: portfolioURL = url; workPortfolioUpload.text = "✓ \(name)"
        case 2: certificateURL = url; certificateUpload.text = "✓ \(name)"
        default: break
        }
    }

    // MARK: - 🔥 SUBMIT - FIXED VERSION
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {

        print("🔥 SUBMIT PRESSED")

        // Validate all fields
        if tellUsTxt.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert("Please tell us about yourself.", title: "Missing Information")
            return
        }

        if selectedCategory == nil {
            showAlert("Please select a category.", title: "Missing Information")
            return
        }

        if selectedSkill == nil {
            showAlert("Please select your skill level.", title: "Missing Information")
            return
        }

        if idCardURL == nil {
            showAlert("Please upload your ID card.", title: "Missing Information")
            return
        }

        // ✅ Get UID - Try multiple methods
        var uid: String?
        
        // Method 1: Try current user
        if let currentUID = Auth.auth().currentUser?.uid {
            uid = currentUID
            print("✅ Got UID from currentUser:", currentUID)
        }
        // Method 2: Use email as backup
        else if let email = userEmail {
            uid = email.replacingOccurrences(of: "@", with: "_at_")
                       .replacingOccurrences(of: ".", with: "_")
            print("⚠️ Using email-based UID:", uid ?? "")
        }
        
        guard let finalUID = uid else {
            showAlert("Unable to process request. Please try again.", title: "Error")
            return
        }

        print("✅ Validation passed, UID:", finalUID)

        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Submitting your application...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)

        // Upload files to Firebase Storage
        let storage = Storage.storage().reference()
            .child("provider_requests/\(finalUID)")

        let group = DispatchGroup()
        var urls: [String: String] = [:]

        let files = [
            ("idCard", idCardURL),
            ("portfolio", portfolioURL),
            ("certificate", certificateURL)
        ]

        for (key, file) in files {
            guard let file = file else { continue }
            group.enter()

            let ref = storage.child("\(key).\(file.pathExtension)")
            ref.putFile(from: file) { _, error in
                if let error = error {
                    print("❌ Upload error for \(key):", error.localizedDescription)
                }

                ref.downloadURL { url, _ in
                    urls[key] = url?.absoluteString ?? ""
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            print("✅ All uploads finished")
            loadingAlert.dismiss(animated: true) {
                self.saveRequest(uid: finalUID, urls: urls)
            }
        }
    }

    // MARK: - Firestore
    private func saveRequest(uid: String, urls: [String: String]) {
        let data: [String: Any] = [
            "uid": uid,
            "name": userName ?? "",
            "email": userEmail ?? "",
            "phone": userPhone ?? "",
            "category": selectedCategory ?? "",
            "skillLevel": selectedSkill ?? "",
            "bio": tellUsTxt.text ?? "",
            "idCardURL": urls["idCard"] ?? "",
            "portfolioURL": urls["portfolio"] ?? "",
            "certificateURL": urls["certificate"] ?? "",
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        print("💾 Saving to Firestore:", data)

        Firestore.firestore()
            .collection("provider_requests")
            .document(uid)
            .setData(data) { error in
                if let error = error {
                    print("❌ Firestore error:", error.localizedDescription)
                    self.showAlert("Failed to submit your application. Please try again.", title: "Error")
                } else {
                    print("✅ Successfully saved to Firestore")
                    self.showSuccessAlert()
                }
            }
    }

    // MARK: - ✅ SUCCESS ALERT (NAVIGATE TO SIGN IN)
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Registration Successful! ✓",
            message: """
            Congratulations! You are now registered as a Seeker.
            
            Your Provider application has been submitted and is currently under review by our admin team.
            
            You will receive a notification once your request is either approved or rejected.
            
            Thank you for your patience!
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate to SignInViewController
            self.navigateToSignIn()
        })
        
        present(alert, animated: true)
    }

    // MARK: - 🔥 NAVIGATE TO SIGN IN PAGE
    private func navigateToSignIn() {
        // Method 1: Using Storyboard ID
        if let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            // Clear navigation stack and set SignIn as root
            navigationController?.setViewControllers([signInVC], animated: true)
        }
        // Method 2: If using different navigation structure
        else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                let navController = UINavigationController(rootViewController: signInVC)
                window.rootViewController = navController
                window.makeKeyAndVisible()
                
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
        // Method 3: Fallback - pop to root
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - ERROR ALERT
    private func showAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
