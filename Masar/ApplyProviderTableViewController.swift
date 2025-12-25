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
    
    @IBOutlet weak var idUpload: UILabel!
    @IBOutlet weak var workPortfolioUpload: UILabel!
    @IBOutlet weak var certificateUpload: UILabel!

    // MARK: - Properties
    var userName: String?, userEmail: String?, userPhone: String?
    private var idCardURL: URL?, portfolioURL: URL?, certificateURL: URL?
    private var currentUploadType: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenus()
        setupLabelTaps()
        addDoneButtonToKeyboard()
    }

    private func setupUI() {
        title = "Provider Application"
        registerBtn.title = "Submit"
        registerBtn.isEnabled = false
        
        nameLabel.text = userName
        emailLabel.text = userEmail
        phoneLabel.text = userPhone
        
        tellUsTxt.delegate = self
        tellUsTxt.layer.cornerRadius = 8
        tellUsTxt.layer.borderWidth = 0.5
        tellUsTxt.layer.borderColor = UIColor.systemGray4.cgColor
        
        [idUpload, workPortfolioUpload, certificateUpload].forEach { label in
            label?.text = "Upload"
            label?.textColor = .systemBlue
            label?.isUserInteractionEnabled = true
            label?.numberOfLines = 1
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.5
            label?.lineBreakMode = .byClipping
        }
    }

    // MARK: - Keyboard Animation Helpers
    
    private func addDoneButtonToKeyboard() {
        // Removed toolbar - keyboard will dismiss with tap outside or return key
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Scroll to the row being edited for a smooth animation
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Find the actual index path of the cell containing the text view
        if let cell = textView.superview?.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        
        UIView.animate(withDuration: 0.3) {
            textView.layer.borderColor = UIColor.systemBlue.cgColor
            textView.layer.borderWidth = 1.0
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            textView.layer.borderColor = UIColor.systemGray4.cgColor
            textView.layer.borderWidth = 0.5
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        validateForm()
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
        label?.text = "✓ \(fileName)"
        label?.textColor = .systemGreen
    }

    // MARK: - Submit & Firebase
    @IBAction func registerTapped(_ sender: UIBarButtonItem) {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.showAlert("User not authenticated.")
            return
        }
        
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
            "name": userName ?? "",
            "email": userEmail ?? "",
            "phone": userPhone ?? "",
            "role": "provider",
            "category": categoryMenu.title(for: .normal) ?? "General",
            "bio": tellUsTxt.text ?? "",
            "idCardURL": urls["idCard"] ?? "",
            "portfolioURL": urls["portfolio"] ?? "",
            "certificateURL": urls["certificate"] ?? "",
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                self.showAlert("Error saving data: \(error.localizedDescription)")
                self.registerBtn.isEnabled = true
            } else {
                self.showSuccessAndRedirect()
            }
        }
    }

    func showSuccessAndRedirect() {
        let alert = UIAlertController(title: "Success!", message: "Your provider application has been submitted successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    // MARK: - Helper Methods
    private func setupMenus() {
        // Category Menu
        let categories = ["Electrician", "Plumber", "Carpenter", "Painter", "Mechanic"]
        categoryMenu.menu = UIMenu(children: categories.map { name in
            UIAction(title: name) { _ in
                self.categoryMenu.setTitle(name, for: .normal)
                self.validateForm()
            }
        })
        categoryMenu.showsMenuAsPrimaryAction = true
        
        // Skills Level Menu
        let skillLevels = ["Beginner", "Intermediate", "Advanced", "Expert"]
        skillLevelMenu.menu = UIMenu(children: skillLevels.map { level in
            UIAction(title: level) { _ in
                self.skillLevelMenu.setTitle(level, for: .normal)
                self.validateForm()
            }
        })
        skillLevelMenu.showsMenuAsPrimaryAction = true
    }

    private func validateForm() {
        let hasBio = !tellUsTxt.text.trimmingCharacters(in: .whitespaces).isEmpty
        let hasID = idCardURL != nil
        registerBtn.isEnabled = hasBio && hasID
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
