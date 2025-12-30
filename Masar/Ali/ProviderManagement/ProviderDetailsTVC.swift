import UIKit

class ProviderDetailsTVC: UITableViewController {

    // MARK: - Properties
    var provider: Provider? // The provider to display
    var isNewProvider: Bool = false

    // MARK: - IBOutlets
    // Header Section (Top Blue Box in your screenshot)
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var headerProviderNameLabel: UILabel?
    @IBOutlet weak var headerStatusLabel: UILabel?
    
    // Personal Information Section (Middle Section)
    @IBOutlet weak var fullNameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var phoneTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    
    // Account Status Section (Bottom Section)
    @IBOutlet weak var statusMenuButton: UIButton?
    @IBOutlet weak var aboutButton: UIButton? // The "About" button in your screenshot
    
    // Track current status
    private var currentStatus: String = "Active"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStatusMenu()
        loadProviderData()
    }

    private func setupUI() {
        // Making the profile image circular
        if let profileImageView = profileImageView {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.backgroundColor = .systemGray5 // Placeholder color
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        }
        
        // Update title based on mode
        self.title = isNewProvider ? "Add New Provider" : "Provider Details"
    }
    
    private func loadProviderData() {
        if let provider = provider {
            // Load existing provider data
            headerProviderNameLabel?.text = provider.fullName
            fullNameTextField?.text = provider.fullName
            emailTextField?.text = provider.email
            phoneTextField?.text = provider.phone
            usernameTextField?.text = provider.username
            
            // Set status
            let statusColor: UIColor = (provider.status == "Active") ? .systemBlue : .systemRed
            updateStatus(to: provider.status, color: statusColor)
        } else {
            // Empty fields for new provider
            headerProviderNameLabel?.text = "New Provider"
            fullNameTextField?.text = ""
            emailTextField?.text = ""
            phoneTextField?.text = ""
            usernameTextField?.text = ""
            
            updateStatus(to: "Active", color: .systemBlue)
        }
    }

    // MARK: - Status Menu Setup
    private func setupStatusMenu() {
        guard let statusMenuButton = statusMenuButton else { return }
        
        let activeAction = UIAction(
            title: "Active",
            image: UIImage(systemName: "checkmark.circle")
        ) { [weak self] _ in
            self?.updateStatus(to: "Active", color: .systemBlue)
        }
        
        let suspendAction = UIAction(
            title: "Suspend",
            image: UIImage(systemName: "pause.circle"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.updateStatus(to: "Suspend", color: .systemRed)
        }

        let menu = UIMenu(title: "Change Status", children: [activeAction, suspendAction])
        statusMenuButton.menu = menu
        statusMenuButton.showsMenuAsPrimaryAction = true
    }

    private func updateStatus(to status: String, color: UIColor) {
        currentStatus = status
        
        // Update Button
        statusMenuButton?.setTitle(status, for: .normal)
        statusMenuButton?.setTitleColor(color, for: .normal)
        
        // Update Header Label
        headerStatusLabel?.text = status
        headerStatusLabel?.textColor = color
        
        // Animation for smooth transition
        if let btn = statusMenuButton {
            UIView.transition(with: btn, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Actions

        @IBAction func aboutButtonTapped(_ sender: UIButton) {
            // Option 1: Using a Segue (If you created a segue in Storyboard)
            // self.performSegue(withIdentifier: "goToAboutScreen", sender: self)
            
            // Option 2: Programmatic Navigation (Once you create the AboutViewController)
            /*
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
                self.navigationController?.pushViewController(aboutVC, animated: true)
            }
            */
            
            // Temporary Placeholder: Show an alert so you know the button works
            let alert = UIAlertController(
                title: "Coming Soon",
                message: "The About screen for this provider is under development.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        }
    @objc private func saveButtonTapped() {
        // 1. Collect data from your labels/UI
        // Note: If you allow editing, these should be UIFields. If they are just labels,
        // we use the current text or the original provider data.
        let name = fullNameTextField?.text ?? ""
        let email = emailTextField?.text ?? ""
        let phone = phoneTextField?.text ?? ""
        let username = usernameTextField?.text ?? ""
        let status = currentStatus // Captured from the menu selection
        
        // 2. Validate data (Optional but recommended)
        if name.isEmpty || email.isEmpty {
            showAlert(message: "Please ensure Name and Email are provided.")
            return
        }
        
        // 3. Create or Update the Provider object
        let updatedProvider = Provider(
            fullName: name,
            email: email,
            phone: phone,
            username: username,
            category: provider?.category ?? "",
            status: status,
            imageName: "default_profile",
            roleType: "Provider"
        )

        
        // 4. Save to your Data Source (API, Firebase, or CoreData)
        if isNewProvider {
            print("Saving new provider: \(updatedProvider.fullName)")
            // Call your create service here
        } else {
            print("Updating existing provider: \(updatedProvider.fullName)")
            // Call your update service here
        }
        
        // 5. Dismiss or Pop back to the list
        navigationController?.popViewController(animated: true)
    }

    // Helper for validation alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
