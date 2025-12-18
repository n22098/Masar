import UIKit

class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Variables
    var providerData: ServiceProviderModel?
    
    let services = [
        ("Website Starter", "BHD 85.000", "Includes responsive design, basic contact form, and fast delivery."),
        ("Business Website", "BHD 150.000", "Includes custom layout, database support, admin panel, and SEO.")
    ]
    
    // MARK: - Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerRoleLabel: UILabel!
    @IBOutlet weak var headerRatingLabel: UILabel!
    @IBOutlet weak var headerSkillsLabel: UILabel!
    @IBOutlet weak var headerDescriptionLabel: UILabel!
    
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var availabilityIcon: UIImageView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var phoneIcon: UIImageView!
    
    @IBOutlet weak var seeProfileButton: UIButton!
    @IBOutlet weak var packagesButton: UIButton!
    
    // Info container views (if you have them in storyboard)
    @IBOutlet weak var availabilityContainer: UIView!
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var phoneContainer: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateHeaderData()
        
        // Register custom cell if needed
        tableView.register(ModernBookingCell.self, forCellReuseIdentifier: "ModernBookingCell")
    }
    
    func setupUI() {
        title = "IT Solutions"
        
        // Navigation bar styling
        setupNavigationBar()
        
        // Table view styling
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        // Avatar styling
        if let imgView = headerImageView {
            imgView.layer.cornerRadius = 40
            imgView.clipsToBounds = true
            imgView.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.1)
            imgView.contentMode = .scaleAspectFill
        }
        
        // Button styling
        styleButton(seeProfileButton)
        styleButton(packagesButton)
        
        // Info containers styling
        styleInfoContainer(availabilityContainer)
        styleInfoContainer(locationContainer)
        styleInfoContainer(phoneContainer)
        
        // Icon styling
        styleIcon(availabilityIcon, systemName: "clock.fill")
        styleIcon(locationIcon, systemName: "mappin.circle.fill")
        styleIcon(phoneIcon, systemName: "phone.fill")
    }
    
    func setupNavigationBar() {
        // Purple navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Menu button
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
    }
    
    func styleButton(_ button: UIButton?) {
        guard let btn = button else { return }
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.3).cgColor
    }
    
    func styleInfoContainer(_ container: UIView?) {
        guard let view = container else { return }
        view.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.08)
        view.layer.cornerRadius = 8
    }
    
    func styleIcon(_ icon: UIImageView?, systemName: String) {
        guard let iv = icon else { return }
        iv.image = UIImage(systemName: systemName)
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        iv.contentMode = .scaleAspectFit
    }
    
    func populateHeaderData() {
        guard let provider = providerData else { return }
        
        // Basic info
        headerNameLabel?.text = provider.name
        headerNameLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerNameLabel?.textColor = .black
        
        headerRoleLabel?.text = provider.role
        headerRoleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerRoleLabel?.textColor = .darkGray
        
        headerRatingLabel?.text = "⭐️ \(provider.rating)"
        headerRatingLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        headerRatingLabel?.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        
        // Skills
        headerSkillsLabel?.text = provider.skills.joined(separator: ", ")
        headerSkillsLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        headerSkillsLabel?.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        headerSkillsLabel?.numberOfLines = 0
        
        // Description
        headerDescriptionLabel?.text = "Frontend & backend solutions"
        headerDescriptionLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        headerDescriptionLabel?.textColor = .gray
        headerDescriptionLabel?.numberOfLines = 0
        
        // Availability info
        availabilityLabel?.text = provider.availability
        availabilityLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        availabilityLabel?.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        availabilityLabel?.textAlignment = .center
        
        locationLabel?.text = provider.location
        locationLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        locationLabel?.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        locationLabel?.textAlignment = .center
        
        phoneLabel?.text = provider.phone
        phoneLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        phoneLabel?.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        phoneLabel?.textAlignment = .center
        
        // Avatar
        if let image = UIImage(named: provider.imageName) {
            headerImageView?.image = image
        } else {
            headerImageView?.image = UIImage(systemName: "person.circle.fill")
            headerImageView?.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        }
    }
    
    // MARK: - Actions
    @objc func menuTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share Provider", style: .default, handler: { _ in
            // Share functionality
            self.shareProvider()
        }))
        alert.addAction(UIAlertAction(title: "Report Issue", style: .default, handler: { _ in
            // Report functionality
            self.reportIssue()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func seeProfileTapped(_ sender: UIButton) {
        // Navigate to full profile
        print("See Profile tapped for \(providerData?.name ?? "")")
        // Implement navigation if you have a profile view controller
    }
    
    @IBAction func packagesTapped(_ sender: UIButton) {
        // Show all packages
        print("Packages tapped")
        // Implement navigation if you have a packages view controller
    }
    
    func shareProvider() {
        guard let provider = providerData else { return }
        let text = "Check out \(provider.name) - \(provider.role) on our app!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
    
    func reportIssue() {
        let alert = UIAlertController(
            title: "Report Issue",
            message: "Please describe the issue you're experiencing.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Describe the issue..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                print("Issue reported: \(text)")
                // Implement actual reporting logic
            }
        })
        
        present(alert, animated: true)
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try to use custom cell first, fall back to storyboard cell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingCell") as? ModernBookingCell {
            let service = services[indexPath.row]
            let icon = indexPath.row == 0 ? "doc.text.fill" : "building.2.fill"
            cell.configure(title: service.0, price: service.1, description: service.2, icon: icon)
            
            cell.onBookingTapped = { [weak self] in
                self?.handleBooking(for: service)
            }
            
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as? BookingCell {
            let service = services[indexPath.row]
            cell.configure(name: service.0, price: service.1)
            
            cell.onBookingTapped = { [weak self] in
                self?.performSegue(withIdentifier: "showDetails", sender: service)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func handleBooking(for service: (String, String, String)) {
        performSegue(withIdentifier: "showDetails", sender: service)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let destVC = segue.destination as? ServiceInformationTableViewController,
               let serviceData = sender as? (String, String, String) {
                
                destVC.receivedServiceName = serviceData.0
                destVC.receivedServicePrice = serviceData.1
                destVC.receivedServiceDetails = serviceData.2
                destVC.providerData = self.providerData
            }
        }
    }
}

// MARK: - Modern Booking Cell (Programmatic)
class ModernBookingCell: UITableViewCell {
    
    var onBookingTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Request", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(bookingButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bookingButton.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: bookingButton.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            bookingButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bookingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            bookingButton.widthAnchor.constraint(equalToConstant: 90),
            bookingButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        bookingButton.addTarget(self, action: #selector(bookingTapped), for: .touchUpInside)
    }
    
    @objc private func bookingTapped() {
        onBookingTapped?()
    }
    
    func configure(title: String, price: String, description: String, icon: String) {
        titleLabel.text = title
        priceLabel.text = price
        descriptionLabel.text = description
        iconView.image = UIImage(systemName: icon)
    }
}
