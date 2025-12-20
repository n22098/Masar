import UIKit

class CategoryManagementTVC: UITableViewController {

    // This array holds your Category objects
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This ensures the table looks clean if empty
        tableView.tableFooterView = UIView()
        
        // Load data from disk or use samples if disk is empty
        if let savedCategories = Category.loadCategories() {
            categories = savedCategories
        } else {
            categories = Category.loadSampleCategories()
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check if destination is a Nav Controller, if so, get the top view controller
        let destination = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination
        
        // 2. Now check if it's the AddCategoryViewController
        if let addVC = destination as? AddCategoryViewController {
            print("DEBUG: Segue triggered, onSave closure is being set.")
            
            addVC.onSave = { [weak self] newName in
                guard let self = self else { return }
                print("DEBUG: Received new name: \(newName)")
                
                let newCategory = Category(name: newName, iconName: "tag", colorHex: "#000000")
                self.categories.append(newCategory)
                
                Category.saveCategories(self.categories)
                self.tableView.reloadData()
            }
        }
    }
            
        
    

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // IMPORTANT: In Storyboard, set your Cell Identifier to "CategoryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        
        // Set labels and images based on the struct attributes
        cell.textLabel?.text = category.name
        cell.imageView?.image = UIImage(systemName: category.iconName)
        
        return cell
    }
    
    // Swipe-to-delete logic
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove from array
            categories.remove(at: indexPath.row)
            
            // Save the updated list to disk
            Category.saveCategories(categories)
            
            // Animate the row removal
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
