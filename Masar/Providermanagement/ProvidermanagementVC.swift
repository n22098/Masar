import UIKit

class ProviderManagementVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Provider Management"
        
        // Refresh the table in case data was added elsewhere
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Accessing providers from your SampleData
        return SampleData.providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure the identifier here matches the one in your Storyboard for the Provider cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath)
        
        let provider = SampleData.providers[indexPath.row]
        cell.textLabel?.text = provider.fullName
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Assuming your detail view controller is named ProviderDetailsTVC
        if let detailVC = segue.destination as? ProviderDetailsTVC {
            
            // Segue from the '+' button
            if segue.identifier == "addProviderSegue" {
                detailVC.provider = nil
                detailVC.isNewProvider = true
            }
            // Segue from selecting a row in the table
            else if segue.identifier == "showProviderDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailVC.provider = SampleData.providers[indexPath.row]
                    detailVC.isNewProvider = false
                }
            }
        }
    }
}
