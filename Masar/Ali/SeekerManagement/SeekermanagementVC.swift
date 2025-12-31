import UIKit
import FirebaseFirestore
import FirebaseAuth

class SeekermanagementVC: UITableViewController {

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Array to hold Firestore data
    var seekers: [Seeker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Register Cell
        tableView.register(showSeekerDetailsCell.self, forCellReuseIdentifier: "showSeekerDetailsCell")
        
        // Fetch Data
        fetchSeekersFromFirestore()
    }
    
    // MARK: - Firebase Fetching
    func fetchSeekersFromFirestore() {
        let db = Firestore.firestore()
        
        // Get users where role is "seeker"
        db.collection("users").whereField("role", isEqualTo: "seeker")
            .addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.seekers = [] // Clear list
            
            for document in querySnapshot!.documents {
                let newSeeker = Seeker(document: document)
                self.seekers.append(newSeeker)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UI Setup
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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath) as? showSeekerDetailsCell else {
            return UITableViewCell()
        }
        
        let seeker = seekers[indexPath.row]
        cell.configure(name: seeker.fullName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        performSegue(withIdentifier: "showSeekerDetailsSegue", sender: nil)
    }
    
    // 🔥 NEW: Swipe to Delete Functionality
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteSeeker(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    // 🔥 NEW: Delete Seeker Function
    private func deleteSeeker(at indexPath: IndexPath) {
        let seekerToDelete = seekers[indexPath.row]
        
        let alert = UIAlertController(
            title: "Delete Seeker",
            message: "Are you sure you want to delete \(seekerToDelete.fullName)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(seeker: seekerToDelete, at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    // 🔥 NEW: Perform Delete from Firebase
    private func performDelete(seeker: Seeker, at indexPath: IndexPath) {
        let db = Firestore.firestore()
        
        // Delete from Firebase
        db.collection("users").document(seeker.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error deleting seeker: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to delete seeker")
                return
            }
            
            print("✅ Seeker deleted from Firebase: \(seeker.uid)")
            
            // Remove from local array
            self.seekers.remove(at: indexPath.row)
            
            // Update table view
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            // If deleted user is currently logged in, kick them out
            if let currentUser = Auth.auth().currentUser, currentUser.uid == seeker.uid {
                self.kickUserFromApp()
            }
            
            self.showAlert(title: "Success", message: "Seeker deleted successfully")
        }
    }
    
    // 🔥 NEW: Kick user from app if they delete themselves
    private func kickUserFromApp() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    // 🔥 NEW: Navigate to login screen
    private func navigateToLogin() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? UIViewController {
                loginVC.modalPresentationStyle = .fullScreen
                
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.window?.rootViewController = loginVC
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    // 🔥 NEW: Show alert helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SeekerDetailsTVC {
            if segue.identifier == "showSeekerDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailVC.seeker = seekers[indexPath.row]
                    detailVC.isNewSeeker = false
                }
            } else if segue.identifier == "addSeekerSegue" {
                detailVC.seeker = nil
                detailVC.isNewSeeker = true
            }
        }
    }
}
