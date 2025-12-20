import UIKit

class CategoryManagementTVC: UITableViewController {

    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        categories = Category.loadCategories() ?? []
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // UNWRAP: Checks if destination is a Navigation Controller or the View Controller directly
        let destination = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination
        
        if let addVC = destination as? AddCategoryViewController {
            // Define what happens when 'Save' is clicked on the next screen
            addVC.onSave = { [weak self] newName in
                guard let self = self else { return }
                
                let newCategory = Category(name: newName)
                self.categories.append(newCategory)
                
                Category.saveCategories(self.categories)
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
}
