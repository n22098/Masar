import UIKit
import FirebaseFirestore

/// ReportManagementTVC: Manages the administrative list of all submitted user reports.
/// OOD Principle: Delegation - Inherits from UITableViewController to handle list interactions
/// and data population through standard iOS protocols.
class ReportManagementTVC: UITableViewController {
    
    // MARK: - Properties
    /// reports: Local cache of the report data retrieved from Firestore.
    var reports: [[String: Any]] = []
    
    /// reportDocumentIDs: Keeps track of specific Firestore document IDs to enable deletion.
    /// OOD Principle: Data Mapping - Linking UI indices to specific database records.
    var reportDocumentIDs: [String] = []
    
    /// Centralized branding color (Encapsulation).
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        fetchReports()
        
        // OOD Principle: Reusability - Registering the custom cell class for the table view.
        tableView.register(ReportItemCell.self, forCellReuseIdentifier: ReportItemCell.identifier)
    }
    
    /// Configures the visual appearance of the navigation bar and the general UI.
    func setupDesign() {
        title = "Report Management"
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        
        // Navigation Bar styling (Maintaining visual consistency across the Admin module)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.separatorStyle = .none // Using custom card separation in cells
        tableView.rowHeight = 100 // Fixed height for consistent card presentation
    }
    
    // MARK: - Data Management
    
    /// fetchReports: Establishes a real-time connection to the "reports" collection.
    /// OOD Principle: Observer Pattern - Automatically updates the UI when database documents change.
    func fetchReports() {
        let db = Firestore.firestore()
        
        // Query: Orders reports by timestamp so the newest appear at the top.
        db.collection("reports").order(by: "timestamp", descending: true).addSnapshotListener { [weak self] (snapshot, error) in
            if let error = error {
                print("❌ Error fetching reports: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("⚠️ No reports found")
                return
            }
            
            // 🔥 Synchronizing local state with the server snapshot
            self?.reports = documents.map { $0.data() }
            self?.reportDocumentIDs = documents.map { $0.documentID }
            
            print("✅ Fetched \(documents.count) reports")
            
            // UI Thread Safety: Reloading the table view to show new data
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // OOD Note: Casting to the specific 'ReportItemCell' to access its unique interface.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportItemCell.identifier, for: indexPath) as? ReportItemCell else {
            return UITableViewCell()
        }
        
        let report = reports[indexPath.row]
        
        // Logic: Generating a formatted ID for display (e.g., 001, 002) based on list order.
        let displayId = String(format: "%03d", reports.count - indexPath.row)
        
        let name = report["reporter"] as? String ?? "Unknown"
        let email = report["email"] as? String ?? "No Email"
        
        // Encapsulation: The cell handles its own UI internal layout.
        cell.configure(id: displayId, name: name, email: email)
        cell.accessoryType = .none
        
        return cell
    }
    
    // MARK: - Administrative Actions
    
    /// commit editingStyle: Handles the administrative "Swipe to Delete" action.
    /// OOD Principle: State Integrity - Removing data from the cloud also triggers the local observer to refresh.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentID = reportDocumentIDs[indexPath.row]
            
            print("🗑️ Deleting report with ID: \(documentID)")
            
            let db = Firestore.firestore()
            
            // Delete operation on Firestore
            db.collection("reports").document(documentID).delete { [weak self] error in
                if let error = error {
                    print("❌ Error deleting report: \(error.localizedDescription)")
                    
                    // UX Error Handling: Notifying the admin of a failure
                    let alert = UIAlertController(title: "Error", message: "Failed to delete report. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    print("✅ Report deleted successfully from Firebase")
                    // Note: No manual array removal needed; SnapshotListener handles it automatically.
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Handles user selection to view report details.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReport = reports[indexPath.row]
        
        // Manual View Controller instantiation (OOD: Direct Navigation)
        let detailsVC = ReportDetailsTVC()
        
        // Data Transformation: Converting raw Firestore [String: Any] to [String: String] for the detail view.
        var stringData: [String: String] = [:]
        stringData["id"] = selectedReport["id"] as? String ?? ""
        stringData["reporter"] = selectedReport["reporter"] as? String ?? ""
        stringData["email"] = selectedReport["email"] as? String ?? ""
        stringData["subject"] = selectedReport["subject"] as? String ?? ""
        stringData["description"] = selectedReport["description"] as? String ?? ""
        
        // Dependency Injection: Providing the detail view with the data it needs to display.
        detailsVC.reportData = stringData
        
        // Customizing the back button for a cleaner UI
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
