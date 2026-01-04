import UIKit
import FirebaseFirestore
import FirebaseAuth

/// ReportIssueTVC: A controller that allows users to submit support tickets or issues.
/// OOD Principle: Encapsulation - This class manages the state of the reporting form
/// and hides the complexity of the Firestore upload process.
class ReportIssueTVC: UITableViewController {

    // MARK: - IBOutlets
    // These outlets connect UI elements to code.
    @IBOutlet weak var reportIDLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel! // Displays the current user's full name
    @IBOutlet weak var emailLabel: UILabel!    // Displays the current user's email
    
    @IBOutlet weak var subjectTextField: UITextField! // Input for the report title
    @IBOutlet weak var descriptionTextView: UITextView! // Input for the detailed message

    // MARK: - Properties
    /// Visual identity colors to match the branding of the Admin tools.
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
    
    /// Reference to the Firestore database
    let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModernUI()
        loadUserProfile() // OOD Principle: Automated Data Fetching
        generateReportID()
    }

    // MARK: - 🎨 Modern UI Setup
    
    /// Configures the visual appearance of the form.
    private func setupModernUI() {
        self.title = "Report Issue"
        
        // Navigation Bar styling for branding consistency
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // TableView styling
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none
        
        // Enhancing the description text area (Encapsulation of visual styling)
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.text = ""
        
        // Adding a 'Submit' button to the Navigation Bar (OOD: Action-Target pattern)
        let submitButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitReport))
        navigationItem.rightBarButtonItem = submitButton
    }

    /// Generates a unique tracking ID for the user's reference.
    private func generateReportID() {
        let randomID = Int.random(in: 1000...9999)
        reportIDLabel.text = "#RM-\(randomID)"
    }

    /// Fetches the reporter's personal data from their Firebase Profile.
    /// This improves UX by pre-filling the user's identity.
    private func loadUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Accessing the 'users' collection to pull name and email
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.reporterLabel.text = data?["fullName"] as? String ?? "Unknown User"
                self.emailLabel.text = data?["email"] as? String ?? "No Email"
            }
        }
    }

    // MARK: - Firebase Actions
    
    /// Validates inputs and uploads the report to the "reports" collection.
    @objc private func submitReport() {
        // Validation Logic: Ensuring the admin receives complete data.
        guard let subject = subjectTextField.text, !subject.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(message: "Please fill in the subject and description.")
            return
        }

        // Constructing the data dictionary (Model mapping)
        let reportData: [String: Any] = [
            "reportID": reportIDLabel.text ?? "",
            "reporter": reporterLabel.text ?? "",
            "email": emailLabel.text ?? "",
            "subject": subject,
            "description": description,
            "timestamp": FieldValue.serverTimestamp(), // Use server time for accuracy
            "status": "New" // Initial status for the admin to see
        ]

        // Persistence Logic: Uploading the document to the cloud
        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                self.showAlert(message: "Error submitting report: \(error.localizedDescription)")
            } else {
                // Success Feedback: Notify the user and return to the previous screen.
                let alert = UIAlertController(title: "Success", message: "Your issue has been reported.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    /// Helper method to display error or notice messages.
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Navigation
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
