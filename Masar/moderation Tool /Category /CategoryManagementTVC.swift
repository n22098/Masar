import UIKit

class CategoryManagementTVC: UITableViewController {
    
//    @IBOutlet var categoryText: UILabel!
//    @IBOutlet weak var segCategory: UISegmentedControl!
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateCategorySelection()
        tableView.tableFooterView = UIView()
        categories = Category.loadCategories() ?? []
    }
//    @IBAction func toggleChange(_ sender: UISegmentedControl) {
//        updateCategorySelection()
//    }
//    func updateCategorySelection() {
//        // Just the names of your categories
//        let categories = ["IT Helper", "Tutor", "Designer"]
//        
//        let index = segCategory.selectedSegmentIndex
//        
//        // Update the label with the selected category name
//        if index >= 0 && index < categories.count {
//            categoryText.text = categories[index]
//        }
        
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

