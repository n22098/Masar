import UIKit
import SafariServices
import FirebaseFirestore

/// ProviderRequestTVC: Manages the detailed view of a service provider's application.
/// OOD Principle: Single Responsibility - This class focuses entirely on the
/// administrative review process for new provider requests.
class ProviderRequestTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var skillsLevelLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    /// requestUID: The unique identifier for the request being reviewed.
    var requestUID: String?
    
    /// Database Reference
    let db = Firestore.firestore()
    
    // Links to external documents (ID, Certificates, Portfolios)
    var idCardLink: String?
    var certificateLink: String?
    var portfolioLink: String?
    
    /// local cache of the full document to simplify the archiving process
    private var fullRequestData: [String: Any]?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial Fetch: Retrieve the details as soon as the view loads.
        if let uid = requestUID {
            fetchRequestDetails(uid: uid)
        }
    }
    
    // MARK: - Firebase Fetching
    
    /// fetchRequestDetails: Uses a Snapshot Listener to get real-time updates.
    /// OOD Principle: Reactive Programming - The UI updates automatically if the
    /// status changes in the database.
    private func fetchRequestDetails(uid: String) {
        db.collection("provider_requests").document(uid).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data() else { return }
            self.fullRequestData = data
            
            // Mapping Dictionary data to UI Labels
            self.providerNameLabel.text = data["name"] as? String
            self.emailLabel.text = data["email"] as? String
            self.phoneLabel.text = data["phone"] as? String
            self.categoryLabel.text = data["category"] as? String
            self.skillsLevelLabel.text = data["skillLevel"] as? String
            
            // Status Handling: Defaults to "pending" if no status is found
            let status = data["status"] as? String ?? "pending"
            self.updateStatusUI(status: status)
            
            // Extracting URL strings for document viewing
            self.idCardLink = data["idCardURL"] as? String
            self.certificateLink = data["certificateURL"] as? String
            self.portfolioLink = data["portfolioURL"] as? String
        }
    }

    /// updateStatusUI: Centralized logic for styling the status label.
    /// OOD Principle: Encapsulation - The logic for "how a status looks" is hidden here.
    private func updateStatusUI(status: String) {
        statusLabel.text = status.capitalized
        
        // Polymorphic-style UI: Colors change based on the status string
        switch status.lowercased() {
        case "approved":
            statusLabel.textColor = .systemGreen
        case "rejected":
            statusLabel.textColor = .systemRed
        default:
            statusLabel.textColor = .systemOrange
        }
    }

    // MARK: - Dual Archive Logic
    
    /// finalizeDecision: Processes the admin's choice (Approve or Reject).
    /// OOD Principle: Atomicity (Write Batch) - Ensures all database changes happen as a single unit.
    private func finalizeDecision(isApproved: Bool) {
        guard let uid = requestUID, var archiveData = fullRequestData else { return }
        
        // Start a Batch: A group of write operations that succeed or fail together.
        let batch = db.batch()
        let finalStatus = isApproved ? "approved" : "rejected"
        let userStatus = isApproved ? "Active" : "Rejected"
        
        // 1️⃣ Update Original Collections: Maintain app functionality
        // Update user role and status in the 'users' collection
        let userRef = db.collection("users").document(uid)
        batch.updateData([
            "status": userStatus,
            "role": isApproved ? "provider" : "seeker"
        ], forDocument: userRef)
        
        // Update status in the 'provider_requests' collection
        let requestRef = db.collection("provider_requests").document(uid)
        batch.updateData(["status": finalStatus], forDocument: requestRef)
        
        // 2️⃣ Archive Logic: Store a permanent record for admin history
        archiveData["admin_decision_date"] = FieldValue.serverTimestamp()
        archiveData["final_status"] = finalStatus
        
        // Decide which path to archive to based on the decision
        let newPath = isApproved ? "archived_approved_requests" : "archived_rejected_requests"
        let archiveRef = db.collection(newPath).document(uid)
        
        batch.setData(archiveData, forDocument: archiveRef)
        
        // Commit: Execute all operations in the batch
        batch.commit { [weak self] error in
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
            } else {
                // Return to the previous screen upon success
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Actions
    
    @IBAction func approveTapped(_ sender: UIButton) {
        finalizeDecision(isApproved: true)
    }
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        finalizeDecision(isApproved: false)
    }
    
    // MARK: - Helpers
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - External Document Viewing
    // OOD Principle: Delegation - Using SFSafariViewController to handle web browsing tasks.
    
    @IBAction func viewIDCardTapped(_ sender: UIButton) { openLink(idCardLink) }
    @IBAction func viewCertificateTapped(_ sender: UIButton) { openLink(certificateLink) }
    @IBAction func viewPortfolioTapped(_ sender: UIButton) { openLink(portfolioLink) }
    
    /// openLink: Safely opens a URL in an in-app Safari browser.
    private func openLink(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
