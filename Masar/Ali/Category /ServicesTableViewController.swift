import UIKit
import FirebaseFirestore

// Renamed to match the "Service Item" screen in your storyboard
class ServiceItemTVC: UITableViewController {

    // Data passed from ProvidersTableViewController
    var providerName: String?
    var providerID: String?
    
    // Arrays to hold dynamic data from Firebase
    var services: [String] = []
    var serviceIDs: [String] = []
    
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the title to the provider you clicked on
        self.title = "\(providerName ?? "Provider")'s Services"
        
        // This allows you to click 'Edit' in the nav bar to delete rows
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadServices()
    }

    // MARK: - Firebase Logic
    func loadServices() {
        guard let pID = providerID else {
            print("❌ No providerID received")
            return
        }
        
        // Listening for services where 'providerID' matches the one we clicked
        db.collection("Services")
            .whereField("providerID", isEqualTo: pID)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                
                guard let self = self else { return }
                self.services = []
                self.serviceIDs = []
                
                if let e = error {
                    print("Error fetching services: \(e.localizedDescription)")
                } else {
                    if let snapshotDocs = querySnapshot?.documents {
                        for doc in snapshotDocs {
                            let data = doc.data()
                            if let name = data["name"] as? String {
                                self.services.append(name)
                                self.serviceIDs.append(doc.documentID)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure "ServiceCell" is the identifier set in your Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
        cell.textLabel?.text = services[indexPath.row]
        return cell
    }
    
    // MARK: - Swipe to Delete (Firebase)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sID = serviceIDs[indexPath.row]
            
            db.collection("Services").document(sID).delete { error in
                if let e = error {
                    print("❌ Error deleting service: \(e.localizedDescription)")
                } else {
                    print("✅ Service deleted successfully")
                }
            }
        }
    }

    // MARK: - Swipe to Edit
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showEditServiceAlert(for: indexPath.row)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func showEditServiceAlert(for index: Int) {
        let alert = UIAlertController(title: "Edit Service", message: "Update service name", preferredStyle: .alert)
        alert.addTextField { $0.text = self.services[index] }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                guard let sID = self?.serviceIDs[index] else { return }
                // Update Firebase document
                self?.db.collection("Services").document(sID).updateData(["name": newName])
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
