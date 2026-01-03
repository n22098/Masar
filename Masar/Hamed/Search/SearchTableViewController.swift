import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Sort Options
enum SortOption {
    case nameAZ
    case nameZA
    case priceLowToHigh
    case priceHighToLow
}

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentSort: SortOption = .nameAZ
    
    private lazy var categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All"])
        sc.selectedSegmentIndex = 0
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
    
    // MARK: - Firebase Fetching
    private func fetchCategoriesFromFirebase() {
        db.collection("categories")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
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
        filterProvidersByCategory()
    }
    
    private func fetchProvidersFromFirebase() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let group = DispatchGroup()
        var fetchedServices: [ServiceModel] = []
        var providersDataMap: [String: [String: Any]] = [:]
        
        group.enter()
        ServiceManager.shared.fetchAllServices { services in
            fetchedServices = services.filter { $0.providerId != currentUserId }
            group.leave()
        }
        
        // Fetch from provider_requests
        group.enter()
        db.collection("provider_requests").whereField("status", isEqualTo: "approved").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                if let uid = doc.data()["uid"] as? String {
                    providersDataMap[uid] = doc.data()
                }
            }
            group.leave()
        }
        
        // FIXED: Also fetch from users collection for providers
        group.enter()
        db.collection("users").whereField("role", isEqualTo: "provider").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                let uid = doc.documentID
                // Merge with provider_requests data if exists, otherwise use users data
                if providersDataMap[uid] == nil {
                    providersDataMap[uid] = doc.data()
                } else {
                    // Merge data - prefer provider_requests but fill in missing fields from users
                    var mergedData = providersDataMap[uid] ?? [:]
                    doc.data().forEach { key, value in
                        if mergedData[key] == nil {
                            mergedData[key] = value
                        }
                    }
                    providersDataMap[uid] = mergedData
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            var groupedServices: [String: [ServiceModel]] = [:]
            for service in fetchedServices {
                if let pId = service.providerId {
                    groupedServices[pId, default: []].append(service)
                }
            }
            
            self.allProviders = groupedServices.compactMap { (providerId, services) in
                let profile = providersDataMap[providerId]
                return ServiceProviderModel(
                    id: providerId,
                    name: profile?["name"] as? String ?? profile?["username"] as? String ?? "Provider",
                    role: profile?["category"] as? String ?? profile?["specialty"] as? String ?? services.first?.category ?? "Service Provider",
                    imageName: "person.circle.fill",
                    rating: 5.0,
                    skills: services.map { $0.name },
                    availability: "Available",
                    location: "Online",
                    phone: profile?["phone"] as? String ?? "N/A",
                    services: services,
                    aboutMe: profile?["bio"] as? String ?? "",
                    portfolio: [],
                    certifications: [],
                    reviews: [],
                    experience: profile?["skillLevel"] as? String ?? "N/A",
                    completedProjects: 0
                )
            }
            self.filterProvidersByCategory()
        }
    }
    
    // MARK: - Setup UI
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(sortTapped))
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search provider..."
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.backgroundColor = .clear
        
        // FIXED: Remove from navigation, will add to table header instead
        // navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        tableView.register(ProviderTableCell.self, forCellReuseIdentifier: "ProviderCell")
        
        // FIXED: Create header with search bar
        let headerView = createHeaderView()
        tableView.tableHeaderView = headerView
    }
    
    private func createHeaderView() -> UIView {
        let totalHeight: CGFloat = 120
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: totalHeight))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        
        // Add search bar
        let searchBarContainer = UIView(frame: CGRect(x: 16, y: 8, width: view.frame.width - 32, height: 52))
        searchBarContainer.backgroundColor = .white
        searchBarContainer.layer.cornerRadius = 12
        searchBarContainer.layer.shadowColor = UIColor.black.cgColor
        searchBarContainer.layer.shadowOpacity = 0.08
        searchBarContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBarContainer.layer.shadowRadius = 8
        
        searchController.searchBar.frame = searchBarContainer.bounds
        searchBarContainer.addSubview(searchController.searchBar)
        headerView.addSubview(searchBarContainer)
        
        // Add category segment
        categorySegment.frame = CGRect(x: 16, y: 68, width: view.frame.width - 32, height: 40)
        headerView.addSubview(categorySegment)
        
        return headerView
    }
    
    // MARK: - Actions & Sorting
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Name (A-Z)", style: .default) { _ in self.applySorting(to: .nameAZ) })
        alert.addAction(UIAlertAction(title: "Name (Z-A)", style: .default) { _ in self.applySorting(to: .nameZA) })
        alert.addAction(UIAlertAction(title: "Price (Lowest First)", style: .default) { _ in self.applySorting(to: .priceLowToHigh) })
        alert.addAction(UIAlertAction(title: "Price (Highest First)", style: .default) { _ in self.applySorting(to: .priceHighToLow) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func applySorting(to option: SortOption? = nil) {
        if let option = option { self.currentSort = option }
        
        // Fix: Explicit type annotations and optional handling for sorting
        filteredProviders.sort { (p1: ServiceProviderModel, p2: ServiceProviderModel) -> Bool in
            let price1 = p1.services?.compactMap({ $0.price }).min() ?? 0.0
            let price2 = p2.services?.compactMap({ $0.price }).min() ?? 0.0
            
            switch currentSort {
            case .nameAZ: return p1.name < p2.name
            case .nameZA: return p1.name > p2.name
            case .priceLowToHigh: return price1 < price2
            case .priceHighToLow: return price1 > price2
            }
        }
        tableView.reloadData()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        filterProvidersByCategory()
    }
    
    private func filterProvidersByCategory() {
        let selectedIndex = categorySegment.selectedSegmentIndex
        let selectedCategory = selectedIndex == 0 ? "All" : categoryNames[selectedIndex]
        var results = allProviders
        if selectedCategory != "All" {
            results = results.filter { $0.role.lowercased().contains(selectedCategory.lowercased()) }
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            results = results.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.role.lowercased().contains(searchText.lowercased()) }
        }
        self.filteredProviders = results
        applySorting()
    }
    
    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProviders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath) as! ProviderTableCell
        cell.configure(with: filteredProviders[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showServiceItem", sender: filteredProviders[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showServiceItem",
           let destVC = segue.destination as? ServiceItemTableViewController,
           let provider = sender as? ServiceProviderModel {
            destVC.providerData = provider
        }
    }
}

// MARK: - Fix: Search Results Updating Conformance
extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterProvidersByCategory()
    }
}

// MARK: - Provider Cell
class ProviderTableCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        [avatarImageView, nameLabel, roleLabel, priceLabel].forEach { containerView.addSubview($0) }
        
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
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        
        // FIXED: Set purple color for avatar icon
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        
        // Fix: Use Optional Chaining for services and extract price
        let prices = provider.services?.compactMap({ $0.price }) ?? []
        if let minPrice = prices.min() {
            priceLabel.text = String(format: "Starts at BHD %.3f", minPrice)
        } else {
            priceLabel.text = "Contact for price"
        }
    }
}
