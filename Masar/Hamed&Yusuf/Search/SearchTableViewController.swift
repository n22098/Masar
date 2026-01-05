// ===================================================================================
// SEARCH TABLE VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows users to search, filter, and sort service providers.
//
// KEY FEATURES:
// 1. Advanced Search: Filters providers by name or role in real-time.
// 2. Dynamic Categories: Fetches categories from Firestore to populate the segment control.
// 3. Sorting: Sorts results by Name (A-Z) or Price (Low/High).
// 4. Data Aggregation: Uses DispatchGroup to merge data from Users, ProviderRequests, and Services collections.
// 5. Programmatic Header: Creates a custom header view with SearchBar and SegmentControl.
// ===================================================================================

import UIKit
import FirebaseFirestore
import FirebaseAuth

// Enum to manage different sorting states
enum SortOption {
    case nameAZ
    case nameZA
    case priceLowToHigh
    case priceHighToLow
}

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: - UI Components
    // Lazy initialization ensures these views are only created when needed
    
    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search provider..."
        sb.searchBarStyle = .minimal
        sb.delegate = self
        sb.backgroundImage = UIImage() // Removes default background lines
        sb.searchTextField.backgroundColor = .white
        sb.searchTextField.textColor = .black
        sb.searchTextField.layer.cornerRadius = 10
        sb.searchTextField.clipsToBounds = true
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private var currentSort: SortOption = .nameAZ
    
    private lazy var categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor(white: 0.95, alpha: 1)
        sc.selectedSegmentTintColor = .white
        
        // Customizing text attributes for normal and selected states
        sc.setTitleTextAttributes([.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 14, weight: .medium)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1), .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    private lazy var sortHeaderButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        
        // Add Shadow
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.08
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var searchBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        // Container shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Data Properties
    var allProviders: [ServiceProviderModel] = []       // Source of truth
    private var filteredProviders: [ServiceProviderModel] = [] // Displayed data
    private var categoryNames: [String] = ["All"]
    let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchCategoriesFromFirebase()
        fetchProvidersFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Data Fetching: Categories
    // Listen for category updates in real-time
    private func fetchCategoriesFromFirebase() {
        db.collection("categories").order(by: "createdAt", descending: false).addSnapshotListener { [weak self] snapshot, error in
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
    
    // MARK: - Data Fetching: Providers
    // Uses DispatchGroup to handle complex data aggregation from multiple collections
    private func fetchProvidersFromFirebase() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let group = DispatchGroup()
        var fetchedServices: [ServiceModel] = []
        var providersDataMap: [String: [String: Any]] = [:]
        
        // Task 1: Fetch Services
        group.enter()
        ServiceManager.shared.fetchAllServices { services in
            fetchedServices = services.filter { $0.providerId != currentUserId }
            group.leave()
        }
        
        // Task 2: Fetch Approved Provider Requests (For profile info)
        group.enter()
        db.collection("provider_requests").whereField("status", isEqualTo: "approved").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                if let uid = doc.data()["uid"] as? String {
                    providersDataMap[uid] = doc.data()
                }
            }
            group.leave()
        }
        
        // Task 3: Fetch User Profiles (Fallback info)
        group.enter()
        db.collection("users").whereField("role", isEqualTo: "provider").getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                let uid = doc.documentID
                // Merge data if needed
                if providersDataMap[uid] == nil {
                    providersDataMap[uid] = doc.data()
                } else {
                    var mergedData = providersDataMap[uid] ?? [:]
                    doc.data().forEach { key, value in
                        if mergedData[key] == nil { mergedData[key] = value }
                    }
                    providersDataMap[uid] = mergedData
                }
            }
            group.leave()
        }
        
        // Finalize: Execute when all tasks are done
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Group services by provider ID
            var groupedServices: [String: [ServiceModel]] = [:]
            for service in fetchedServices {
                if let pId = service.providerId {
                    groupedServices[pId, default: []].append(service)
                }
            }
            
            // Map raw data to ServiceProviderModel objects
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
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Notifications Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(notificationsTapped))
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        tableView.register(ProviderTableCell.self, forCellReuseIdentifier: "ProviderCell")
        tableView.tableHeaderView = createHeaderView()
    }
    
    // Programmatically creates the custom header view
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 120))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        
        headerView.addSubview(searchBarContainer)
        headerView.addSubview(sortHeaderButton)
        headerView.addSubview(categorySegment)
        searchBarContainer.addSubview(searchBar)
        categorySegment.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            sortHeaderButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            sortHeaderButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            sortHeaderButton.widthAnchor.constraint(equalToConstant: 50),
            sortHeaderButton.heightAnchor.constraint(equalToConstant: 50),
            
            searchBarContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            searchBarContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            searchBarContainer.trailingAnchor.constraint(equalTo: sortHeaderButton.leadingAnchor, constant: -10),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 50),
            
            searchBar.topAnchor.constraint(equalTo: searchBarContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor),
            
            categorySegment.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 16),
            categorySegment.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            categorySegment.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            categorySegment.heightAnchor.constraint(equalToConstant: 40)
        ])
        return headerView
    }
    
    // MARK: - Search Logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterProvidersByCategory()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func notificationsTapped() {
        let vc = NotificationsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Sorting Logic
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
        
        filteredProviders.sort { p1, p2 in
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
    
    // Combines Search Text, Selected Category, and Sorting Order
    private func filterProvidersByCategory() {
        let selectedIndex = categorySegment.selectedSegmentIndex
        let selectedCategory = selectedIndex == 0 ? "All" : categoryNames[selectedIndex]
        var results = allProviders
        
        // Filter by Category
        if selectedCategory != "All" {
            results = results.filter { $0.role.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        // Filter by Search Text
        if let searchText = searchBar.text, !searchText.isEmpty {
            results = results.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.role.lowercased().contains(searchText.lowercased()) }
        }
        
        self.filteredProviders = results
        applySorting()
    }
    
    // MARK: - Interaction Handling
    // Simulates a phone call via alert
    private func handlePhoneCall(for phoneNumber: String) {
        let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let alert = UIAlertController(title: "Call Provider?", message: "Simulating call to: \(cleanNumber)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProviders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath) as! ProviderTableCell
        let provider = filteredProviders[indexPath.row]
        cell.configure(with: provider)
        // Set closure to handle button tap inside the cell
        cell.onCallTapped = { [weak self] in self?.handlePhoneCall(for: provider.phone) }
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

// MARK: - Custom Provider Cell
class ProviderTableCell: UITableViewCell {
    
    var onCallTapped: (() -> Void)?
    private let db = Firestore.firestore()
    
    // Container View (Card Design)
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
    
    private lazy var callButton: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        btn.setImage(UIImage(systemName: "phone.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // Setup Constraints
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        [avatarImageView, nameLabel, roleLabel, priceLabel, callButton].forEach { containerView.addSubview($0) }
        
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
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            callButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            callButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            callButton.widthAnchor.constraint(equalToConstant: 44),
            callButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func callButtonTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Haptic feedback
        onCallTapped?()
    }
    
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        
        // Asynchronously fetch profile image
        db.collection("users").document(provider.id).getDocument { [weak self] snap, _ in
            if let urlStr = snap?.data()?["profileImageURL"] as? String, let url = URL(string: urlStr) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let d = data, let img = UIImage(data: d) {
                        DispatchQueue.main.async { self?.avatarImageView.image = img }
                    }
                }.resume()
            }
        }
        
        let prices = provider.services?.compactMap({ $0.price }) ?? []
        priceLabel.text = prices.isEmpty ? "Contact for price" : String(format: "Starts from %.3f BHD ", prices.min()!)
    }
}
