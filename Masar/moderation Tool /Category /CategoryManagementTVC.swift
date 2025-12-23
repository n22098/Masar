import UIKit

// MARK: - Protocol
protocol CategoryManagerDelegate: AnyObject {
    func didUpdateCategories(_ categories: [Category])
}

class CategoryManagementTVC: UITableViewController {
    
    // MARK: - Properties
    var categories = [Category]()
    var allProviders: [ServiceProviderModel] = [] // Ensure this is passed from Search screen
    weak var delegate: CategoryManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "Category Management"
        tableView.tableFooterView = UIView()
        
        // Register the cell identifier to prevent crashes
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        // Navigation Buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        // Settings for Edit Mode
        tableView.setEditing(true, animated: false)
        tableView.allowsSelectionDuringEditing = true
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
        // We use dequeueReusableCell which returns a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.textLabel?.textColor = .systemBlue
        cell.accessoryType = .disclosureIndicator
        
        // EVERY path must return a cell. This line fixes your error.
        return cell
    }
    
    // MARK: - Tap to See Providers
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        
        // Filtering logic to find providers in this category
        let keyword = selectedCategory.name.replacingOccurrences(of: "ing", with: "")
        let matchingProviders = allProviders.filter { provider in
            provider.role.localizedCaseInsensitiveContains(keyword) ||
            selectedCategory.name.localizedCaseInsensitiveContains(provider.role)
        }
        
        showProviderList(for: selectedCategory.name, providers: matchingProviders)
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    @objc private func doneTapped() {
        delegate?.didUpdateCategories(categories)
        // If presented modally, use dismiss. If pushed, use pop.
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func saveAndRefresh() {
        Category.saveCategories(categories)
        tableView.reloadData()
    }
    
    // MARK: - Edit Logic
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            saveAndRefresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = categories.remove(at: sourceIndexPath.row)
        categories.insert(moved, at: destinationIndexPath.row)
        Category.saveCategories(categories)
    }
}
