import UIKit

class SeekermanagementVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Seeker Management"
        // Refresh the table in case data was added elsewhere
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Pull count from SampleData class
        return SampleData.seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This string MUST be identical to the one in your Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath)
        
        let seeker = SampleData.seekers[indexPath.row]
        cell.textLabel?.text = seeker.fullName
        
        return cell
    }

    // MARK: - Navigation

    
        
    
}
