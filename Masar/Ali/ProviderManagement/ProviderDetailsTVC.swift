import UIKit
import FirebaseFirestore
import FirebaseAuth

/// ProviderDetailsTVC: Manages the detailed profile and administrative actions for a Service Provider.
/// OOD Principle: Encapsulation - All specific data handling for a Provider object is contained
/// within this controller to protect the integrity of the user data.
class ProviderDetailsTVC: UITableViewController {

    // MARK: - Properties
    /// provider: The Model object injected from the management list.
    var provider: Provider?
    
    /// currentStatus: Tracks the pending status change (Active/Ban) before committing to Firestore.
    private var currentStatus: String = "Active"
    
    // MARK: - Theme Colors (Centralized UI Branding)
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let secondaryTextColor = UIColor.systemGray
    let surfaceColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1.0)
    
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
        setupStatusMenu() // Prepares the interaction menu
        loadData()        // Populates UI from the Model
        
        // UI Polish: Removes the default padding above the first section in iOS 15+
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// setupNavigation: Configures the Navigation Bar appearance.
    private func setupNavigation() {
        title = "Provider Details"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    /// setupTableView: Sets background and removes default separators for a card-based layout.
    private func setupTableView() {
        tableView.backgroundColor = surfaceColor
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    /// setupUI: Configures subview properties (Fonts, Corners, and Alignment).
    private func setupUI() {
        usernameLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        roleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        roleLabel?.textColor = secondaryTextColor
        
        // Iterative Styling: Applying common styles to all value labels
        [fullNameValueLabel, emailValueLabel, phoneValueLabel, usernameValueLabel].forEach { label in
            label?.font = .systemFont(ofSize: 15, weight: .semibold)
            label?.textColor = .darkGray
            label?.textAlignment = .left
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.5
        }

        // Circular Image Masking (Encapsulation of visual logic)
        profileImageView?.layer.cornerRadius = 45
        profileImageView?.layer.borderWidth = 4
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        profileImageView?.clipsToBounds = true
        profileImageView?.contentMode = .scaleAspectFill
        
        statusBadge?.layer.cornerRadius = 4
        statusBadge?.clipsToBounds = true
        
        // Status Button Interaction
        statusButton?.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        statusButton?.layer.cornerRadius = 15
        statusButton?.showsMenuAsPrimaryAction = true // Enables modern UIMenu behavior
        
        // Save Button Styling
        saveButton?.backgroundColor = brandColor
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        saveButton?.layer.cornerRadius = 15
        saveButton?.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    /// setupStatusMenu: Creates the administrative dropdown for changing account status.
    /// OOD Principle: Command Pattern - Each menu action performs a specific logic update.
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
    
    /// loadData: Injects the Model data into the UI Views.
    /// Includes asynchronous image loading to prevent Main Thread blocking.
    private func loadData() {
        guard let provider = provider else { return }
        
        // Asynchronous Networking: Fetching profile image from URL
        if let urlString = provider.profileImageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { self?.profileImageView.image = image }
                }
            }.resume()
        } else {
            profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        }
        
        usernameLabel?.text = provider.fullName
        roleLabel?.text = provider.role.uppercased()
        fullNameValueLabel?.text = provider.fullName
        emailValueLabel?.text = provider.email
        phoneValueLabel?.text = provider.phone
        usernameValueLabel?.text = provider.username
        
        currentStatus = provider.status
        updateStatusUI()
    }
    
    /// updateStatusUI: Updates UI colors based on whether the provider is Active or Banned.
    private func updateStatusUI() {
        let isBan = currentStatus.lowercased() == "ban"
        let color: UIColor = isBan ? .systemRed : .systemGreen
        
        statusBadge?.text = currentStatus.uppercased()
        statusBadge?.textColor = color
        statusBadge?.backgroundColor = color.withAlphaComponent(0.12)
        
        statusButton?.setTitle(currentStatus, for: .normal)
        statusButton?.setTitleColor(color, for: .normal)
        statusButton?.backgroundColor = color.withAlphaComponent(0.1)
        statusButton?.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        statusButton?.layer.borderWidth = 1
    }

    // MARK: - TableView Design Logic
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            let label = UILabel()
            label.text = "Personal Information"
            label.font = .systemFont(ofSize: 14, weight: .bold)
            label.textColor = .systemGray
            label.frame = CGRect(x: 20, y: 10, width: 200, height: 20)
            headerView.addSubview(label)
            return headerView
        }
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 140 }
        if indexPath.section == tableView.numberOfSections - 1 { return 65 }
        return 50
    }

    /// willDisplay: Programmatically draws card backgrounds for specific sections.
    /// OOD Principle: Custom Drawing via CALayer for optimized UI rendering.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Clean up previous layers to avoid "ghosting" during scroll (Memory Efficiency)
        cell.contentView.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        
        let totalSections = tableView.numberOfSections
        if indexPath.section > 0 && indexPath.section < (totalSections - 1) {
            let cardLayer = CAShapeLayer()
            cardLayer.fillColor = UIColor.white.cgColor
            let cardFrame = cell.bounds.inset(by: UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16))
            cardLayer.path = UIBezierPath(roundedRect: cardFrame, cornerRadius: 12).cgPath
            cell.layer.insertSublayer(cardLayer, at: 0)
        }
    }

    // MARK: - Persistence Logic
    
    /// saveButtonTapped: Commits user status changes to the Firestore database.
    @objc @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let uid = provider?.uid else { return }
        saveButton?.isEnabled = false // UI feedback: prevent spam clicks
        
        // Updating remote document
        Firestore.firestore().collection("users").document(uid).updateData(["status": currentStatus]) { [weak self] error in
            guard let self = self else { return }
            self.saveButton?.isEnabled = true
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                // Sync the local model with the newly saved status
                self.provider?.status = self.currentStatus
                self.showAlert(title: "Success", message: "Updated successfully")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
