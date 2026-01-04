import UIKit
import FirebaseFirestore
import FirebaseAuth

/// ProviderManagementVC: Manages the list of "Service Provider" users for the administrator.
/// OOD Principle: Inheritance - Inherits from UITableViewController to utilize built-in
/// dynamic list management features.
class ProviderManagementVC: UITableViewController {
    
    /// Centralized brand color for visual consistency across the Admin module.
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Properties
    /// providers: The local collection of Provider model objects (The "Source of Truth" for the UI).
    var providers: [Provider] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Registering the custom cell used to display provider summaries.
        tableView.register(showProviderDetailsCell.self, forCellReuseIdentifier: "showProviderDetailsCell")
        
        // Initiating the real-time data connection.
        fetchProvidersFromFirestore()
    }
    
    /// Ensures the navigation bar appearance is correctly configured every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Firebase Fetching
    
    /// fetchProvidersFromFirestore: Sets up an active listener to track changes in the "users" collection.
    /// OOD Principle: Observer Pattern - This allows the controller to react instantly to database updates.
    func fetchProvidersFromFirestore() {
        let db = Firestore.firestore()
        
        // Filtering: Only retrieving users whose role is defined as "provider".
        db.collection("users").whereField("role", isEqualTo: "provider")
            .addSnapshotListener { (querySnapshot, error) in
            
            // Error handling to prevent the app from processing invalid data.
            if let error = error { return }
            
            // Clear the local list to repopulate it with the fresh data snapshot.
            self.providers = []
            
            // Mapping Firestore documents into our strongly-typed 'Provider' Model objects.
            for document in querySnapshot!.documents {
                let newProvider = Provider(document: document)
                self.providers.append(newProvider)
            }
            
            // UI Thread Management: Ensure the table reloads on the main thread for performance.
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    // MARK: - UI Setup
    
    /// Global UI styling for the navigation bar, background, and list spacing.
    private func setupUI() {
        self.title = "Provider Management"
        
        // Navigation Bar styling (Branding consistency).
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = titleAttributes
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table View Data Source (OOD Implementation)

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeuing and casting to the custom Provider cell type.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath) as? showProviderDetailsCell else {
            return UITableViewCell()
        }
        
        let provider = providers[indexPath.row]
        
        // Encapsulation: The cell is responsible for its own layout given the provider name.
        cell.configure(name: provider.fullName, category: "")
        return cell
    }

    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedProvider = providers[indexPath.row]
        
        // Trigger navigation to the detailed view.
        performSegue(withIdentifier: "showProviderDetailsSegue", sender: selectedProvider)
    }

    /// OOD Principle: Dependency Injection - Injecting the specific Provider object
    /// into the destination view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderDetailsSegue",
           let destinationVC = segue.destination as? ProviderDetailsTVC,
           let selectedProvider = sender as? Provider {
            destinationVC.provider = selectedProvider
        }
    }

    // MARK: - Administrative Actions (Delete Logic)

    /// trailingSwipeActionsConfiguration: Enables the "Swipe to Delete" UI for administrators.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            // Trigger the confirmation workflow.
            self?.deleteProvider(at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    /// Displays an alert to ensure the administrator intended to remove the user.
    private func deleteProvider(at indexPath: IndexPath) {
        let providerToDelete = providers[indexPath.row]
        let alert = UIAlertController(title: "Delete Provider", message: "Are you sure you want to delete \(providerToDelete.fullName)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(provider: providerToDelete)
        })
        present(alert, animated: true)
    }

    /// performDelete: Executes the actual removal command to the Firestore backend.
    private func performDelete(provider: Provider) {
        let db = Firestore.firestore()
        
        // Direct document deletion in the "users" collection.
        db.collection("users").document(provider.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to delete provider")
                return
            }
            
            /* Logic Note: Snapshot Listener handles local list and UI updates automatically
               once the server confirms deletion, ensuring "Source of Truth" integrity. */
            
            // Security Check: Kick user from the session if they happen to delete themselves.
            if let currentUser = Auth.auth().currentUser, currentUser.uid == provider.uid {
                self.kickUserFromApp()
            }
        }
    }

    // MARK: - User Session Management
    
    /// Forces a sign-out if the current authenticated user is removed from the database.
    private func kickUserFromApp() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch { print("Error signing out") }
    }

    /// Resets the app's root interface to the login screen (State Reset).
    private func navigateToLogin() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? UIViewController {
                loginVC.modalPresentationStyle = .fullScreen
                
                // Switching the Root View Controller via the SceneDelegate.
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = loginVC
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }

    /// Helper to show alerts to the administrator.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
