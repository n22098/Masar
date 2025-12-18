import UIKit

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["IT Solutions", "Teaching", "Digital Services"])
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
    
    var allProviders: [ServiceProviderModel] = [
        // IT Solutions (5 providers)
        ServiceProviderModel(
            id: "1",
            name: "Sayed Husain",
            role: "Software Engineer",
            imageName: "it1",
            rating: 4.9,
            skills: ["HTML", "CSS", "JS", "PHP", "MySQL"],
            availability: "Sat-Thu",
            location: "Online",
            phone: "36666222"
        ),
        ServiceProviderModel(
            id: "2",
            name: "Joe Dean",
            role: "Network Technician",
            imageName: "it2",
            rating: 4.5,
            skills: ["Networking", "Security"],
            availability: "Sun-Thu",
            location: "Manama",
            phone: "33333333"
        ),
        ServiceProviderModel(
            id: "3",
            name: "Amin Altajer",
            role: "Computer Repair",
            imageName: "it3",
            rating: 4.8,
            skills: ["Hardware", "Software"],
            availability: "Daily",
            location: "Riffa",
            phone: "39999999"
        ),
        ServiceProviderModel(
            id: "7",
            name: "Ahmed Ali",
            role: "IT Support Engineer",
            imageName: "it4",
            rating: 4.7,
            skills: ["Windows", "Linux", "Cloud"],
            availability: "Mon-Fri",
            location: "Manama",
            phone: "35555555"
        ),
        ServiceProviderModel(
            id: "8",
            name: "Mohammed Hassan",
            role: "Database Administrator",
            imageName: "it5",
            rating: 4.6,
            skills: ["SQL", "Oracle", "MongoDB"],
            availability: "Sun-Thu",
            location: "Online",
            phone: "34444444"
        ),
        
        // Teaching (5 providers)
        ServiceProviderModel(
            id: "4",
            name: "Kashmala Saleem",
            role: "Math Teacher",
            imageName: "t1",
            rating: 5.0,
            skills: ["Math", "Physics"],
            availability: "Weekends",
            location: "Online",
            phone: "34444444"
        ),
        ServiceProviderModel(
            id: "9",
            name: "Fatima Ahmed",
            role: "English Teacher",
            imageName: "t2",
            rating: 4.8,
            skills: ["English", "Grammar"],
            availability: "Daily",
            location: "Riffa",
            phone: "36111111"
        ),
        ServiceProviderModel(
            id: "10",
            name: "Sarah Ali",
            role: "Science Teacher",
            imageName: "t3",
            rating: 4.7,
            skills: ["Biology", "Chemistry"],
            availability: "Mon-Fri",
            location: "Manama",
            phone: "37222222"
        ),
        ServiceProviderModel(
            id: "11",
            name: "Layla Hassan",
            role: "Arabic Teacher",
            imageName: "t4",
            rating: 4.9,
            skills: ["Arabic", "Literature"],
            availability: "Weekends",
            location: "Online",
            phone: "38333333"
        ),
        ServiceProviderModel(
            id: "12",
            name: "Noor Mohammed",
            role: "History Teacher",
            imageName: "t5",
            rating: 4.6,
            skills: ["History", "Geography"],
            availability: "Sun-Thu",
            location: "Muharraq",
            phone: "39444444"
        ),
        
        // Digital Services (5 providers)
        ServiceProviderModel(
            id: "5",
            name: "Osama Hasan",
            role: "UI/UX Designer",
            imageName: "d1",
            rating: 4.6,
            skills: ["Figma", "Adobe XD"],
            availability: "Flexible",
            location: "Online",
            phone: "37777777"
        ),
        ServiceProviderModel(
            id: "6",
            name: "Vishal Santhosh",
            role: "Content Creator",
            imageName: "d3",
            rating: 4.8,
            skills: ["Video Editing", "Photography"],
            availability: "Mon-Sat",
            location: "Muharraq",
            phone: "38888888"
        ),
        ServiceProviderModel(
            id: "13",
            name: "Zainab Ali",
            role: "Graphic Designer",
            imageName: "d2",
            rating: 4.7,
            skills: ["Photoshop", "Illustrator"],
            availability: "Mon-Fri",
            location: "Online",
            phone: "35666666"
        ),
        ServiceProviderModel(
            id: "14",
            name: "Khalid Ahmed",
            role: "Social Media Manager",
            imageName: "d4",
            rating: 4.5,
            skills: ["Instagram", "Facebook", "TikTok"],
            availability: "Daily",
            location: "Manama",
            phone: "36777777"
        ),
        ServiceProviderModel(
            id: "15",
            name: "Mariam Hassan",
            role: "Video Editor",
            imageName: "d5",
            rating: 4.9,
            skills: ["Premiere Pro", "After Effects"],
            availability: "Flexible",
            location: "Online",
            phone: "37888888"
        )
    ]
    
    private var filteredProviders: [ServiceProviderModel] = []
    private var isAscending = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupTableView()
        
        // Show IT Solutions providers by default
        filterProvidersByCategory()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // Large title
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search"
        
        // Purple navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 36, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Logout button (LEFT)
        let logoutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = .white
        navigationItem.leftBarButtonItem = logoutButton
        
        // Sort button (RIGHT)
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
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        // Register custom cell
        tableView.register(ProviderTableCell.self, forCellReuseIdentifier: "ProviderCell")
        
        // Add segment control as header
        tableView.tableHeaderView = createHeaderView()
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1)
        
        categorySegment.frame = CGRect(x: 20, y: 15, width: view.frame.width - 40, height: 44)
        headerView.addSubview(categorySegment)
        
        return headerView
    }
    
    // MARK: - Actions
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(
            title: nil,
            message: "Sort by:",
            preferredStyle: .actionSheet
        )
        
        // A-Z Option
        alert.addAction(UIAlertAction(title: "A-Z", style: .default) { [weak self] _ in
            self?.isAscending = true
            self?.applySorting()
        })
        
        // Z-A Option
        alert.addAction(UIAlertAction(title: "Z-A", style: .default) { [weak self] _ in
            self?.isAscending = false
            self?.applySorting()
        })
        
        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
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
    
    private func performLogout() {
        // Clear user session
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
        
        // Navigate to login screen
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
            // Fallback: pop to root
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        filterProvidersByCategory()
    }
    
    private func filterProvidersByCategory() {
        let selectedCategory = categorySegment.selectedSegmentIndex
        var categoryProviders: [ServiceProviderModel] = []
        
        switch selectedCategory {
        case 0: // IT Solutions
            categoryProviders = allProviders.filter {
                $0.role.contains("Engineer") ||
                $0.role.contains("Technician") ||
                $0.role.contains("Repair") ||
                $0.role.contains("Administrator")
            }
        case 1: // Teaching
            categoryProviders = allProviders.filter { $0.role.contains("Teacher") }
        case 2: // Digital Services
            categoryProviders = allProviders.filter {
                $0.role.contains("Designer") ||
                $0.role.contains("Creator") ||
                $0.role.contains("Editor") ||
                $0.role.contains("Manager")
            }
        default:
            categoryProviders = allProviders
        }
        
        // Apply search filter if active
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredProviders = categoryProviders.filter { provider in
                provider.name.lowercased().contains(searchText.lowercased()) ||
                provider.role.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredProviders = categoryProviders
        }
        
        // Apply current sorting
        applySorting()
    }
    
    private func filterContent(for searchText: String) {
        // Get current category providers first
        let selectedCategory = categorySegment.selectedSegmentIndex
        var categoryProviders: [ServiceProviderModel] = []
        
        switch selectedCategory {
        case 0:
            categoryProviders = allProviders.filter {
                $0.role.contains("Engineer") ||
                $0.role.contains("Technician") ||
                $0.role.contains("Repair") ||
                $0.role.contains("Administrator")
            }
        case 1:
            categoryProviders = allProviders.filter { $0.role.contains("Teacher") }
        case 2:
            categoryProviders = allProviders.filter {
                $0.role.contains("Designer") ||
                $0.role.contains("Creator") ||
                $0.role.contains("Editor") ||
                $0.role.contains("Manager")
            }
        default:
            categoryProviders = allProviders
        }
        
        // Then filter by search text
        if searchText.isEmpty {
            filteredProviders = categoryProviders
        } else {
            filteredProviders = categoryProviders.filter { provider in
                provider.name.lowercased().contains(searchText.lowercased()) ||
                provider.role.lowercased().contains(searchText.lowercased()) ||
                provider.skills.joined(separator: " ").lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply current sorting
        applySorting()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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

// MARK: - UISearchResultsUpdating
extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContent(for: searchText)
    }
}

// MARK: - Custom Provider Cell
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
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor.lightGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(roleLabel)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(viewButton)
        containerView.addSubview(chevronImageView)
        
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
            viewButton.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            viewButton.widthAnchor.constraint(equalToConstant: 110),
            viewButton.heightAnchor.constraint(equalToConstant: 36),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        ratingLabel.text = "⭐️ \(provider.rating)"
        
        // Try to load the image
        if let image = UIImage(named: provider.imageName) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
