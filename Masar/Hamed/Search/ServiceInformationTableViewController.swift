// ===================================================================================
// SERVICE INFORMATION VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Displays detailed information about a specific service and the provider.
//
// KEY FEATURES:
// 1. Programmatic UI: The entire layout (Header & Footer) is built using code, not Storyboard cells.
// 2. Provider Profile: Fetches and displays the provider's real image and skills.
// 3. Service Details: Shows the price, description, and breakdown of the selected service.
// 4. Data Passing: Acts as a middle-man, passing data from the Search screen to the Booking screen.
// ===================================================================================

import UIKit
import FirebaseFirestore

class ServiceInformationTableViewController: UITableViewController {
    
    // MARK: - Properties
    // Data variables receiving information from the previous screen (Search/Home)
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var service: ServiceModel?
    var receivedServiceItems: [String]?
    var providerData: ServiceProviderModel?
    
    private let db = Firestore.firestore()
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Initializer
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UI Components (Programmatic)
    // We use lazy initialization to create views only when they are needed.
    
    // The top section containing Provider Information
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220))
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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerSkillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Horizontal stack to show Availability, Location, and Phone
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // The bottom card containing Service Details
    private let serviceCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        // Card Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        fetchProviderRealImage()
    }
    
    // Dynamic Height Calculation
    // Calculates the required height for the header/footer based on text content size
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let header = tableView.tableHeaderView {
            let width = tableView.bounds.width
            let size = header.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
            if header.frame.size.height != size.height {
                header.frame.size.height = size.height
                tableView.tableHeaderView = header
            }
        }
        
        if let footer = tableView.tableFooterView {
            let width = tableView.bounds.width
            let size = footer.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
            if footer.frame.size.height != size.height {
                footer.frame.size.height = size.height
                tableView.tableFooterView = footer
            }
        }
    }
    
    // MARK: - Data Logic
    
    // Asynchronous network call to fetch the provider's profile image from Firebase Storage URL
    private func fetchProviderRealImage() {
        guard let providerId = providerData?.id else { return }
        db.collection("users").document(providerId).getDocument { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data(),
                  let urlString = data["profileImageURL"] as? String,
                  let url = URL(string: urlString) else { return }
            
            // Download image data in background
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.providerImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    // Populates the UI labels with the data passed from the previous screen
    private func populateData() {
        if let provider = providerData {
            providerNameLabel.text = provider.name
            providerRoleLabel.text = provider.role
            providerSkillsLabel.text = provider.skills.joined(separator: " • ")
            providerImageView.image = UIImage(systemName: "person.circle.fill") // Placeholder
        }
        
        serviceNameLabel.text = receivedServiceName ?? "Service Package"
        servicePriceLabel.text = receivedServicePrice ?? "BHD 0.000"
        serviceDetailsLabel.text = receivedServiceDetails ?? "No details provided"
    }
    
    // MARK: - Setup UI Methods
    private func setupUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = receivedServiceName ?? providerData?.role ?? "Service Details"
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    // Layout logic for the Provider Header
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
            providerRoleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            providerSkillsLabel.topAnchor.constraint(equalTo: providerRoleLabel.bottomAnchor, constant: 5),
            providerSkillsLabel.leadingAnchor.constraint(equalTo: providerNameLabel.leadingAnchor),
            providerSkillsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: providerImageView.bottomAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 64),
            infoStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // Layout logic for the Service Footer Card
    private func setupServiceCard() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 400))
        container.addSubview(serviceCardView)
        
        [serviceNameLabel, servicePriceLabel, serviceDetailsLabel, requestButton].forEach { serviceCardView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            serviceCardView.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            serviceCardView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            serviceCardView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            serviceCardView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            
            serviceNameLabel.topAnchor.constraint(equalTo: serviceCardView.topAnchor, constant: 24),
            serviceNameLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            serviceNameLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            
            servicePriceLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 16),
            servicePriceLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            
            serviceDetailsLabel.topAnchor.constraint(equalTo: servicePriceLabel.bottomAnchor, constant: 18),
            serviceDetailsLabel.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            serviceDetailsLabel.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            
            requestButton.topAnchor.constraint(equalTo: serviceDetailsLabel.bottomAnchor, constant: 30),
            requestButton.bottomAnchor.constraint(equalTo: serviceCardView.bottomAnchor, constant: -20),
            requestButton.leadingAnchor.constraint(equalTo: serviceCardView.leadingAnchor, constant: 24),
            requestButton.trailingAnchor.constraint(equalTo: serviceCardView.trailingAnchor, constant: -24),
            requestButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        tableView.tableFooterView = container
    }
    
    // Helper to create small info boxes (Time, Location, Phone)
    private func createInfoItem(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = brandColor.withAlphaComponent(0.08)
        container.layer.cornerRadius = 10
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = brandColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 11)
        l.textColor = brandColor
        l.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iv)
        container.addSubview(l)
        
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            l.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 4),
            l.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        return container
    }

    @objc private func requestButtonTapped() {
        performSegue(withIdentifier: "showBooking", sender: nil)
    }
    
    // MARK: - Navigation
    // Prepares the Booking View Controller by passing all necessary data forward
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBooking", let destVC = segue.destination as? ServiceDetailsBookingTableViewController {
            destVC.serviceId = self.service?.id
            destVC.providerData = self.providerData
            
            // Passing the individual strings to the next controller
            destVC.receivedServiceName = self.receivedServiceName
            destVC.receivedServicePrice = self.receivedServicePrice
            destVC.receivedServiceDetails = self.receivedServiceDetails
            
            // Converting [String] array to a single formatted String for the next screen
            if let items = self.receivedServiceItems {
                destVC.receivedServiceItems = items.joined(separator: "\n")
            }
        }
    }
    
    // TableView is used as a ScrollView wrapper here, so we return 0 rows
    override func numberOfSections(in tableView: UITableView) -> Int { return 0 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
}
