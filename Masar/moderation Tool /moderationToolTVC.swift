import UIKit

class moderationToolTVC: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the title in the Navigation Bar
        self.navigationItem.title = "Moderation Tool"
        
        // Optional: Makes the title large
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view selection
    
    // This function detects which static cell you tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect the row so it doesn't stay gray
        tableView.deselectRow(at: indexPath, animated: true)
        
        // You can add extra logic here if needed
        print("Selected section \(indexPath.section), row \(indexPath.row)")
    }
    
    /* NOTE: Do NOT include 'numberOfSections' or 'numberOfRowsInSection'.
       Leaving them out allows the Storyboard's Static Cells to show up automatically.
    */
}
