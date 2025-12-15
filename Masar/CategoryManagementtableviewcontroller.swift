import UIKit

// Make sure the class name exactly matches the Custom Class set in the Storyboard
class CategoryManagementtableviewcontroller: UITableViewController {
    
    // Define the menu items specific to Category Management
    let categoryMenuItems = [
        "Add New Category",
        "View All Categories",
        "Pending Category Approvals"
    ]
    
    // Define the reuse identifier for this screen's cell
    let cellReuseIdentifier = "CategoryCell" // <-- You must set this ID in the Storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the title for the navigation bar
        self.title = "Category Management"
        
        // If you are using dynamic prototypes, you might want to register the cell class
        // but since you are using a Storyboard, setting the identifier is usually enough.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // We only have one section for the menu items.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count of items in the menu array
        return categoryMenuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. Dequeue the cell using the correct identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? UITableViewCell else {
            fatalError("Could not dequeue cell with identifier \(cellReuseIdentifier). Check Storyboard.")
        }

        // 2. Set the text
        let itemTitle = categoryMenuItems[indexPath.row]
        cell.textLabel?.text = itemTitle
        
        // 3. Add the accessory arrow
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        // Use a switch to perform actions/segues based on the selected row
        switch indexPath.row {
        case 0: // Add New Category
            performSegue(withIdentifier: "showAddCategory", sender: nil)
        case 1: // View All Categories
            performSegue(withIdentifier: "showViewAllCategories", sender: nil)
        case 2: // Pending Category Approvals
            performSegue(withIdentifier: "showPendingApprovals", sender: nil)
        default:
            break
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Use this to pass data to the next screen before the transition
    }
}
