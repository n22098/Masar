import UIKit

class ServiceInformationTableViewController: UITableViewController {
    
    // MARK: - Properties
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var providerData: ServiceProviderModel?
    
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - Header View
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        view.backgroundColor = .white
        return view
    }()
    
    private let providerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
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
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let servicePriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceDetailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var requestButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Request Service", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = brandColor
        btn.layer.cornerRadius = 12
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
    
    // MARK: - Setup
    private func setupUI() {
        // Navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
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
        
        // Table view
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.tableHeaderView = headerView
        
        // Disable table view scrolling to prevent layout issues
        tableView.isScrollEnabled = true
        tableView.bounces = true
    }
    
    private func setupHeaderView() {
        headerView.addSubview(providerImageView)
        headerView.addSubview(providerNameLabel)
        headerView.addSubview(providerRoleLabel)
        headerView.addSubview(providerSkillsLabel)
        headerView.addSubview(infoStackView)
        
        // Create info items
        let timeView = createInfoItem(
            icon: "clock.fill",
            text: providerData?.availability ?? "Daily"
        )
        let locationView = createInfoItem(
            icon: "mappin.circle.fill",
            text: providerData?.location ?? "Online"
        )
        let phoneView = createInfoItem(
            icon: "phone.fill",
            text: providerData?.phone ?? "N/A"
        )
        
        infoStackView.addArrangedSubview(timeView)
        infoStackView.addArrangedSubview(locationView)
        infoStackView.addArrangedSubview(phoneView)
        
        NSLayoutConstraint.activate([
            providerImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            providerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            providerImageView.widthAnchor.constraint(equalToConstant: 80),
            providerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            providerNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            providerNameLabel.leadingAnchor.constraint(equalTo: providerImageView.trailingAnchor, constant: 16),
            providerNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            providerRoleLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 4),
            providerRoleLabel.leadingAnchor.constraint(equalTo: providerNameLabel.leadingAnchor),
            providerRoleLabel.trailingAnchor.constraint(equalTo: providerNameLabel.trailingAnchor),
            
            providerSkillsLabel.topAnchor.constraint(equalTo: providerRoleLabel.bottomAnchor, constant: 6),
            providerSkillsLabel.leadingAnchor.constraint(equalTo: providerNameLabel.leadingAnchor),
            providerSkillsLabel.trailingAnchor.constraint(equalTo: providerNameLabel.trailingAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: providerImageView.bottomAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 60),
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
        
        // Add as table footer
        containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 320)
        tableView.tableFooterView = containerView
        
        NSLayoutConstraint.activate([
            serviceCardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            serviceCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            serviceCardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            serviceIconView.topAnchor.constraint(equalTo: serviceCardView.topAnchor, constant: 20),
            serviceIconView.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 20),
            serviceIconView.widthAnchor.constraint(equalToConstant: 50),
            serviceIconView.heightAnchor.constraint(equalToConstant: 50),
            
            serviceNameLabel.topAnchor.constraint(equalTo: serviceCardView.topAnchor, constant: 24),
            serviceNameLabel.leadingAnchor.constraint(equalTo: serviceIconView.trailingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -20),
            
            servicePriceLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            servicePriceLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            servicePriceLabel.trailingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor),
            
            serviceDetailsLabel.topAnchor.constraint(equalTo: servicePriceLabel.bottomAnchor, constant: 16),
            serviceDetailsLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 20),
            serviceDetailsLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -20),
            
            requestButton.topAnchor.constraint(equalTo: serviceDetailsLabel.bottomAnchor, constant: 20),
            requestButton.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 20),
            requestButton.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -20),
            requestButton.bottomAnchor.constraint(equalTo: serviceCardView.bottomAnchor, constant: -20),
            requestButton.heightAnchor.constraint(equalToConstant: 50)
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
        // Provider data
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
        
        // Service data
        serviceNameLabel.text = receivedServiceName ?? "Service Package"
        servicePriceLabel.text = receivedServicePrice ?? "BHD 0.000"
        
        if let details = receivedServiceDetails {
            let lines = details.components(separatedBy: ".")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if lines.count > 1 {
                let bulletPoints = lines.map { "• \($0)" }.joined(separator: "\n")
                serviceDetailsLabel.text = bulletPoints
            } else {
                serviceDetailsLabel.text = details
            }
        } else {
            serviceDetailsLabel.text = "Complete service package with professional delivery"
        }
    }
    
    // MARK: - Actions
    @objc private func requestButtonTapped() {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.requestButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.requestButton.transform = .identity
            }
        }
        
        performSegue(withIdentifier: "showBookingForm", sender: nil)
    }
    
    // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // تأكد من اسم المعرف (Identifier) في الستوري بورد، غالباً هو "showBooking"
            if segue.identifier == "showBooking" {
                if let destVC = segue.destination as? ServiceDetailsBookingTableViewController {
                    
                    // تمرير البيانات الموجودة
                    destVC.receivedServiceName = self.receivedServiceName
                    destVC.receivedServicePrice = self.receivedServicePrice
                    destVC.receivedLocation = "Online" // أو أي موقع افتراضي
                    destVC.receivedServiceDetails = self.receivedServiceDetails
                    
                    // 🔥🔥 هذا هو السطر الناقص الذي يحل المشكلة!
                    // نقوم بتمرير بيانات الموفر إلى صفحة الحجز
                    destVC.providerData = self.providerData
                }
            }
        }
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0  // No table content, using header and footer only
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
