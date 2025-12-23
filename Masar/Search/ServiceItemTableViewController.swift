import UIKit

class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Properties
    var providerData: ServiceProviderModel?
    
    var services: [ServiceModel] {
        if let realServices = providerData?.services, !realServices.isEmpty {
            return realServices
        }
        return [
            ServiceModel(
                name: "Website Starter",
                price: "BHD 85.000",
                description: "Includes responsive design, basic contact form, and fast delivery.",
                deliveryTime: "3-5 days",
                features: ["Responsive Design", "Contact Form", "SEO Ready"]
            ),
            ServiceModel(
                name: "Business Website",
                price: "BHD 150.000",
                description: "Includes custom layout, database support, admin panel, and SEO.",
                deliveryTime: "7-10 days",
                features: ["Custom Design", "Database", "Admin Panel", "SEO"]
            )
        ]
    }
    
    // MARK: - Header View
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 280))
        view.backgroundColor = .white
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 45
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Provider Name
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Provider Specialist/Role
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Provider Skills
    private let skillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Rating Button (top right)
    private let ratingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.setTitleColor(UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1), for: .normal)
        btn.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1)
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Info Stack
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // View Portfolio Button
    private lazy var viewPortfolioButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View Portfolio", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(viewPortfolioTapped), for: .touchUpInside)
        return btn
    }()
    
    // Chat Button
    private lazy var chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chat", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeaderView()
        populateData()
        
        tableView.register(ModernBookingCell.self, forCellReuseIdentifier: "ModernBookingCell")
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = providerData?.role ?? "Services"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.tableHeaderView = headerView
    }
    
    private func setupHeaderView() {
        headerView.addSubview(profileImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(roleLabel)
        headerView.addSubview(skillsLabel)
        headerView.addSubview(ratingButton)
        headerView.addSubview(infoStackView)
        headerView.addSubview(viewPortfolioButton)
        headerView.addSubview(chatButton)
        
        // Create info items
        let availabilityView = createInfoItem(
            icon: "clock.fill",
            text: providerData?.availability ?? "Sat-Thu"
        )
        let locationView = createInfoItem(
            icon: "mappin.circle.fill",
            text: providerData?.location ?? "Online"
        )
        let phoneView = createInfoItem(
            icon: "phone.fill",
            text: providerData?.phone ?? "36666222"
        )
        
        infoStackView.addArrangedSubview(availabilityView)
        infoStackView.addArrangedSubview(locationView)
        infoStackView.addArrangedSubview(phoneView)
        
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.heightAnchor.constraint(equalToConstant: 90),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: ratingButton.leadingAnchor, constant: -8),
            
            // Role Label
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Skills Label
            skillsLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 6),
            skillsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            skillsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            // Rating Button (top right)
            ratingButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            ratingButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Info Stack
            infoStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // View Portfolio Button
            viewPortfolioButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 16),
            viewPortfolioButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            viewPortfolioButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5, constant: -26),
            viewPortfolioButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Chat Button
            chatButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 16),
            chatButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            chatButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5, constant: -26),
            chatButton.heightAnchor.constraint(equalToConstant: 50),
            chatButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createInfoItem(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.08)
        container.layer.cornerRadius = 10
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
    private func populateData() {
        guard let provider = providerData else { return }
        
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        skillsLabel.text = provider.skills.joined(separator: " • ")
        ratingButton.setTitle("⭐️ \(String(format: "%.1f", provider.rating))", for: .normal)
        
        if let image = UIImage(named: provider.imageName) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        }
    }
    
    // MARK: - Actions
    @objc private func menuTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share Provider", style: .default, handler: { _ in self.shareProvider() }))
        alert.addAction(UIAlertAction(title: "Report Issue", style: .default, handler: { _ in self.reportIssue() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    @objc private func viewPortfolioTapped() {
        performSegue(withIdentifier: "showPortfolio", sender: providerData)
    }
    
    @objc private func chatTapped() {
        performSegue(withIdentifier: "showChat", sender: providerData)
    }
    
    private func shareProvider() {
        guard let provider = providerData else { return }
        let text = "Check out \(provider.name) - \(provider.role) on our app!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(activityVC, animated: true)
    }
    
    private func reportIssue() {
        let alert = UIAlertController(title: "Report Issue", message: "Describe the issue.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Issue..." }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = services[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingCell", for: indexPath) as! ModernBookingCell
        cell.configure(title: service.name, price: service.price, description: service.description, icon: "briefcase.fill")
        cell.onBookingTapped = { [weak self] in
            self?.handleBooking(for: service)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    private func handleBooking(for service: ServiceModel) {
        performSegue(withIdentifier: "showDetails", sender: service)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails",
           let destVC = segue.destination as? ServiceInformationTableViewController,
           let service = sender as? ServiceModel {
            destVC.receivedServiceName = service.name
            destVC.receivedServicePrice = service.price
            destVC.receivedServiceDetails = service.description
            destVC.providerData = self.providerData
        } else if segue.identifier == "showPortfolio",
                  let destVC = segue.destination as? ProviderPortfolioTableViewController,
                  let provider = sender as? ServiceProviderModel {
            destVC.providerData = provider
        } else if segue.identifier == "showChat",
                  let destVC = segue.destination as? MessageTableViewController,
                  let provider = sender as? ServiceProviderModel {
            // Pass provider data to chat screen
            destVC.providerData = provider
        }
    }
}

// MARK: - Modern Booking Cell
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
        iv.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
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
        btn.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1).cgColor
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
