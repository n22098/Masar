import UIKit
import FirebaseFirestore // Added Firebase

// MARK: - Protocol
protocol CategoryManagerDelegate: AnyObject {
    func didUpdateCategories()
}

// MARK: - 1. Custom Cell (Card Design)
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
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)
        
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}

// MARK: - 2. Main Controller
class CategoryManagementTVC: UITableViewController {
    
    // MARK: - Properties
    private let db = Firestore.firestore() // Firebase Reference
    private var categories: [QueryDocumentSnapshot] = [] // Store Firestore documents
    weak var delegate: CategoryManagerDelegate?
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startFirebaseListener() // Start listening for live updates
        tableView.register(CategoryCardCell.self, forCellReuseIdentifier: "CategoryCardCell")
    }
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTapped))
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    // MARK: - Firebase Logic
    private func startFirebaseListener() {
        // Listen to 'categories' collection in real-time
        db.collection("categories").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching categories: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self?.categories = documents
            self?.tableView.reloadData()
            self?.delegate?.didUpdateCategories() // Notify Dashboard if needed
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
                }
            }
        }
    }
}
