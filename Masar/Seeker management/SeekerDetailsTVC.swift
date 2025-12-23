import UIKit

class SeekerDetailsTVC: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var headerUserNameLabel: UILabel?
    @IBOutlet weak var headerRoleLabel: UILabel?
    @IBOutlet weak var headerStatusLabel: UILabel?
    
    @IBOutlet weak var fullNameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var phoneTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    
    @IBOutlet weak var statusMenuButton: UIButton?

    // MARK: - Properties
    var seeker: Seeker?
    var isNewSeeker: Bool = false
    private var currentStatus: String = "Active"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🚀 SeekerDetailsTVC viewDidLoad called")
        
        // Testing fallback - load sample data if no seeker provided
        if seeker == nil && !isNewSeeker {
            print("⚠️ No seeker provided, loading sample data...")
            seeker = SampleData.seekers.first(where: { $0.fullName == "John Doe" })
            if let seeker = seeker {
                print("✅ Sample seeker loaded: \(seeker.fullName)")
            } else {
                print("❌ Failed to load sample seeker")
            }
        }
        
        setupUI()
        setupStatusMenu()
        loadSeekerData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("👁️ View appeared - checking text field values:")
        print("  Full Name field: '\(fullNameTextField?.text ?? "")'")
        print("  Email field: '\(emailTextField?.text ?? "")'")
        print("  Phone field: '\(phoneTextField?.text ?? "")'")
        print("  Username field: '\(usernameTextField?.text ?? "")'")
    }

    // MARK: - Setup Methods
    private func setupUI() {
        print("🎨 Setting up UI...")
        
        // Setup profile image
        if let profileImageView = profileImageView {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            print("  Profile image view configured")
        } else {
            print("  ⚠️ Profile image view is nil")
        }
        
        // Set title
        self.title = isNewSeeker ? "Add New Seeker" : "Seeker Details"
        print("  Title set to: \(self.title ?? "")")
    }

    private func setupStatusMenu() {
        print("📋 Setting up status menu...")
        
        guard let statusMenuButton = statusMenuButton else {
            print("  ⚠️ Status menu button is nil")
            return
        }
        
        let activeAction = UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
            self?.updateStatus(to: "Active", color: .systemBlue)
        }
        
        let suspendAction = UIAction(title: "Suspend", image: UIImage(systemName: "pause.circle")) { [weak self] _ in
            self?.updateStatus(to: "Suspend", color: .systemOrange)
        }
        
        let banAction = UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle")) { [weak self] _ in
            self?.updateStatus(to: "Ban", color: .systemRed)
        }
        
        statusMenuButton.menu = UIMenu(children: [activeAction, suspendAction, banAction])
        statusMenuButton.showsMenuAsPrimaryAction = true
        print("  ✅ Status menu configured with 3 actions")
    }

    private func loadSeekerData() {
        print("\n📂 Loading seeker data...")
        
        guard let seeker = seeker else {
            print("❌ No seeker data available")
            return
        }
        
        print("✅ Seeker object exists: \(seeker.fullName)")
        
        // Debug outlet connections
        print("\n🔌 Checking Outlet Connections:")
        print("  - profileImageView: \(profileImageView != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - headerUserNameLabel: \(headerUserNameLabel != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - headerRoleLabel: \(headerRoleLabel != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - headerStatusLabel: \(headerStatusLabel != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - fullNameTextField: \(fullNameTextField != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - emailTextField: \(emailTextField != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - phoneTextField: \(phoneTextField != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - usernameTextField: \(usernameTextField != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        print("  - statusMenuButton: \(statusMenuButton != nil ? "✓ Connected" : "✗ NOT CONNECTED")")
        
        // Update Header Labels
        print("\n📝 Updating header labels...")
        headerUserNameLabel?.text = seeker.fullName
        print("  - Header username set to: '\(seeker.fullName)'")
        
        headerRoleLabel?.text = seeker.roleType
        print("  - Header role set to: '\(seeker.roleType)'")
        
        headerStatusLabel?.text = seeker.status
        print("  - Header status set to: '\(seeker.status)'")
        
        // Update Text Fields
        print("\n✍️ Updating text fields...")
        
        fullNameTextField?.text = seeker.fullName
        print("  - Full Name: '\(seeker.fullName)' → field value: '\(fullNameTextField?.text ?? "")'")
        
        emailTextField?.text = seeker.email
        print("  - Email: '\(seeker.email)' → field value: '\(emailTextField?.text ?? "")'")
        
        phoneTextField?.text = seeker.phone
        print("  - Phone: '\(seeker.phone)' → field value: '\(phoneTextField?.text ?? "")'")
        
        usernameTextField?.text = seeker.username
        print("  - Username: '\(seeker.username)' → field value: '\(usernameTextField?.text ?? "")'")
        
        // Update profile image - imageName is non-optional String
        let imageName = seeker.imageName
        if !imageName.isEmpty, let image = UIImage(named: imageName) {
            profileImageView?.image = image
            print("  - Profile image loaded: '\(imageName)'")
        } else {
            profileImageView?.image = UIImage(systemName: "person.circle.fill")
            print("  - Using default profile image (imageName: '\(imageName)')")
        }
        
        // Update status
        let statusColor: UIColor = {
            switch seeker.status {
            case "Active": return .systemBlue
            case "Suspend": return .systemOrange
            case "Ban": return .systemRed
            default: return .systemGray
            }
        }()
        
        updateStatus(to: seeker.status, color: statusColor)
        
        print("\n✅ Data loading complete\n")
    }

    private func updateStatus(to status: String, color: UIColor) {
        print("🔄 Updating status to: '\(status)' with color: \(color)")
        
        currentStatus = status
        statusMenuButton?.setTitle(status, for: .normal)
        statusMenuButton?.setTitleColor(color, for: .normal)
        headerStatusLabel?.text = status
        headerStatusLabel?.textColor = color
        
        // Update seeker object
        seeker?.status = status
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        print("\n💾 Save button tapped")
        saveSeekerData()
    }
    
    private func saveSeekerData() {
        print("Saving seeker data...")
        
        // Get text field values with empty string as default
        let fullName = fullNameTextField?.text ?? ""
        let email = emailTextField?.text ?? ""
        let phone = phoneTextField?.text ?? ""
        let username = usernameTextField?.text ?? ""
        
        // Validate inputs
        guard !fullName.isEmpty else {
            showAlert(title: "Error", message: "Full name is required")
            return
        }
        
        guard !email.isEmpty else {
            showAlert(title: "Error", message: "Email is required")
            return
        }
        
        guard !phone.isEmpty else {
            showAlert(title: "Error", message: "Phone is required")
            return
        }
        
        guard !username.isEmpty else {
            showAlert(title: "Error", message: "Username is required")
            return
        }
        
        // Update or create seeker
        if isNewSeeker {
            let newSeeker = Seeker(
                fullName: fullName,
                email: email,
                phone: phone,
                username: username,
                status: currentStatus,
                imageName: "profile1",  // Use default image name instead of nil
                roleType: "Seeker"
            )
            SampleData.seekers.append(newSeeker)
            print("✅ New seeker created: \(fullName)")
            print("📊 Total seekers now: \(SampleData.seekers.count)")
        } else {
            // Find and update the existing seeker in the array
            if let index = SampleData.seekers.firstIndex(where: { $0.fullName == seeker?.fullName }) {
                SampleData.seekers[index].fullName = fullName
                SampleData.seekers[index].email = email
                SampleData.seekers[index].phone = phone
                SampleData.seekers[index].username = username
                SampleData.seekers[index].status = currentStatus
                
                // Also update the local reference
                seeker?.fullName = fullName
                seeker?.email = email
                seeker?.phone = phone
                seeker?.username = username
                seeker?.status = currentStatus
                
                print("✅ Seeker updated at index \(index): \(fullName)")
            }
        }
        
        showAlert(title: "Success", message: "Seeker saved successfully") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
