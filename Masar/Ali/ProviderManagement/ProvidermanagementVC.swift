import UIKit
import FirebaseFirestore

class ProviderManagementVC: UITableViewController {
    
    // 1. Firebase Reference and Data Array
    private let db = Firestore.firestore()
    // Changed to [Provider] to fix the assignment error in prepare(for:segue:)
    private var providers: [Provider] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Provider Management"
        
        setupNavigationButtons()
        observeProviders()
    }
    
    // 2. Navigation Bar Setup
    private func setupNavigationButtons() {
        // This replaces the "+" with the standard "Edit/Done" system button
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // 3. Real-time Firebase Listener
    private func observeProviders() {
        listener = db.collection("providers").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching providers: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else { return }
            
            // Map Firestore data to the [Provider] array
            self.providers = documents.compactMap { doc -> Provider? in
                return Provider(id: doc.documentID, dictionary: doc.data())
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath)
        let provider = providers[indexPath.row]
        
        // Populate cell with provider data
        cell.textLabel?.text = provider.fullName
        cell.detailTextLabel?.text = provider.category // Optional: show subtitle
        
        return cell
    }
    
    // 4. Handle Deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let providerID = providers[indexPath.row].id
            
            // Delete from Firestore
            db.collection("providers").document(providerID).delete { error in
                if let error = error {
                    print("Error deleting provider: \(error.localizedDescription)")
                }
            }
            // Note: The tableView row will disappear automatically because of the listener
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? ProviderDetailsTVC {
            if segue.identifier == "showProviderDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // This now works because both types are 'Provider'
                    detailVC.provider = providers[indexPath.row]
                    detailVC.isNewProvider = false
                }
            }
        }
    }
    
    deinit {
        listener?.remove() // Safety: Stop listening to database changes
    }
}
