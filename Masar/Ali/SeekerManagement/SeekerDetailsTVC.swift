import UIKit
import FirebaseFirestore
import FirebaseAuth

/// SeekerDetailsTVC: Manages the detailed profile view of a "Seeker" user for administrators.
/// OOD Principle: Encapsulation - This controller manages the state of a single Seeker object
/// and handles all UI updates related to that user's status.
class SeekerDetailsTVC: UITableViewController {

    // MARK: - Properties
    /// seeker: The data model passed from the previous list screen.
    var seeker: Seeker?
    var isNewSeeker: Bool = false
    
    /// currentStatus: A local variable to track UI changes before saving to the database.
    private var currentStatus: String = "Active"
    
    // MARK: - Theme Colors (Centralized UI Management)
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
        setupStatusMenu() // Initializes the interactive dropdown for status
        loadData()        // Populates the UI with seeker data
        
        // Remove modern iOS header padding for a tighter design
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// setupNavigation: Configures the top bar style and title.
    private func setupNavigation() {
        title = isNewSeeker ? "Add Seeker" : "Seeker Details"
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
    
    /// setupTableView: Configures the list appearance.
    private func setupTableView() {
        tableView.backgroundColor = surfaceColor
        tableView.separatorStyle = .none // Using custom card styling instead
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    /// setupUI: Applies visual styles (fonts, corners, borders) to the UI components.
    private func setupUI() {
        usernameLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        roleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        roleLabel?.textColor = secondaryTextColor
        
        // Mapping styles to information labels
        [fullNameValueLabel, emailValueLabel, phoneValueLabel, usernameValueLabel].forEach { label in
            label?.font = .systemFont(ofSize: 15, weight: .semibold)
            label?.textColor = .darkGray
            label?.textAlignment = .left
            label?.baselineAdjustment = .alignBaselines
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.5
            label?.numberOfLines = 1
        }

        // Circular Profile Image (Encapsulation of drawing logic)
        profileImageView?.layer.cornerRadius = 45
        profileImageView?.layer.borderWidth = 4
        profileImageView?.layer.borderColor = UIColor.white.cgColor
        profileImageView?.clipsToBounds = true
        profileImageView?.contentMode = .scaleAspectFill
        
        statusBadge?.layer.cornerRadius = 4
        statusBadge?.clipsToBounds = true
        
        // Button Setup
        statusButton?.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        statusButton?.layer.cornerRadius = 15
        statusButton?.showsMenuAsPrimaryAction = true // Enables the UIMenu
        
        saveButton?.backgroundColor = brandColor
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        saveButton?.layer.cornerRadius = 15
        saveButton?.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    /// loadData: Transfers model data into the UI.
    /// Demonstrates: Asynchronous image loading for better performance.
    private func loadData() {
        guard let seeker = seeker else { return }
        
        // Logic: Download profile image if URL exists
        if let urlString = seeker.profileImageURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { self?.profileImageView.image = image }
                }
            }.resume()
        } else {
            // Fallback to a system icon
            profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        }
        
        usernameLabel?.text = seeker.username
        roleLabel?.text = seeker.role.uppercased()
        fullNameValueLabel?.text = seeker.name
        emailValueLabel?.text = seeker.email
        phoneValueLabel?.text = seeker.phone
        usernameValueLabel?.text = seeker.username
        
        currentStatus = seeker.status
        updateStatusUI()
    }

    /// updateStatusUI: Dynamically changes colors and text based on the "Active/Ban" state.
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
    }

    /// setupStatusMenu: Creates a professional interaction menu for admins.
    private func setupStatusMenu() {
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "Active"; self?.updateStatusUI()
            },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "Ban"; self?.updateStatusUI()
            }
        ]
        statusButton?.menu = UIMenu(children: actions)
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
        if indexPath.section == 0 { return 140 } // Profile header
        if indexPath.section == tableView.numberOfSections - 1 { return 65 } // Save button
        return 50 // Standard rows
    }

    /// willDisplay: Used to inject custom "Card" backgrounds into the cells.
    /// OOD Principle: UI customization through Layer manipulation.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Remove existing custom layers before adding new ones (Performance/Sync)
        cell.contentView.layer.sublayers?.filter { $0 is CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        
        let totalSections = tableView.numberOfSections
        // Middle sections are wrapped in white cards
        if indexPath.section > 0 && indexPath.section < (totalSections - 1) {
            let cardLayer = CAShapeLayer()
            cardLayer.fillColor = UIColor.white.cgColor
            let cardFrame = cell.bounds.inset(by: UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16))
            cardLayer.path = UIBezierPath(roundedRect: cardFrame, cornerRadius: 12).cgPath
            cell.layer.insertSublayer(cardLayer, at: 0)
        }
    }
    
    // MARK: - Firebase Update
    
    /// saveButtonTapped: Commits changes to the Cloud database.
    /// OOD Principle: Persistance - Moving data from volatile local state to permanent storage.
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let uid = seeker?.uid else { return }
        
        // Prevent double submission
        saveButton?.isEnabled = false
        
        // Update the 'status' field in the user's Firestore document
        Firestore.firestore().collection("users").document(uid).updateData(["status": currentStatus]) { [weak self] error in
            self?.saveButton?.isEnabled = true
            if error == nil {
                self?.showAlert(title: "Success", message: "Updated successfully")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
