import UIKit

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var categorySegment: UISegmentedControl = {
        // قمنا بإضافة "All" لرؤية كل شيء للتجربة
        let sc = UISegmentedControl(items: ["All", "IT Solutions", "Teaching", "Digital Services"])
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
    
    // هذه المصفوفة ستمتلئ من الفايربيس، لا حاجة للبيانات الوهمية الآن
    var allProviders: [ServiceProviderModel] = []
    
    private var filteredProviders: [ServiceProviderModel] = []
    private var isAscending = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupTableView()
        
        // 🔥 تشغيل دالة جلب البيانات من الفايربيس
        fetchProvidersFromFirebase()
    }
    
    // MARK: - Firebase Fetching 📡
    private func fetchProvidersFromFirebase() {
        print("⏳ Fetching data from Firebase...")
        
        // استدعاء المانجر الذي أنشأناه سابقاً
        ServiceManager.shared.fetchAllServices { [weak self] services in
            guard let self = self else { return }
            
            // 1. تجميع الخدمات حسب اسم الموفر (Grouping)
            // يعني: إذا "Hamed Studio" عنده 3 خدمات، نجمعهم في مكان واحد
            var providersMap: [String: [ServiceModel]] = [:]
            
            for service in services {
                // نستخدم providerName، وإذا كان nil نعتبره "Unknown"
                let pName = service.providerName ?? "Unknown Provider"
                
                if providersMap[pName] == nil {
                    providersMap[pName] = []
                }
                providersMap[pName]?.append(service)
            }
            
            // 2. تحويل المجموعات إلى ServiceProviderModel
            var newProviders: [ServiceProviderModel] = []
            
            for (providerName, providerServices) in providersMap {
                // نأخذ التصنيف (Category) من أول خدمة عشان نحدد دور الشخص
                let role = providerServices.first?.category ?? "Service Provider"
                
                let provider = ServiceProviderModel(
                    id: UUID().uuidString,
                    name: providerName,
                    role: role,
                    imageName: "person.circle.fill", // صورة افتراضية حالياً
                    rating: 5.0, // تقييم افتراضي
                    skills: providerServices.map { $0.name }, // المهارات هي أسماء الخدمات
                    availability: "Available",
                    location: "Online",
                    phone: "N/A",
                    services: providerServices, // 🔥 نضع الخدمات الحقيقية هنا
                    aboutMe: "Provider from Firebase",
                    portfolio: [],
                    certifications: [],
                    reviews: [],
                    experience: "N/A",
                    completedProjects: 0
                )
                newProviders.append(provider)
            }
            
            // 3. تحديث الواجهة
            DispatchQueue.main.async {
                self.allProviders = newProviders
                self.filterProvidersByCategory() // إعادة الفلترة والعرض
                print("✅ Successfully loaded \(newProviders.count) providers from Firebase!")
            }
        }
    }
    
    // MARK: - Setup
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
        let selectedCategory = categorySegment.selectedSegmentIndex
        var categoryProviders: [ServiceProviderModel] = []
        
        switch selectedCategory {
        case 0: // All
            categoryProviders = allProviders
        case 1: // IT Solutions
            categoryProviders = allProviders.filter {
                $0.role.contains("IT") || $0.role.contains("Engineer") || $0.role.contains("Technician")
            }
        case 2: // Teaching
            categoryProviders = allProviders.filter { $0.role.contains("Teacher") || $0.role.contains("Tutor") }
        case 3: // Digital Services
            categoryProviders = allProviders.filter {
                $0.role.contains("Design") || $0.role.contains("Creative") || $0.role.contains("Media")
            }
        default:
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
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
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
        containerView.addSubview(ratingLabel)
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
            
            ratingLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            viewButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            viewButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            viewButton.widthAnchor.constraint(equalToConstant: 110),
            viewButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        ratingLabel.text = "⭐️ \(provider.rating)"
        if let image = UIImage(named: provider.imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
