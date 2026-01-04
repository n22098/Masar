import UIKit
import FirebaseFirestore
import FirebaseAuth

/// SeekermanagementVC: Manages the list of "Seeker" users for the administrator.
/// OOD Principle: Observer Pattern - Using addSnapshotListener to keep the UI
/// in constant sync with the Firestore database.
class SeekermanagementVC: UITableViewController {

    /// Centralized brand color for UI consistency.
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Properties
    /// seekers: The "Source of Truth" array for the TableView.
    var seekers: [Seeker] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Registering the custom cell used for displaying seeker summaries.
        tableView.register(showSeekerDetailsCell.self, forCellReuseIdentifier: "showSeekerDetailsCell")
        
        // Initiate the real-time data connection.
        fetchSeekersFromFirestore()
    }
    
    // MARK: - Firebase Fetching
    
    /// fetchSeekersFromFirestore: Sets up a live stream of data from the "users" collection.
    /// OOD Principle: Reactive Programming - The app reacts to database changes automatically.
    func fetchSeekersFromFirestore() {
        let db = Firestore.firestore()
        
        // Querying users with the specific role of "seeker"
        db.collection("users").whereField("role", isEqualTo: "seeker")
            .addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            // Clear the local list before repopulating with the latest snapshot.
            self.seekers = []
            
            // Mapping Firestore Documents to Seeker Model objects.
            for document in querySnapshot!.documents {
                let newSeeker = Seeker(document: document)
                self.seekers.append(newSeeker)
            }
            
            // UI Thread Safety: Always reload data on the main thread.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UI Setup
    
    /// Configures the visual identity of the navigation bar and table background.
    private func setupUI() {
        self.title = "Seeker Management"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source logic
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeuing and casting to our custom cell type.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath) as? showSeekerDetailsCell else {
            return UITableViewCell()
        }
        
        let seeker = seekers[indexPath.row]
        // Encapsulation: The cell handles its own text layout based on the name we provide.
        cell.configure(name: seeker.name)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // UX: Deselecting the row shortly after tap for a cleaner interaction feel.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        performSegue(withIdentifier: "showSeekerDetailsSegue", sender: nil)
    }
    
    // MARK: - Swipe to Delete Functionality
    
    /// Enables the administrative "Swipe to Delete" feature on user rows.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            // Trigger the confirmation workflow.
            self?.deleteSeeker(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // MARK: - Deletion Logic
    
    /// Displays a confirmation alert to prevent accidental user deletion.
    private func deleteSeeker(at indexPath: IndexPath) {
        let seekerToDelete = seekers[indexPath.row]
        
        let alert = UIAlertController(
            title: "Delete Seeker",
            message: "Are you sure you want to delete \(seekerToDelete.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(seeker: seekerToDelete)
        })
        
        present(alert, animated: true)
    }
    
    /// performDelete: Executes the actual removal command to Firebase.
    private func performDelete(seeker: Seeker) {
        let db = Firestore.firestore()
        
        // Permanent deletion from the Cloud Database.
        db.collection("users").document(seeker.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error deleting seeker: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to delete seeker")
                return
            }
            
            print("✅ Seeker deleted from Firebase: \(seeker.uid)")
            
            /* Technical Note: We do not manually remove the item from the 'seekers' array.
               The 'addSnapshotListener' will detect the deletion on the server and
               refresh the UI automatically, ensuring the local view matches the server.
            */
            
            // Security Logic: If the deleted user is the one currently logged in, log them out.
            if let currentUser = Auth.auth().currentUser, currentUser.uid == seeker.uid {
                self.kickUserFromApp()
            }
            
            self.showAlert(title: "Success", message: "Seeker deleted successfully")
        }
    }
    
    // MARK: - Session Management
    
    /// Kicks the user out of the app session if their account is removed.
    private func kickUserFromApp() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    /// navigateToLogin: Resets the root of the app to the entry screen.
    private func navigateToLogin() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? UIViewController {
                loginVC.modalPresentationStyle = .fullScreen
                
                // Switching the Window's Root Controller to the login screen.
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = loginVC
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    /// Helper to present quick feedback messages to the admin.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    
    /// OOD Principle: Dependency Injection - Passing the Seeker object to the detail screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SeekerDetailsTVC {
            if segue.identifier == "showSeekerDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Injecting the existing seeker data for editing.
                    detailVC.seeker = seekers[indexPath.row]
                    detailVC.isNewSeeker = false
                }
            } else if segue.identifier == "addSeekerSegue" {
                // Setting up the detail screen for a fresh user entry.
                detailVC.seeker = nil
                detailVC.isNewSeeker = true
            }
        }
    }
}
