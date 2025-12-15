//
//  moderationTooltableviewcontroller.swift
//  Masar
//
//  Created by BP-36-201-08 on 15/12/2025.
//

import UIKit

class moderationTooltableviewcontroller: UITableViewController {
    
    // Define the list of menu items
    let menuItems = ["Category Management", "Report Management", "Verification"]
    
    // Define the cell's reuse identifier (MUST match the Storyboard setting)
    let cellReuseIdentifier = "ModerationCell","CategoryCell","ReportCell" // <-- You must use this Identifier in the Storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Moderations Tool"
    }
    
    // MARK: - Table view data source
    
    // 1. Tell the table view how many sections there are (1 for a simple list)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 2. Tell the table view how many rows are in the section (the count of our menuItems array)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count // Returns 3
    }
    
    // 3. **THE SOLUTION FOR THE CRASH:** Provide the actual cell content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Try to reuse an existing cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? UITableViewCell else {
            // This happens if the identifier is wrong or the cell type is incorrect.
            fatalError("Could not dequeue cell with identifier \(cellReuseIdentifier). Check Storyboard.")
        }
        
        // Set the text of the cell based on the menuItems array
        let itemTitle = menuItems[indexPath.row]
        cell.textLabel?.text = itemTitle
        
        // Add the disclosure indicator (the little arrow) for navigation
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Always deselect the row immediately after tapping for a clean visual.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Determine the action based on the row index
        switch indexPath.row {
        case 0: // Category Management
            performSegue(withIdentifier: "showCategoryManagement", sender: nil)
        case 1: // Report Management
            performSegue(withIdentifier: "showReportManagement", sender: nil)
        case 2: // Verification
            performSegue(withIdentifier: "showVerification", sender: nil)
        default:
            break
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // You can use this method here to pass data to the next view controller
        print("Preparing for segue with identifier: \(String(describing: segue.identifier))")
    }
}
