import UIKit

class CategoryManagementtableviewcontroller: UITableViewController {

    // Start with an empty array or some defaults
    var categories: [String] = ["Electronics"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if we are going to the Add screen
        if let destinationVC = segue.destination as? AddCategoryViewController {
            
            // This code runs when the Add screen "Saves"
            destinationVC.onSave = { [weak self] newName in
                self?.categories.append(newName)
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}
