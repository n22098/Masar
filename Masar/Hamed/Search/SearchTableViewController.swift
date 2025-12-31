import UIKit
import FirebaseFirestore
import FirebaseAuth

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All"])
        sc.selectedSegmentIndex = 0
        
        // Modern styling
        sc.backgroundColor = UIColor(white: 0.95, alpha: 1)
        sc.selectedSegmentTintColor = .white
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        sc.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1),
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        sc.layer.cornerRadius = 12
        sc.clipsToBounds = true
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    var allProviders: [ServiceProviderModel] = []
    
    private var filteredProviders: [ServiceProviderModel] = []
    private var isAscending = true
    
    private var categoryNames: [String] = ["All"]
    
    let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupTableView()
        
        fetchCategoriesFromFirebase()
        fetchProvidersFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Firebase Fetching 📡
    
    private func fetchCategoriesFromFirebase() {
        print("⏳ Fetching categories from Firebase...")
        
        // 🔥 FIX: Added .order(by: "createdAt") to hide old/ghost categories
        Firestore.firestore().collection("categories")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching categories: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var fetchedCategories: [String] = ["All"]
            for document in documents {
                if let categoryName = document.data()["name"] as? String {
                    fetchedCategories.append(categoryName)
                }
            }
            
            DispatchQueue.main.async {
                self.categoryNames = fetchedCategories
                self.updateCategorySegment()
            }
        }
    }
    
    private func updateCategorySegment() {
        categorySegment.removeAllSegments()
        for (index, categoryName) in categoryNames.enumerated() {
            categorySegment.insertSegment(withTitle: categoryName, at: index, animated: false)
        }
        categorySegment.selectedSegmentIndex = 0
        
        categorySegment.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        categorySegment.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1),
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        filterProvidersByCategory()
    }
    
    // 🔥 FIX: Merging Services with Provider Profile to show Real Name & Image
    // ✅ EXCLUDE current user's services from search results
    private func fetchProvidersFromFirebase() {
        print("⏳ Fetching data (Services + Profiles)...")
        
        // 🔥 Get current user ID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("⚠️ No logged in user")
            return
        }
        
        let group = DispatchGroup()
        
        var fetchedServices: [ServiceModel] = []
        var providersDataMap: [String: [String: Any]] = [:] // UID -> Profile Data
        
        // 1. Fetch Services
        group.enter()
        ServiceManager.shared.fetchAllServices { services in
            // ✅ Filter out current user's services
            fetchedServices = services.filter { service in
                guard let providerId = service.providerId else { return false }
                return providerId != currentUserId
            }
            print("✅ Filtered services - Total: \(services.count), Shown: \(fetchedServices.count)")
            group.leave()
        }
        
        // 2. Fetch Approved Provider Profiles
        group.enter()
        db.collection("provider_requests").whereField("status", isEqualTo: "approved").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for doc in documents {
                    let data = doc.data()
                    // Assuming 'uid' matches the providerId in ServiceModel
                    if let uid = data["uid"] as? String {
                        providersDataMap[uid] = data
                    }
                }
            }
            group.leave()
        }
        
        // 3. Merge Data
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            var groupedServices: [String: [ServiceModel]] = [:]
            
            for service in fetchedServices {
                // Ensure service has a providerId
                if let pId = service.providerId, !pId.isEmpty {
                    if groupedServices[pId] == nil {
                        groupedServices[pId] = []
                    }
                    groupedServices[pId]?.append(service)
                }
            }
            
            var newProviders: [ServiceProviderModel] = []
            
            for (providerId, services) in groupedServices {
                // Get Profile Data
                let profile = providersDataMap[providerId]
                
                // Get Real Name (Fallback to "Unknown" only if profile missing)
                let realName = profile?["name"] as? String ?? "Unknown Provider"
                
                // Get Real Category
                let realCategory = profile?["category"] as? String ?? services.first?.category ?? "Service Provider"
                
                // Get Other Info
                let realPhone = profile?["phone"] as? String ?? "N/A"
                let realBio = profile?["bio"] as? String ?? "Provider from Firebase"
                let realExp = profile?["skillLevel"] as? String ?? "N/A"
                let portfolioUrl = profile?["portfolioURL"] as? String // Usage depends on your image loader
                
                let provider = ServiceProviderModel(
                    id: providerId,
                    name: realName,
                    role: realCategory,
                    imageName: "person.circle.fill", // Update this if you implement URL image loading
                    rating: 5.0,
                    skills: services.map { $0.name },
                    availability: "Available",
                    location: "Online",
                    phone: realPhone,
                    services: services,
                    aboutMe: realBio,
                    portfolio: [],
                    certifications: [],
                    reviews: [],
                    experience: realExp,
                    completedProjects: 0
                )
                
                newProviders.append(provider)
            }
            
            self.allProviders = newProviders
            self.filterProvidersByCategory()
            print("✅ Loaded \(newProviders.count) providers (excluding current user)")
        }
    }
    
    // MARK: - Setup UI
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Search"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        sortButton.tintColor = .white
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search provider..."
        searchController.searchBar.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tableView.register(ProviderTableCell.self, forCellReuseIdentifier: "ProviderCell")
        tableView.tableHeaderView = createHeaderView()
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        categorySegment.frame = CGRect(x: 16, y: 8, width: view.frame.width - 32, height: 40)
        headerView.addSubview(categorySegment)
        return headerView
    }
    
    // MARK: - Actions
    @objc private func sortTapped() {
        let alert = UIAlertController(title: nil, message: "Sort by Name:", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "A-Z", style: .default) { [weak self] _ in
            self?.isAscending = true
            self?.applySorting()
        })
        alert.addAction(UIAlertAction(title: "Z-A", style: .default) { [weak self] _ in
            self?.isAscending = false
            self?.applySorting()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    private func applySorting() {
        filteredProviders.sort { provider1, provider2 in
            if isAscending {
                return provider1.name < provider2.name
            } else {
                return provider1.name > provider2.name
            }
        }
        tableView.reloadData()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        filterProvidersByCategory()
    }
    
    private func filterProvidersByCategory() {
        let selectedIndex = categorySegment.selectedSegmentIndex
        var categoryProviders: [ServiceProviderModel] = []
        
        if selectedIndex == 0 {
            categoryProviders = allProviders
        } else if selectedIndex < categoryNames.count {
            let selectedCategory = categoryNames[selectedIndex]
            
            categoryProviders = allProviders.filter { provider in
                provider.role.lowercased().contains(selectedCategory.lowercased())
            }
        } else {
            categoryProviders = allProviders
        }
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredProviders = categoryProviders.filter { provider in
                provider.name.lowercased().contains(searchText.lowercased()) ||
                provider.role.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredProviders = categoryProviders
        }
        
        applySorting()
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProviders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath) as! ProviderTableCell
        let provider = filteredProviders[indexPath.row]
        cell.parentViewController = self
        cell.configure(with: provider)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedProvider = filteredProviders[indexPath.row]
        performSegue(withIdentifier: "showServiceItem", sender: selectedProvider)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showServiceItem" {
            if let destVC = segue.destination as? ServiceItemTableViewController,
               let provider = sender as? ServiceProviderModel {
                destVC.providerData = provider
            }
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterProvidersByCategory()
    }
}

// MARK: - Provider Cell
class ProviderTableCell: UITableViewCell {
    
    weak var parentViewController: SearchTableViewController?
    
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
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.1)
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("view services", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1), for: .normal)
        btn.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1).cgColor
        btn.layer.borderWidth = 1.5
        btn.layer.cornerRadius = 18
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(roleLabel)
        containerView.addSubview(viewButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: viewButton.leadingAnchor, constant: -8),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            viewButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            viewButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            viewButton.widthAnchor.constraint(equalToConstant: 110),
            viewButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        
        if let image = UIImage(named: provider.imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
