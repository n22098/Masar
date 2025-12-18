import UIKit

class ServiceInformationTableViewController: UITableViewController {
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var providerData: ServiceProviderModel?
    
    // MARK: - Outlets - Provider Section
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var providerRoleLabel: UILabel!
    @IBOutlet weak var providerSkillsLabel: UILabel!
    @IBOutlet weak var providerDescriptionLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    
    // Info containers
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var phoneContainer: UIView!
    
    // MARK: - Outlets - Service Section
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var packageDetailsLabel: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    // Package info card
    @IBOutlet weak var packageCardView: UIView!
    
    // MARK: - Colors
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightPurple = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.08)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupDesign()
        configureData()
    }
    
    // MARK: - Setup Navigation Bar
    func setupNavigationBar() {
        // Purple navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Set title based on category
        if providerData?.role.contains("Designer") == true || providerData?.role.contains("Creator") == true {
            title = "Digital Services"
        } else if providerData?.role.contains("Teacher") == true {
            title = "Teaching"
        } else {
            title = "IT Solutions"
        }
    }
    
    // MARK: - Setup Design
    func setupDesign() {
        // Table view styling
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // Provider image styling
        if let img = providerImageView {
            img.layer.cornerRadius = 40
            img.clipsToBounds = true
            img.backgroundColor = lightPurple
            img.contentMode = .scaleAspectFill
        }
        
        // Info containers styling
        styleInfoContainer(timeContainer)
        styleInfoContainer(locationContainer)
        styleInfoContainer(phoneContainer)
        
        // Icons styling
        styleIcon(timeIcon, systemName: "clock.fill")
        styleIcon(locationIcon, systemName: "mappin.circle.fill")
        styleIcon(phoneIcon, systemName: "phone.fill")
        
        // Info labels styling
        styleInfoLabel(timeLabel)
        styleInfoLabel(locationLabel)
        styleInfoLabel(phoneLabel)
        
        // Provider labels styling
        providerNameLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        providerNameLabel?.textColor = .black
        
        providerRoleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        providerRoleLabel?.textColor = .darkGray
        
        providerSkillsLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        providerSkillsLabel?.textColor = brandColor
        providerSkillsLabel?.numberOfLines = 0
        
        providerDescriptionLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        providerDescriptionLabel?.textColor = .gray
        providerDescriptionLabel?.numberOfLines = 0
        
        // Package card styling
        if let card = packageCardView {
            card.backgroundColor = .white
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.05
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            card.layer.shadowRadius = 8
        }
        
        // Package labels styling
        packageNameLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        packageNameLabel?.textColor = .black
        
        packagePriceLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        packagePriceLabel?.textColor = .black
        
        packageDetailsLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        packageDetailsLabel?.textColor = .gray
        packageDetailsLabel?.numberOfLines = 0
        
        // Request button styling
        if let btn = requestButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = .white
            btn.setTitleColor(brandColor, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = brandColor.cgColor
            btn.setTitle("Request", for: .normal)
        }
    }
    
    func styleInfoContainer(_ container: UIView?) {
        guard let view = container else { return }
        view.backgroundColor = lightPurple
        view.layer.cornerRadius = 8
    }
    
    func styleIcon(_ icon: UIImageView?, systemName: String) {
        guard let iv = icon else { return }
        iv.image = UIImage(systemName: systemName)
        iv.tintColor = brandColor
        iv.contentMode = .scaleAspectFit
    }
    
    func styleInfoLabel(_ label: UILabel?) {
        guard let lbl = label else { return }
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = brandColor
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.8
    }
    
    // MARK: - Populate Data
    func configureData() {
        // Provider data
        if let provider = providerData {
            providerNameLabel?.text = provider.name
            providerRoleLabel?.text = provider.role
            
            // Skills with bullet points
            let skillsText = provider.skills.joined(separator: " • ")
            providerSkillsLabel?.text = skillsText
            
            providerDescriptionLabel?.text = "Creative visuals & clean designs"
            
            timeLabel?.text = provider.availability
            locationLabel?.text = provider.location
            phoneLabel?.text = provider.phone
            
            // Image
            if let image = UIImage(named: provider.imageName) {
                providerImageView?.image = image
            } else {
                providerImageView?.image = UIImage(systemName: "person.circle.fill")
                providerImageView?.tintColor = brandColor
            }
        } else {
            // Default data
            providerNameLabel?.text = "Sayed Husain"
            providerRoleLabel?.text = "Software Engineer"
            providerSkillsLabel?.text = "HTML • CSS • JS • PHP • MySQL"
        }
        
        // Service data
        packageNameLabel?.text = receivedServiceName
        packagePriceLabel?.text = receivedServicePrice
        
        // Format package details
        if let details = receivedServiceDetails {
            // Split by period and create bullet points
            let lines = details.components(separatedBy: ".")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if lines.count > 1 {
                let bulletPoints = lines.map { "• \($0)" }.joined(separator: "\n")
                packageDetailsLabel?.text = bulletPoints
            } else {
                packageDetailsLabel?.text = details
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        print("🔵 Booking Button Tapped")
        
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        performSegue(withIdentifier: "showBookingForm", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookingForm" {
            if let destVC = segue.destination as? ServiceDetailsBookingTableViewController {
                destVC.receivedServiceName = self.receivedServiceName
                destVC.receivedServicePrice = self.receivedServicePrice
                destVC.receivedLocation = self.providerData?.location
                // Remove this line if not needed:
                // destVC.providerData = self.providerData
                
                print("✅ Data passed: \(receivedServiceName ?? "Nil")")
            }
        }
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}

// MARK: - Extension for Additional Helpers
extension ServiceInformationTableViewController {
    
    /// Creates a formatted attributed string for package details
    func createFormattedPackageDetails(_ details: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 8
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.gray,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: details, attributes: attributes)
    }
    
    /// Shows a confirmation alert before proceeding to booking
    func showBookingConfirmation() {
        let alert = UIAlertController(
            title: "Confirm Booking",
            message: "Would you like to proceed with booking '\(receivedServiceName ?? "this service")'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "showBookingForm", sender: nil)
        })
        
        present(alert, animated: true)
    }
}
