import UIKit
import FirebaseFirestore

// MARK: - Service Item Model
struct ServiceItem {
    let id: String
    let name: String
    let description: String
    let price: String
    let createdAt: Date?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        self.name = document.get("name") as? String ?? ""
        self.description = document.get("description") as? String ?? ""
        self.price = document.get("price") as? String ?? ""
        self.createdAt = (document.get("createdAt") as? Timestamp)?.dateValue()
    }
}

// MARK: - Custom Service Cell
class ServiceRequestCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "briefcase.fill")
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    private let requestButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Request", for: .normal)
        btn.setTitleColor(UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0).cgColor
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [iconImageView, titleLabel, priceLabel, descriptionLabel, requestButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 35),
            iconImageView.heightAnchor.constraint(equalToConstant: 35),
            
            requestButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            requestButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            requestButton.widthAnchor.constraint(equalToConstant: 80),
            requestButton.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: requestButton.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: requestButton.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with service: ServiceItem) {
        titleLabel.text = service.name
        priceLabel.text = "BHD \(service.price)"
        descriptionLabel.text = service.description
    }
}

// MARK: - Provider Details View Controller
class ProviderDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let db = Firestore.firestore()
    
    var providerID: String = ""
    var categoryName: String = ""
    
    private var services: [ServiceItem] = []
    private var fetchedProviderData: [String: Any] = [:]
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // UI Elements
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileImageView = UIImageView()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tv.separatorStyle = .none
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // DEBUG CHECK: If providerID is empty, the screen will stay blank.
        if providerID.isEmpty {
            print("DEBUG: Error - providerID is EMPTY. Check how you are passing data to this controller.")
            nameLabel.text = "No Provider ID Found"
        } else {
            fetchProviderDetails()
            startServicesListener()
        }
    }
    
    private func setupUI() {
        title = "My Service" // Changed title to match your screenshot
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServiceTapped))
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ServiceRequestCell.self, forCellReuseIdentifier: "ServiceRequestCell")
        
        // IMPORTANT: In code-based layouts, ensure the header has a height
        let header = createHeaderView()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 320)
        tableView.tableHeaderView = header
    }
    
    private func createHeaderView() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        profileImageView.backgroundColor = brandColor
        profileImageView.image = UIImage(systemName: "person.fill")
        profileImageView.tintColor = .white
        profileImageView.layer.cornerRadius = 45
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = "Loading..."
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        categoryLabel.text = categoryName.isEmpty ? "Category" : categoryName
        categoryLabel.textColor = .gray
        categoryLabel.font = .systemFont(ofSize: 14)
        
        descriptionLabel.text = "Fetching details..."
        descriptionLabel.textColor = brandColor
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.numberOfLines = 2
        
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, categoryLabel, descriptionLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let badgesStack = UIStackView()
        badgesStack.axis = .horizontal
        badgesStack.distribution = .fillEqually
        badgesStack.spacing = 10
        badgesStack.translatesAutoresizingMaskIntoConstraints = false
        
        badgesStack.addArrangedSubview(createStatusBadge(icon: "clock.fill", title: "Available", color: brandColor))
        badgesStack.addArrangedSubview(createStatusBadge(icon: "info.circle.fill", title: "Online", color: brandColor))
        badgesStack.addArrangedSubview(createStatusBadge(icon: "phone.fill", title: "Phone", color: brandColor))
        
        let actionsStack = UIStackView()
        actionsStack.axis = .horizontal
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 15
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let portfolioBtn = UIButton(type: .system)
        portfolioBtn.setTitle("View Portfolio", for: .normal)
        portfolioBtn.backgroundColor = brandColor
        portfolioBtn.setTitleColor(.white, for: .normal)
        portfolioBtn.layer.cornerRadius = 12
        portfolioBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let contactBtn = UIButton(type: .system)
        contactBtn.setTitle("Contact", for: .normal)
        contactBtn.backgroundColor = .white
        contactBtn.setTitleColor(brandColor, for: .normal)
        contactBtn.layer.cornerRadius = 12
        contactBtn.layer.borderWidth = 1
        contactBtn.layer.borderColor = brandColor.cgColor
        contactBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        contactBtn.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)
        
        actionsStack.addArrangedSubview(portfolioBtn)
        actionsStack.addArrangedSubview(contactBtn)
        
        container.addSubview(profileImageView)
        container.addSubview(infoStack)
        container.addSubview(badgesStack)
        container.addSubview(actionsStack)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.heightAnchor.constraint(equalToConstant: 90),
            
            infoStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            infoStack.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            infoStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            badgesStack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            badgesStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            badgesStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            badgesStack.heightAnchor.constraint(equalToConstant: 70),
            
            actionsStack.topAnchor.constraint(equalTo: badgesStack.bottomAnchor, constant: 20),
            actionsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            actionsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            actionsStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return container
    }
    
    private func createStatusBadge(icon: String, title: String, color: UIColor) -> UIView {
        let box = UIView()
        box.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 250/255, alpha: 1.0)
        box.layer.cornerRadius = 10
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = color
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        let lbl = UILabel()
        lbl.text = title
        lbl.textColor = color
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        box.addSubview(iv)
        box.addSubview(lbl)
        
        NSLayoutConstraint.activate([
            iv.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            iv.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            iv.heightAnchor.constraint(equalToConstant: 20),
            iv.widthAnchor.constraint(equalToConstant: 20),
            
            lbl.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            lbl.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 8)
        ])
        return box
    }

    private func fetchProviderDetails() {
        db.collection("providers").document(providerID).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                print("DEBUG: Provider document does not exist for ID: \(self?.providerID ?? "")")
                return
            }
            self.fetchedProviderData = document.data() ?? [:]
            DispatchQueue.main.async { self.updateHeaderWithRealData() }
        }
    }
    
    private func updateHeaderWithRealData() {
        let name = fetchedProviderData["name"] as? String ?? "Unknown Provider"
        let cat = fetchedProviderData["categoryName"] as? String ?? self.categoryName
        let email = fetchedProviderData["email"] as? String ?? ""
        let phone = fetchedProviderData["phone"] as? String ?? ""
        
        nameLabel.text = name
        categoryLabel.text = cat
        descriptionLabel.text = "Contact: \(email)\n\(phone)"
    }

    private func startServicesListener() {
        // NOTE: If this produces NO data, check your Firestore Console to ensure
        // there are documents in 'services' collection where providerID matches exactly.
        db.collection("services")
            .whereField("providerID", isEqualTo: providerID)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("DEBUG: Firestore Error: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                print("DEBUG: Successfully fetched \(documents.count) services")
                self?.services = documents.map { ServiceItem(document: $0) }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }

    @objc private func addServiceTapped() {
        let alert = UIAlertController(title: "Add Service", message: "New service listing", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Service Name" }
        alert.addTextField { $0.placeholder = "Description" }
        alert.addTextField { $0.placeholder = "Price"; $0.keyboardType = .decimalPad }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?[0].text, !name.isEmpty,
                  let desc = alert.textFields?[1].text,
                  let price = alert.textFields?[2].text else { return }
            
            self.saveServiceToFirebase(name: name, desc: desc, price: price)
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saveServiceToFirebase(name: String, desc: String, price: String) {
        db.collection("services").addDocument(data: [
            "name": name,
            "description": desc,
            "price": price,
            "providerID": providerID,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
    
    @objc private func contactTapped() {
        let phone = fetchedProviderData["phone"] as? String ?? ""
        let email = fetchedProviderData["email"] as? String ?? ""
        let alert = UIAlertController(title: "Contact", message: nil, preferredStyle: .actionSheet)
        if !phone.isEmpty { alert.addAction(UIAlertAction(title: "Call", style: .default) { _ in }) }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceRequestCell", for: indexPath) as! ServiceRequestCell
        cell.configure(with: services[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
