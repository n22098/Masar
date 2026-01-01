import UIKit
import FirebaseFirestore

class ProviderManagementVC: UITableViewController {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var providers: [Provider] = []
    private var listener: ListenerRegistration?
    
    // Brand Color
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        observeProviders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Deselect row when coming back for a smooth UI feel
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Provider Management"
        
        // Remove back button text for the next screen
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func setupTableView() {
        // Modern iOS background
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = 80 // Fixed height often looks better for uniform lists
        tableView.tableFooterView = UIView()
    }

    // MARK: - Firestore
    private func observeProviders() {
        print("🔍 Fetching providers...")
        
        // Fetching from 'provider_requests' where status is approved
        listener = db.collection("provider_requests")
            .whereField("status", isEqualTo: "approved")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No providers found")
                    self.providers = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.showEmptyState()
                    }
                    return
                }

                self.providers = documents.compactMap {
                    Provider(uid: $0.documentID, dictionary: $0.data())
                }

                DispatchQueue.main.async {
                    self.hideEmptyState()
                    self.tableView.reloadData()
                    print("✅ Loaded \(self.providers.count) providers")
                }
            }
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: tableView.bounds)
        emptyLabel.text = "No providers found"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure your storyboard cell identifier is exactly "showProviderDetailsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath)

        let provider = providers[indexPath.row]

        // Title (Name)
        cell.textLabel?.text = provider.fullName
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.textLabel?.textColor = .label

        // Subtitle (Category)
        cell.detailTextLabel?.text = provider.category
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.font = .systemFont(ofSize: 15)
        
        // Styling
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProvider = providers[indexPath.row]
        // Triggers the segue and sends the specific provider object
        performSegue(withIdentifier: "showProviderDetailsSegue", sender: selectedProvider)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderDetailsSegue",
           let detailsVC = segue.destination as? ProviderDetailsTVC {
            
            // 1. Try to get provider from sender (passed via performSegue)
            if let selectedProvider = sender as? Provider {
                detailsVC.provider = selectedProvider
            }
            // 2. Fallback: Get from selected row
            else if let indexPath = tableView.indexPathForSelectedRow {
                detailsVC.provider = providers[indexPath.row]
            }
            
            // ✅ ERROR FIXED: The line 'detailsVC.isNewProvider = false' has been removed
            
            print("✅ Passing provider: \(detailsVC.provider?.fullName ?? "Unknown")")
        }
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
