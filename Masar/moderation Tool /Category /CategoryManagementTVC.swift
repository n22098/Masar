import UIKit

// MARK: - Protocol
protocol CategoryManagerDelegate: AnyObject {
    func didUpdateCategories(_ categories: [Category])
}

class CategoryManagementTVC: UITableViewController {
    
    // MARK: - Properties
    var categories = [Category]()
    var allProviders: [ServiceProviderModel] = [] // Passed from Search screen
    weak var delegate: CategoryManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "Category Management"
        tableView.tableFooterView = UIView()
        
        // Register the cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        // Navigation Buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        // Swipe-to-delete logic:
        // We set editing to FALSE so the red buttons disappear.
        // iOS will now reveal the 'Delete' button only when the user swipes.
        tableView.setEditing(false, animated: false)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.textLabel?.textColor = .systemBlue
        
        // In swipe-to-delete mode, disclosure indicators look better
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Swipe to Delete & Reorder Logic
    
    // This enables the "Swipe" gesture
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // This handles the actual deletion logic when the user taps the revealed "Delete" button
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. Remove from data source
            categories.remove(at: indexPath.row)
            
            // 2. Persist the change
            Category.saveCategories(categories)
            
            // 3. Update UI with animation (better than reloadData for swipes)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // 4. Notify delegate of change
            delegate?.didUpdateCategories(categories)
        }
    }
    
    // Note: Reordering (moveRowAt) usually requires tableView.isEditing = true.
    // Since we turned that off to allow swiping, these rows won't be draggable
    // unless you add an "Edit" button to toggle the mode.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moved = categories.remove(at: sourceIndexPath.row)
        categories.insert(moved, at: destinationIndexPath.row)
        Category.saveCategories(categories)
    }

    // MARK: - Tap to See Providers
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        
        // Filtering logic
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
}
