import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderDetailsTVC: UITableViewController {

    var provider: Provider?
    private var currentStatus: String = "Active"
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        // 1. Style Save Button (Purple background, White text)
        saveButton?.backgroundColor = brandColor
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.layer.cornerRadius = 15
        saveButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        // Shadow for Save Button
        saveButton?.layer.shadowColor = brandColor.cgColor
        saveButton?.layer.shadowOpacity = 0.3
        saveButton?.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton?.layer.shadowRadius = 8
        
        // 2. Style Status Button
        statusButton?.layer.cornerRadius = 15
        statusButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        // 3. Header Styling
        statusBadge?.layer.cornerRadius = 10
        statusBadge?.clipsToBounds = true
        statusBadge?.font = .systemFont(ofSize: 12, weight: .bold)
        
        // Profile Image Setup (Person Circle Icon)
        profileImageView?.image = UIImage(systemName: "person.circle.fill")
        profileImageView?.tintColor = brandColor.withAlphaComponent(0.3)
        profileImageView?.layer.cornerRadius = 45
        profileImageView?.clipsToBounds = true
        
        // 4. Add Interactions (Hover/Press effect)
        [saveButton, statusButton].forEach { button in
            button?.addTarget(self, action: #selector(handlePressDown), for: .touchDown)
            button?.addTarget(self, action: #selector(handlePressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
        
        setupStatusMenu()
    }

    // MARK: - Interactions (Hover Effects)
    @objc private func handlePressDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.9
        }
    }

    @objc private func handlePressUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
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
        statusButton?.showsMenuAsPrimaryAction = true
    }
    
    private func loadData() {
        guard let provider = provider else { return }
        usernameLabel?.text = provider.fullName
        roleLabel?.text = "Provider"
        fullNameValueLabel?.text = provider.fullName
        emailValueLabel?.text = provider.email
        phoneValueLabel?.text = provider.phone
        usernameValueLabel?.text = provider.username
        currentStatus = provider.status
        updateStatusUI()
    }
    
    private func updateStatusUI() {
        let isBan = currentStatus.lowercased() == "ban"
        let color: UIColor = isBan ? .systemRed : .systemGreen
        let displayStatus = isBan ? "Ban" : "Active"
        
        statusBadge?.text = "  \(displayStatus.uppercased())  "
        statusBadge?.textColor = color
        statusBadge?.backgroundColor = color.withAlphaComponent(0.12)
        
        statusButton?.setTitle(displayStatus, for: .normal)
        statusButton?.backgroundColor = color.withAlphaComponent(0.1)
        statusButton?.setTitleColor(color, for: .normal)
        statusButton?.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        statusButton?.layer.borderWidth = 1
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let uid = provider?.uid else { return }
        saveButton.isEnabled = false
        
        Firestore.firestore().collection("users").document(uid).updateData(["status": currentStatus]) { [weak self] error in
            guard let self = self else { return }
            self.saveButton.isEnabled = true
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.provider?.status = self.currentStatus
                let msg = self.currentStatus == "Ban" ? "Provider banned successfully" : "Provider activated successfully"
                self.showAlert(title: "Success", message: msg)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
