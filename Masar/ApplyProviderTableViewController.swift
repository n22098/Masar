import UIKit
import UniformTypeIdentifiers
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class ApplyProviderTableViewController: UITableViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tellUsTxt: UITextView!
    @IBOutlet weak var categoryMenu: UIButton!
    @IBOutlet weak var skillLevelMenu: UIButton!
    @IBOutlet weak var registerBtn: UIBarButtonItem!
    
    // Upload Labels from your storyboard
    @IBOutlet weak var idUpload: UILabel!
    @IBOutlet weak var workPortfolioUpload: UILabel!
    @IBOutlet weak var certificateUpload: UILabel!

    // MARK: - Properties
    var userName: String?, userEmail: String?, userPhone: String?
    private var idCardURL: URL?, portfolioURL: URL?, certificateURL: URL?
    private var currentUploadType: Int = 0 // 0: ID, 1: Portfolio, 2: Cert

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenus()
        setupLabelTaps()
    }

    private func setupUI() {
        title = "Data"
        registerBtn.title = "submit"
        registerBtn.isEnabled = false
        
        nameLabel.text = userName
        emailLabel.text = userEmail
        phoneLabel.text = userPhone
        
        tellUsTxt.delegate = self
        
        // Configure labels for FULL NAME display in one line
        [idUpload, workPortfolioUpload, certificateUpload].forEach { label in
            label?.text = "Upload"
            label?.textColor = .systemBlue
            label?.isUserInteractionEnabled = true
            
            // Fix: This ensures the full name shows in one line without "..."
            label?.numberOfLines = 1
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.5 // Allows font to shrink to 50% to fit the name
            label?.lineBreakMode = .byClipping // Removes the "..."
        }
    }

    // MARK: - Tap Gestures
    private func setupLabelTaps() {
        idUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(idTapped)))
        workPortfolioUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(portfolioTapped)))
        certificateUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(certTapped)))
    }

    @objc func idTapped() { currentUploadType = 0; showUploadSourceMenu() }
    @objc func portfolioTapped() { currentUploadType = 1; showUploadSourceMenu() }
    @objc func certTapped() { currentUploadType = 2; showUploadSourceMenu() }

    // MARK: - Source Menu
    private func showUploadSourceMenu() {
        let alert = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Files (PDF)", style: .default) { _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            picker.delegate = self
            self.present(picker, animated: true)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - File Handling
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first { processSelectedFile(url: url) }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.7) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
            try? data.write(to: tempURL)
            processSelectedFile(url: tempURL)
        }
    }

    private func processSelectedFile(url: URL) {
        let fileName = url.lastPathComponent
        switch currentUploadType {
        case 0:
            idCardURL = url
            updateLabelSuccess(idUpload, fileName: fileName)
        case 1:
            portfolioURL = url
            updateLabelSuccess(workPortfolioUpload, fileName: fileName)
        case 2:
            certificateURL = url
            updateLabelSuccess(certificateUpload, fileName: fileName)
        default: break
        }
        validateForm()
    }

    private func updateLabelSuccess(_ label: UILabel?, fileName: String) {
        // Displays the checkmark and the full filename
        label?.text = "✓ \(fileName)"
        label?.textColor = .systemGreen
    }

    // MARK: - Submit & Firebase
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        sender.isEnabled = false
        
        let storageRef = Storage.storage().reference().child("providers/\(uid)")
        let group = DispatchGroup()
        var uploadedURLs: [String: String] = [:]

        let files = [("idCard", idCardURL), ("portfolio", portfolioURL), ("certificate", certificateURL)]

        for (key, fileURL) in files {
            guard let url = fileURL else { continue }
            group.enter()
            let ref = storageRef.child("\(key).\(url.pathExtension)")
            ref.putFile(from: url, metadata: nil) { _, _ in
                ref.downloadURL { dURL, _ in
                    if let d = dURL?.absoluteString { uploadedURLs[key] = d }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            self.saveToFirestore(uid: uid, urls: uploadedURLs)
        }
    }

    private func saveToFirestore(uid: String, urls: [String: String]) {
        let data: [String: Any] = [
            "role": "provider",
            "category": categoryMenu.title(for: .normal) ?? "",
            "bio": tellUsTxt.text ?? "",
            "idCardURL": urls["idCard"] ?? "",
            "portfolioURL": urls["portfolio"] ?? "",
            "certificateURL": urls["certificate"] ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Helper Methods
    private func setupMenus() {
        let categories = ["Electrician", "Plumber", "Carpenter", "Painter"]
        categoryMenu.menu = UIMenu(children: categories.map { name in
            UIAction(title: name) { _ in self.categoryMenu.setTitle(name, for: .normal); self.validateForm() }
        })
        categoryMenu.showsMenuAsPrimaryAction = true
    }

    func textViewDidChange(_ textView: UITextView) { validateForm() }

    private func validateForm() {
        let hasBio = !tellUsTxt.text.trimmingCharacters(in: .whitespaces).isEmpty
        registerBtn.isEnabled = hasBio && idCardURL != nil
    }
}
