import UIKit
import FirebaseFirestore
import FirebaseAuth

class SeekerDetailsTVC: UITableViewController {

    var seeker: Seeker?
    var isNewSeeker: Bool = false
    private var currentStatus: String = "Active"
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Header outlets - connect these in storyboard
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var statusBadge: UILabel!
    
    // Cell outlets - connect these to your static cells in storyboard
    @IBOutlet weak var fullNameValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var phoneValueLabel: UILabel!
    @IBOutlet weak var usernameValueLabel: UILabel!
    
    // Footer outlets - connect these in storyboard
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupStatusMenu()
        setupUI()
        loadData()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupNavigation() {
        title = "Seeker Details"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    private func setupUI() {
        // Setup profile image
        profileImageView?.contentMode = .scaleAspectFill
        profileImageView?.layer.cornerRadius = 45
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.borderWidth = 3
        profileImageView?.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        
        // Setup status badge
        statusBadge?.font = .systemFont(ofSize: 13, weight: .semibold)
        statusBadge?.textAlignment = .center
        statusBadge?.layer.cornerRadius = 12
        statusBadge?.clipsToBounds = true
        
        // Setup status button
        statusButton?.layer.cornerRadius = 12
        statusButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        statusButton?.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        statusButton?.showsMenuAsPrimaryAction = true
        
        // Setup save button with better style
        saveButton?.backgroundColor = brandColor
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        saveButton?.layer.cornerRadius = 16
        saveButton?.layer.shadowColor = brandColor.cgColor
        saveButton?.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton?.layer.shadowRadius = 12
        saveButton?.layer.shadowOpacity = 0.3
        saveButton?.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        saveButton?.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add press animation
        saveButton?.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        saveButton?.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.saveButton?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.saveButton?.transform = .identity
        }
    }
    
    private func setupStatusMenu() {
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "Active"
                self?.updateStatusUI()
            },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "Ban"
                self?.updateStatusUI()
            }
        ]
        statusButton?.menu = UIMenu(children: actions)
    }
    
    private func loadData() {
        guard let seeker = seeker else { return }
        
        // Update header
        profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView?.tintColor = brandColor.withAlphaComponent(0.5)
        usernameLabel?.text = seeker.username.isEmpty ? "N/A" : seeker.username
        roleLabel?.text = seeker.role.isEmpty ? "Seeker" : seeker.role
        
        // Update cell values with ACTUAL data
        fullNameValueLabel?.text = seeker.fullName.isEmpty ? "N/A" : seeker.fullName
        emailValueLabel?.text = seeker.email.isEmpty ? "N/A" : seeker.email
        phoneValueLabel?.text = seeker.phone.isEmpty ? "N/A" : seeker.phone
        usernameValueLabel?.text = seeker.username.isEmpty ? "N/A" : seeker.username
        
        // Force UI update
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        // Update status
        currentStatus = seeker.status
        updateStatusUI()
    }
    
    private func updateStatusUI() {
        let color: UIColor = currentStatus == "Active" ? .systemGreen : .systemRed
        
        // Update badge in header
        statusBadge?.text = currentStatus
        statusBadge?.textColor = color
        statusBadge?.backgroundColor = color.withAlphaComponent(0.15)
        
        // Update status button
        statusButton?.setTitle(currentStatus, for: .normal)
        statusButton?.backgroundColor = color.withAlphaComponent(0.15)
        statusButton?.setTitleColor(color, for: .normal)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let uid = seeker?.uid else {
            showAlert(title: "Error", message: "User ID not found")
            return
        }
        
        saveButton?.isEnabled = false
        saveButton?.alpha = 0.6
        
        Firestore.firestore().collection("users").document(uid).updateData(["status": currentStatus]) { [weak self] error in
            guard let self = self else { return }
            
            self.saveButton?.isEnabled = true
            self.saveButton?.alpha = 1.0
            
            if let error {
                print("❌ \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to update status.")
            } else {
                print("✅ Status updated to \(self.currentStatus)")
                
                // Update seeker object
                self.seeker?.status = self.currentStatus
                
                if self.currentStatus == "Ban" {
                    self.kickUserFromApp(uid: uid)
                }
                
                self.showAlert(title: "Success", message: "User status updated to \(self.currentStatus)")
            }
        }
    }
    
    private func kickUserFromApp(uid: String) {
        if let currentUser = Auth.auth().currentUser, currentUser.uid == uid {
            do {
                try Auth.auth().signOut()
                navigateToLogin()
            } catch {
                print("❌ \(error.localizedDescription)")
            }
        }
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
