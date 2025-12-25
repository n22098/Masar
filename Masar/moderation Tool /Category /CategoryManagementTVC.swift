import UIKit

// MARK: - Protocol
protocol CategoryManagerDelegate: AnyObject {
    func didUpdateCategories(_ categories: [Category])
}

// MARK: - 1. كلاس الخلية المخصصة (تصميم البطاقة)
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
        
        // إعداد البطاقة
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // إعداد النص
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black // لون أسود واضح
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // إعداد السهم
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)
        
        // القيود (Constraints)
        NSLayoutConstraint.activate([
            // البطاقة
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 55),
            
            // النص
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // السهم
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
    
    // أنيميشن الضغط
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}

// MARK: - 2. الكنترولر الرئيسي
class CategoryManagementTVC: UITableViewController {
    
    // MARK: - Properties
    var categories = [Category]()
    var allProviders: [ServiceProviderModel] = []
    weak var delegate: CategoryManagerDelegate?
    
    // لون البراند الموحد
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        
        // تسجيل الخلية الجديدة
        tableView.register(CategoryCardCell.self, forCellReuseIdentifier: "CategoryCardCell")
    }
    
    private func setupUI() {
        self.title = "Category Management"
        
        // 1. إعداد النافيجيشن بار (بنفسجي + نص أبيض)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white // أزرار بيضاء
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 2. زر الإضافة (أبيض)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTapped))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // ❌ تم حذف زر "Done" لكي يظهر زر "Back" الأصلي من الستوري بورد
        
        // 3. تصميم الجدول (خلفية رمادية + بدون خطوط)
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    private func loadData() {
        categories = Category.loadCategories() ?? []
        if allProviders.isEmpty {
            allProviders = SampleData.getTestProviders()
        }
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(name: category.name)
        
        return cell
    }
    
    // MARK: - Swipe to Delete
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            Category.saveCategories(categories)
            tableView.deleteRows(at: [indexPath], with: .fade)
            delegate?.didUpdateCategories(categories)
        }
    }
    
    // MARK: - Tap Action
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // تأخير بسيط للأنيميشن
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let selectedCategory = categories[indexPath.row]
        
        // Filtering logic (Simple keyword match)
        let keyword = selectedCategory.name.replacingOccurrences(of: "ing", with: "")
        let matchingProviders = allProviders.filter { provider in
            provider.role.localizedCaseInsensitiveContains(keyword) ||
            selectedCategory.name.localizedCaseInsensitiveContains(provider.role)
        }
        
        showProviderList(for: selectedCategory.name, providers: matchingProviders)
    }
    
    private func showProviderList(for categoryName: String, providers: [ServiceProviderModel]) {
        let providerNames = providers.isEmpty ? "No providers in this category." : providers.map { "• \($0.name) (\($0.role))" }.joined(separator: "\n")
        
        let alert = UIAlertController(title: "\(categoryName) Members", message: providerNames, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Category Name" }
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self?.categories.append(Category(name: name))
                self?.saveAndRefresh()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saveAndRefresh() {
        Category.saveCategories(categories)
        tableView.reloadData()
    }
}
