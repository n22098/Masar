import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderDetailsTVC: UITableViewController {

    // MARK: - Properties
    var provider: Provider?
    private var currentStatus: String = "Active"
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var statusBadge: UILabel!
    
    @IBOutlet weak var fullNameValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var phoneValueLabel: UILabel!
    @IBOutlet weak var usernameValueLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI()
        setupStatusMenu()
        loadData()
    }
    
    // MARK: - Setup
    private func setupNavigation() {
        title = "Provider Details"
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
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupUI() {
        profileImageView?.contentMode = .scaleAspectFill
        profileImageView?.layer.cornerRadius = 45
        profileImageView?.clipsToBounds = true
        profileImageView?.layer.borderWidth = 3
        profileImageView?.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        
        statusBadge?.font = .systemFont(ofSize: 13, weight: .semibold)
        statusBadge?.textAlignment = .center
        statusBadge?.layer.cornerRadius = 12
        statusBadge?.clipsToBounds = true
        
        statusButton?.layer.cornerRadius = 12
        statusButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        statusButton?.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        statusButton?.showsMenuAsPrimaryAction = true
        
        saveButton?.backgroundColor = brandColor
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.layer.cornerRadius = 16
        saveButton?.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add press animation for better feel
        saveButton?.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        saveButton?.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) { sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) { sender.transform = .identity }
    }

    // MARK: - Data Logic
    private func setupStatusMenu() {
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "Active"
                self?.updateStatusUI()
            },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill"), attributes: .destructive) { [weak self] _ in
                self?.currentStatus = "Ban"
                self?.updateStatusUI()
            }
        ]
        statusButton?.menu = UIMenu(children: actions)
    }
    
    private func loadData() {
        guard let provider = provider else { return }
        
        usernameLabel?.text = provider.username
        roleLabel?.text = provider.category
        fullNameValueLabel?.text = provider.fullName
        emailValueLabel?.text = provider.email
        phoneValueLabel?.text = provider.phone
        usernameValueLabel?.text = provider.username
        
        // Load the actual status from the provider object
        let status = provider.status
        if status.lowercased() == "ban" {
            currentStatus = "Ban"
        } else {
            currentStatus = "Active"
        }
        
        updateStatusUI()
    }
    
    private func updateStatusUI() {
        let isActive = currentStatus == "Active"
        let color: UIColor = isActive ? .systemGreen : .systemRed
        
        statusBadge?.text = currentStatus
        statusBadge?.textColor = color
        statusBadge?.backgroundColor = color.withAlphaComponent(0.15)
        
        statusButton?.setTitle(currentStatus, for: .normal)
        statusButton?.setTitleColor(color, for: .normal)
        statusButton?.backgroundColor = color.withAlphaComponent(0.15)
    }
    
    // MARK: - Firebase Action
    @objc func saveButtonTapped(_ sender: UIButton) {
        guard let uid = provider?.uid else { return }
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.6
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // 1. Update 'users' collection (Controls Login access)
        let userRef = db.collection("users").document(uid)
        batch.updateData(["status": currentStatus], forDocument: userRef)
        
        // 2. Update 'provider_requests' collection (Controls what shows in your List)
        let requestRef = db.collection("provider_requests").document(uid)
        batch.updateData(["status": currentStatus], forDocument: requestRef)
        
        // Commit both updates together
        batch.commit { [weak self] error in
            guard let self = self else { return }
            
            self.saveButton.isEnabled = true
            self.saveButton.alpha = 1.0
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                // Update local provider object
                self.provider?.status = self.currentStatus
                self.updateStatusUI()
                
                let alert = UIAlertController(title: "Success", message: "Status updated to \(self.currentStatus)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    // Return to previous screen
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
