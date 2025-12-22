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
        return SampleData.seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath)
        
        let seeker = SampleData.seekers[indexPath.row]
        cell.textLabel?.text = seeker.fullName
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SeekerDetailsTVC {
            
            // Check if segue is from the + button
            if segue.identifier == "addSeekerSegue" {
                // Adding new seeker
                detailVC.seeker = nil
                detailVC.isNewSeeker = true
            }
            // Check if segue is from table cell selection
            else if segue.identifier == "showSeekerDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Showing existing seeker
                    detailVC.seeker = SampleData.seekers[indexPath.row]
                    detailVC.isNewSeeker = false
                }
            }
        }
    }
}
//
//
//### Step 3: Make sure you have TWO segues:
//
//1. **From the table cell** to SeekerDetailsTVC
//   - Identifier: `showSeekerDetailsSegue`
//   - This is for viewing existing seekers
//
//2. **From the + Bar Button Item** to SeekerDetailsTVC
//   - Identifier: `addSeekerSegue`
//   - This is for adding new seekers
//
//### How to check if segues are set up correctly:
//
//1. Click on the **Document Outline** (left sidebar in Storyboard)
//2. Expand **Seeker Management Scene**
//3. You should see:
//   - One segue under the **prototype cell** (showSeekerDetailsSegue)
//   - One segue under the **Bar Button Item** (addSeekerSegue)
//
//### Visual Guide:
//```
//SeekermanagementVC
//├── Navigation Bar
//│   └── + Button ─────(addSeekerSegue)────→ SeekerDetailsTVC
//└── Table View
//    └── Prototype Cell ─(showSeekerDetailsSegue)─→ SeekerDetailsTVC
