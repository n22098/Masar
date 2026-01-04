import UIKit
import FirebaseFirestore

class ProvidersTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    var selectedCategory: String = ""
    var categoryID: String = ""
    private var providers: [QueryDocumentSnapshot] = []
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.register(CategoryCardCell.self, forCellReuseIdentifier: "CategoryCardCell")
        
        startProvidersListener()
    }
    
    private func setupUI() {
        self.title = selectedCategory
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    private func startProvidersListener() {
        db.collection("provider_requests")
            .whereField("status", isEqualTo: "approved")
            .whereField("category", isEqualTo: selectedCategory)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let documents = querySnapshot?.documents {
                    self.providers = documents
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        documents.isEmpty ? self.showEmptyState() : self.hideEmptyState()
                    }
                }
            }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: tableView.bounds)
        emptyLabel.text = "No approved providers\nin \(selectedCategory)"
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() { tableView.backgroundView = nil }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UITableViewCell()
        }
        let doc = providers[indexPath.row]
        let name = doc.get("name") as? String ?? "Unknown"
        cell.configure(name: name)
        return cell
    }
    
    // MARK: - Navigation: Linking to ServicesController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let doc = providers[indexPath.row]
        let data = doc.data()
        
        // Initializing the renamed ServicesController
        let servicesVC = ServicesController()
        
        // Passing the provider documentID to filter the Services collection
        servicesVC.providerID = doc.documentID
        servicesVC.providerName = data["name"] as? String ?? "Provider"
        
        self.navigationController?.pushViewController(servicesVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let providerName = self.providers[indexPath.row].get("name") as? String ?? "this provider"
            let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete \(providerName)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in completionHandler(false) }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let documentID = self.providers[indexPath.row].documentID
                self.db.collection("provider_requests").document(documentID).delete { error in
                    completionHandler(error == nil)
                }
            }))
            self.present(alert, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
