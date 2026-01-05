import UIKit
import FirebaseFirestore

// MARK: - Protocol
// Optional protocol to update data
protocol CategoryManagerDelegate: AnyObject {
    func didUpdateCategories()
}

// MARK: - Custom Cell (Card Design)
class CategoryCardCell: UITableViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 1. Setup Container (Card)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // 2. Setup Label
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Setup Icon
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)
        
        // 4. Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
    
    // Tap Animation
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}

// MARK: - Category Management Controller
class CategoryManagementTVC: UITableViewController {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var categories: [QueryDocumentSnapshot] = []
    weak var delegate: CategoryManagerDelegate?
    
    // Main App Brand Color
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 🛠️ Note: Adjust row height for correct card display
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        // Register Cell
        tableView.register(CategoryCardCell.self, forCellReuseIdentifier: "CategoryCardCell")
        
        // Initialize Firebase Listener
        startFirebaseListener()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.title = "Category Management"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add Button (+)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTapped))
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    // MARK: - Firebase Logic
    private func startFirebaseListener() {
        print("🔥 Starting Firestore Listener for Categories...")
        
        db.collection("categories").order(by: "createdAt", descending: false).addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching categories: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("⚠️ No documents found")
                return
            }
            
            print("✅ Successfully fetched \(documents.count) categories.")
            self.categories = documents
            self.tableView.reloadData()
            self.delegate?.didUpdateCategories()
        }
    }
    
    @objc private func addCategoryTapped() {
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Category Name" }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self?.saveCategoryToFirebase(name: name)
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saveCategoryToFirebase(name: String) {
        db.collection("categories").addDocument(data: [
            "name": name,
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Failed to save: \(error.localizedDescription)")
            } else {
                print("✅ Category saved successfully.")
            }
        }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UITableViewCell()
        }
        
        let doc = categories[indexPath.row]
        let name = doc.get("name") as? String ?? "Unknown"
        cell.configure(name: name)
        
        return cell
    }
    
    // MARK: - Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let docID = categories[indexPath.row].documentID
            db.collection("categories").document(docID).delete { error in
                if let error = error {
                    print("❌ Error deleting: \(error.localizedDescription)")
                } else {
                    print("🗑️ Category deleted successfully")
                }
            }
        }
    }

    // MARK: - Table View Delegate (Transition to Providers)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1. Extract selected category data
        let doc = categories[indexPath.row]
        let categoryName = doc.get("name") as? String ?? "Unknown"
        let categoryID = doc.documentID
        
        print("➡️ Selected Category: \(categoryName) (ID: \(categoryID))")
        
        // 2. Prepare Providers Page
        let providersVC = ProvidersTableViewController()
        
        // 3. Pass Data (Binding)
        providersVC.selectedCategory = categoryName
        providersVC.categoryID = categoryID
        
        // 4. Navigate to the next screen
        navigationController?.pushViewController(providersVC, animated: true)
    }
}
