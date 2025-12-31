import UIKit
import FirebaseFirestore

class ProviderManagementVC: UITableViewController {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var providers: [Provider] = []
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        observeProviders()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Provider Management"
        navigationItem.rightBarButtonItem = editButtonItem
    }

    private func setupTableView() {
        tableView.backgroundColor = UIColor(
            red: 248/255,
            green: 249/255,
            blue: 253/255,
            alpha: 1.0
        )
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView() // يخفي الفواصل الفاضية
    }

    // MARK: - Firestore
    private func observeProviders() {
        listener = db.collection("providers")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching providers: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No provider documents found")
                    self.providers = []
                    self.tableView.reloadData()
                    return
                }

                print("✅ Found \(documents.count) providers")

                self.providers = documents.compactMap {
                    Provider(uid: $0.documentID, dictionary: $0.data())
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("📱 Table reloaded with \(self.providers.count) providers")
                }
            }
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "showProviderDetailsCell",
            for: indexPath
        )

        let provider = providers[indexPath.row]

        // Title
        cell.textLabel?.text = provider.fullName.isEmpty
            ? provider.username
            : provider.fullName

        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        // Subtitle
        cell.detailTextLabel?.text = provider.category.isEmpty
            ? provider.email
            : provider.category

        cell.detailTextLabel?.textColor = .systemGray
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Delete Provider
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let provider = providers[indexPath.row]

            let alert = UIAlertController(
                title: "Delete Provider",
                message: "Are you sure you want to delete \(provider.fullName)?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(
                UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    self?.deleteProvider(provider)
                }
            )

            present(alert, animated: true)
        }
    }

    private func deleteProvider(_ provider: Provider) {
        db.collection("providers")
            .document(provider.uid)
            .delete { [weak self] error in
                if let error = error {
                    print("❌ Error deleting provider: \(error.localizedDescription)")
                    self?.showAlert(
                        title: "Error",
                        message: "Failed to delete provider"
                    )
                } else {
                    print("✅ Provider deleted")
                }
            }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderDetailsSegue",
           let detailsVC = segue.destination as? ProviderDetailsTVC,
           let indexPath = tableView.indexPathForSelectedRow {

            detailsVC.provider = providers[indexPath.row]
            detailsVC.isNewProvider = false
        }
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
