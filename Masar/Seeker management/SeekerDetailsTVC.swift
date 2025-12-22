import UIKit

class SeekerDetailsTVC: UITableViewController {

    // MARK: - Properties
    var seeker: Seeker? // The seeker to display (nil for new seeker)
    var isNewSeeker: Bool = false // Track if we're adding a new seeker

    // MARK: - IBOutlets
    // Header Section
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var headerUserNameLabel: UILabel?
    @IBOutlet weak var headerRoleLabel: UILabel?
    @IBOutlet weak var headerStatusLabel: UILabel?
    
    // Personal Information Section
    @IBOutlet weak var fullNameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var usernameLabel: UILabel?
    
    // Account Status Section
    @IBOutlet weak var statusMenuButton: UIButton?
    
    // Track current status
    private var currentStatus: String = "Active"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStatusMenu()
        loadSeekerData()
    }

    private func setupUI() {
        // Making the profile image circular
        if let profileImageView = profileImageView {
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .scaleAspectFill
            
        }
        
        // Update title based on mode
        if isNewSeeker {
            self.title = "Add New Seeker"
        } else {
            self.title = "Seeker Details"
        }
    }
    
    private func loadSeekerData() {
        if let seeker = seeker {
            // Load existing seeker data
            headerUserNameLabel?.text = seeker.fullName
            fullNameLabel?.text = seeker.fullName
            emailLabel?.text = seeker.email
            phoneLabel?.text = seeker.phone
            usernameLabel?.text = seeker.username
            
            // Set status
            updateStatus(to: seeker.status, color: seeker.status == "Active" ? .systemBlue : .systemRed)
        } else {
            // Empty fields for new seeker
            headerUserNameLabel?.text = "New Seeker"
            fullNameLabel?.text = ""
            emailLabel?.text = ""
            phoneLabel?.text = ""
            usernameLabel?.text = ""
            
            // Default status to Active
            updateStatus(to: "Active", color: .systemBlue)
        }
        
        // Set role label
        headerRoleLabel?.text = "Seeker"
    }

    // MARK: - Status Menu Setup
    private func setupStatusMenu() {
        guard let statusMenuButton = statusMenuButton else { return }
        
        // Create Active action
        let activeAction = UIAction(
            title: "Active",
            image: UIImage(systemName: "checkmark.circle")
        ) { [weak self] _ in
            self?.updateStatus(to: "Active", color: .systemBlue)
        }
        
        // Create Suspend action
        let suspendAction = UIAction(
            title: "Suspend",
            image: UIImage(systemName: "pause.circle"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.updateStatus(to: "Suspend", color: .systemRed)
        }

        // Create and assign menu
        let menu = UIMenu(children: [activeAction, suspendAction])
        statusMenuButton.menu = menu
        statusMenuButton.showsMenuAsPrimaryAction = true
    }

    private func updateStatus(to status: String, color: UIColor) {
        currentStatus = status
        
        // Update the button appearance
        statusMenuButton?.setTitle(status, for: .normal)
        statusMenuButton?.setTitleColor(color, for: .normal)
        
        // Update the header status label
        headerStatusLabel?.text = status
        headerStatusLabel?.textColor = color
        
        // Optional: Print for debugging
        print("Status changed to: \(status)")
        
        // Optional: Add animation
        UIView.transition(with: statusMenuButton ?? UIView(),
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: {
            self.statusMenuButton?.setTitle(status, for: .normal)
        })
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
