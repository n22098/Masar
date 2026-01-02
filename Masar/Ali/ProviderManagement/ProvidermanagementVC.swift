import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderManagementVC: UITableViewController {
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    var providers: [Provider] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(showProviderDetailsCell.self, forCellReuseIdentifier: "showProviderDetailsCell")
        fetchProvidersFromFirestore()
    }
    
    func fetchProvidersFromFirestore() {
        let db = Firestore.firestore()
        db.collection("users").whereField("role", isEqualTo: "provider")
            .addSnapshotListener { (querySnapshot, error) in
            if let error = error { return }
            self.providers = []
            for document in querySnapshot!.documents {
                let newProvider = Provider(document: document)
                self.providers.append(newProvider)
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    private func setupUI() {
        self.title = "Provider Management"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath) as? showProviderDetailsCell else {
            return UITableViewCell()
        }
        let provider = providers[indexPath.row]
        // عرض اسم البروفايدر فقط
        cell.configure(name: provider.fullName, category: "")
        return cell
    }

    // MARK: - Navigation (إضافة منطق الانتقال)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // استخدام المعرف الذي وضعته في الـ Storyboard
        let selectedProvider = providers[indexPath.row]
        performSegue(withIdentifier: "showProviderDetailsSegue", sender: selectedProvider)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderDetailsSegue",
           let destinationVC = segue.destination as? ProviderDetailsTVC,
           let selectedProvider = sender as? Provider {
            // تمرير كائن الـ Provider للصفحة التالية
            destinationVC.provider = selectedProvider
        }
    }

    // MARK: - Actions (حذف البروفايدر)

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteProvider(at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func deleteProvider(at indexPath: IndexPath) {
        let providerToDelete = providers[indexPath.row]
        let alert = UIAlertController(title: "Delete Provider", message: "Are you sure you want to delete \(providerToDelete.fullName)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(provider: providerToDelete, at: indexPath)
        })
        present(alert, animated: true)
    }

    private func performDelete(provider: Provider, at indexPath: IndexPath) {
        let db = Firestore.firestore()
        db.collection("users").document(provider.uid).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to delete provider")
                return
            }
            self.providers.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let currentUser = Auth.auth().currentUser, currentUser.uid == provider.uid {
                self.kickUserFromApp()
            }
        }
    }

    private func kickUserFromApp() {
        do {
            try Auth.auth().signOut()
            navigateToLogin()
        } catch { print("Error signing out") }
    }

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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
