import UIKit
import FirebaseFirestore

// 1. Data Model (DTO)
/// VerificationItem: Represents the essential data for a provider's verification request.
/// OOD Principle: Abstraction - This struct provides a simplified view of the
/// complex document stored in Firestore.
struct VerificationItem {
    let uid: String
    let providerName: String
    let providerCategory: String
    let status: String
}

// 2. Custom Cell Class
/// VerificationItemCell: Encapsulates the visual design for a single verification row.
/// OOD Principle: Encapsulation - The cell manages its own subviews and layout constraints.
class VerificationItemCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    /// setupUI: Builds the card-based design with shadows and programmatic Auto Layout.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container styling (Card effect)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(chevronImageView)
        
        // MARK: - Auto Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    /// Maps the model data to the UI components.
    func configure(with item: VerificationItem) {
        nameLabel.text = item.providerName
        categoryLabel.text = item.providerCategory
    }
    
    /// OOD Polish: Provides a scale animation when the user taps the cell.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}

// 3. Main Controller
/// VerificationVC: Monitors and displays pending provider verification requests.
/// OOD Principle: Separation of Concerns - This controller handles the list view and Firebase listener,
/// while the cell handles the display.
class VerificationVC: UITableViewController {
    
    /// requests: Local source of truth for the table view data.
    var requests: [VerificationItem] = []
    let db = Firestore.firestore()
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        tableView.register(VerificationItemCell.self, forCellReuseIdentifier: "VerificationItemCell")
        
        // Initial Data Fetch
        fetchPendingRequests()
    }
    
    /// fetchPendingRequests: Sets up a real-time listener on the provider_requests collection.
    /// OOD Principle: Reactive Programming - The UI is synchronized with the remote database state.
    func fetchPendingRequests() {
        db.collection("provider_requests")
            .whereField("status", isEqualTo: "pending") // Filter to show only pending items
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching requests: \(error)")
                    return
                }
                
                // Transforming Firestore documents into local Swift models
                self.requests = snapshot?.documents.compactMap { doc -> VerificationItem? in
                    let data = doc.data()
                    let name = data["name"] as? String ?? "Unknown"
                    let category = data["category"] as? String ?? "Unknown"
                    let status = data["status"] as? String ?? "pending"
                    let uid = doc.documentID
                    
                    return VerificationItem(uid: uid, providerName: name, providerCategory: category, status: status)
                } ?? []
                
                // Refreshing the table view on the main thread
                self.tableView.reloadData()
            }
    }
    
    /// Global UI styling for the navigation bar and background.
    func setupDesign() {
        self.title = "Verification"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source (OOD Protocol Implementation)
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VerificationItemCell", for: indexPath) as? VerificationItemCell else {
            return UITableViewCell()
        }
        
        let item = requests[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Small delay to let the user see the touch animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            // Passing the specific UID to the detail page
            let selectedRequest = self.requests[indexPath.row]
            self.performSegue(withIdentifier: "showProviderRequest", sender: selectedRequest.uid)
        }
    }
    
    /// OOD Principle: Dependency Injection - Passing the specific document ID
    /// required by the next screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderRequest",
           let destinationVC = segue.destination as? ProviderRequestTVC,
           let uid = sender as? String {
            destinationVC.requestUID = uid
        }
    }
}
