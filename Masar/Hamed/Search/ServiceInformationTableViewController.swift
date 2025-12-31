import UIKit

class ServiceInformationTableViewController: UITableViewController {
    
    // MARK: - Properties
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    
    // Variable to hold the Service Items (Add-ons)
    var receivedServiceItems: [String]?
    
    var providerData: ServiceProviderModel?
    
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - ✅ THE FIX IS HERE
    // This initializer is required to prevent the "Fatal error: init(coder:) has not been implemented" crash.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Header View
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        view.backgroundColor = .white
        return view
    }()
    
    private let providerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerRoleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerSkillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Service Card
    private let serviceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let serviceIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "briefcase.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let servicePriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceDetailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        label.attributedText = NSAttributedString(string: "Details", attributes: [.paragraphStyle: style])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var requestButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Request Service", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = brandColor
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeaderView()
        setupServiceCard()
        populateData()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if providerData?.role.contains("Designer") == true || providerData?.role.contains("Creator") == true {
            title = "Digital Services"
        } else if providerData?.role.contains("Teacher") == true {
            title = "Teaching"
        } else {
            title = "IT Solutions"
        }
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.tableHeaderView = headerView
        
        tableView.isScrollEnabled = true
        tableView.bounces = true
    }
    
    private func setupHeaderView() {
        headerView.addSubview(providerImageView)
        headerView.addSubview(providerNameLabel)
        headerView.addSubview(providerRoleLabel)
        headerView.addSubview(providerSkillsLabel)
        headerView.addSubview(infoStackView)
        
        let timeView = createInfoItem(icon: "clock.fill", text: providerData?.availability ?? "Daily")
        let locationView = createInfoItem(icon: "mappin.circle.fill", text: providerData?.location ?? "Online")
        let phoneView = createInfoItem(icon: "phone.fill", text: providerData?.phone ?? "N/A")
        
        infoStackView.addArrangedSubview(timeView)
        infoStackView.addArrangedSubview(locationView)
        infoStackView.addArrangedSubview(phoneView)
        
        NSLayoutConstraint.activate([
            providerImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            providerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            providerImageView.widthAnchor.constraint(equalToConstant: 70),
            providerImageView.heightAnchor.constraint(equalToConstant: 70),
            
            providerNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            providerNameLabel.leadingAnchor.constraint(equalTo: providerImageView.trailingAnchor, constant: 14),
            providerNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            providerRoleLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 3),
            providerRoleLabel.leadingAnchor.constraint(equalTo: providerNameLabel.leadingAnchor),
            providerRoleLabel.trailingAnchor.constraint(equalTo: providerNameLabel.trailingAnchor),
            
            providerSkillsLabel.topAnchor.constraint(equalTo: providerRoleLabel.bottomAnchor, constant: 5),
            providerSkillsLabel.leadingAnchor.constraint(equalTo: providerNameLabel.leadingAnchor),
            providerSkillsLabel.trailingAnchor.constraint(equalTo: providerNameLabel.trailingAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: providerImageView.bottomAnchor, constant: 18),
            infoStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 64),
            infoStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupServiceCard() {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        containerView.addSubview(serviceCardView)
        serviceCardView.addSubview(serviceIconView)
        serviceCardView.addSubview(serviceNameLabel)
        serviceCardView.addSubview(servicePriceLabel)
        serviceCardView.addSubview(serviceDetailsLabel)
        serviceCardView.addSubview(requestButton)
        
        // Ensure the container is large enough to fit content + padding
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 340)
        tableView.tableFooterView = containerView
        
        NSLayoutConstraint.activate([
            serviceCardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            serviceCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            serviceCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            serviceCardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            serviceIconView.topAnchor.constraint(equalTo: serviceCardView.topAnchor, constant: 24),
            serviceIconView.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            serviceIconView.widthAnchor.constraint(equalToConstant: 36),
            serviceIconView.heightAnchor.constraint(equalToConstant: 36),
            
            serviceNameLabel.centerYAnchor.constraint(equalTo: serviceIconView.centerYAnchor, constant: -4),
            serviceNameLabel.leadingAnchor.constraint(equalTo: serviceIconView.trailingAnchor, constant: 14),
            serviceNameLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            
            servicePriceLabel.topAnchor.constraint(equalTo: serviceIconView.bottomAnchor, constant: 16),
            servicePriceLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            servicePriceLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            
            serviceDetailsLabel.topAnchor.constraint(equalTo: servicePriceLabel.bottomAnchor, constant: 18),
            serviceDetailsLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            serviceDetailsLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            
            requestButton.bottomAnchor.constraint(equalTo: serviceCardView.bottomAnchor, constant: -20),
            requestButton.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            requestButton.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            requestButton.heightAnchor.constraint(equalToConstant: 54),
            
            serviceDetailsLabel.bottomAnchor.constraint(lessThanOrEqualTo: requestButton.topAnchor, constant: -20)
        ])
    }
    
    private func createInfoItem(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.08)
        container.layer.cornerRadius = 10
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = brandColor
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
        if let provider = providerData {
            providerNameLabel.text = provider.name
            providerRoleLabel.text = provider.role
            providerSkillsLabel.text = provider.skills.joined(separator: " • ")
            
            if let image = UIImage(named: provider.imageName) {
                providerImageView.image = image
            } else {
                providerImageView.image = UIImage(systemName: "person.circle.fill")
                providerImageView.tintColor = brandColor
            }
        }
        
        serviceNameLabel.text = receivedServiceName ?? "Service Package"
        servicePriceLabel.text = receivedServicePrice ?? "BHD 0.000"
        
        if let details = receivedServiceDetails, !details.isEmpty {
            let lines = details.components(separatedBy: ".")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if lines.count > 1 {
                let bulletPoints = lines.map { "• \($0)" }.joined(separator: "\n\n")
                serviceDetailsLabel.text = bulletPoints
            } else {
                serviceDetailsLabel.text = details
            }
        } else {
            // Default text logic if empty
            serviceDetailsLabel.text = "Complete service package with professional delivery"
        }
    }
    
    @objc private func requestButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.requestButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.requestButton.transform = .identity
            }
        }
        performSegue(withIdentifier: "showBooking", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBooking" {
            if let destVC = segue.destination as? ServiceDetailsBookingTableViewController {
                
                // Pass Data
                destVC.receivedServiceName = self.receivedServiceName
                destVC.receivedServicePrice = self.receivedServicePrice
                
                // Pass the visible text from the Label
                destVC.receivedServiceDetails = self.serviceDetailsLabel.text
                
                destVC.providerData = self.providerData
                
                // Pass the Service Items (Add-ons) to the Booking Screen
                if let items = receivedServiceItems {
                    destVC.receivedServiceItems = items.joined(separator: ", ")
                } else {
                    destVC.receivedServiceItems = "None"
                }
            }
        }
    }
    
    // TableView Config (Empty because you are using Header/Footer for content)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
