import UIKit

class CategoryManagementtableviewcontroller: UITableViewController {

    // This array holds your data
        var categories: [String] = ["Electronics", "Groceries", "Clothing"]

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // This ensures the table looks clean if empty
            tableView.tableFooterView = UIView()
        }

        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destinationVC = segue.destination as? AddCategoryViewController {
                
                // Callback when the other screen saves a new category
                destinationVC.onSave = { [weak self] newName in
                    // Ensure name isn't empty
                    if !newName.isEmpty {
                        self?.categories.append(newName)
                        self?.tableView.reloadData()
                    }
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
            // "cell" must match the Identifier in your Storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "showCategoryTableViewCell", for: indexPath)
            
            // Set the text for the row
            cell.textLabel?.text = categories[indexPath.row]
            
            return cell
        }
        
        // Optional: Add swipe-to-delete to keep your management clean
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                categories.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
