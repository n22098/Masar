// ===================================================================================
// SERVICE ITEMS SELECTION VIEW CONTROLLER
// ===================================================================================
// PURPOSE: A multi-selection list that allows Service Providers to tag specific
// skills or sub-services they offer.
//
// KEY FEATURES:
// 1. Master Catalog: A pre-defined list of popular services categorized by industry.
// 2. Multi-Selection: Users can select multiple items (Checkmark logic).
// 3. State Persistence: If a user edits a service, previously selected items appear checked.
// 4. Data Callback: Uses a Closure to send the selected list back to the previous screen.
// ===================================================================================

import UIKit

// MARK: - Data Model
// Simple structure to hold the name of the service and its selection state.
struct ServiceItemOption {
    let name: String
    var isSelected: Bool
}

class ServiceItemsSelectionTableViewController: UITableViewController {

    // MARK: - Data Source
    // ✅ Master Catalog: The complete list of available tags/sub-services.
    // This acts as the "Menu" for the provider to choose from.
    var items: [ServiceItemOption] = [
        
        // General Add-ons (Applicable to most categories)
        ServiceItemOption(name: "Online Consultation", isSelected: false),
        ServiceItemOption(name: "Urgent Service (Priority)", isSelected: false),
        ServiceItemOption(name: "Home Visit", isSelected: false),
        
        // IT & Technical Support
        ServiceItemOption(name: "PC & Laptop Repair", isSelected: false),
        ServiceItemOption(name: "Virus & Malware Removal", isSelected: false),
        ServiceItemOption(name: "Data Recovery", isSelected: false),
        ServiceItemOption(name: "Wi-Fi & Network Setup", isSelected: false),
        ServiceItemOption(name: "Software Installation", isSelected: false),
        ServiceItemOption(name: "Custom PC Building", isSelected: false),
        
        // Digital & Creative Services
        ServiceItemOption(name: "Logo & Brand Identity", isSelected: false),
        ServiceItemOption(name: "Mobile App Development", isSelected: false),
        ServiceItemOption(name: "Website Maintenance", isSelected: false),
        ServiceItemOption(name: "UX/UI Design", isSelected: false),
        ServiceItemOption(name: "Video Editing & Montage", isSelected: false),
        ServiceItemOption(name: "Social Media Management", isSelected: false),
        
        // Education & Training
        ServiceItemOption(name: "Private Tutoring", isSelected: false),
        ServiceItemOption(name: "Exam Preparation", isSelected: false),
        ServiceItemOption(name: "Coding Lessons (Python/Swift)", isSelected: false),
        ServiceItemOption(name: "English Language Training", isSelected: false),
        ServiceItemOption(name: "CV & Resume Review", isSelected: false),
        ServiceItemOption(name: "Project Mentorship", isSelected: false)
    ]
    
    // MARK: - Inputs & Outputs
    
    // Input: Receives data from the previous screen to show what was already picked.
    var previouslySelectedItems: [String] = []
    
    // Output: A Closure (Callback) to send the final list back when "Done" is tapped.
    var onSelectionComplete: (([String]) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Services"
        
        // Pre-Selection Logic:
        // Iterate through the master list. If an item exists in 'previouslySelectedItems',
        // mark it as true so the checkmark appears.
        for i in 0..<items.count {
            if previouslySelectedItems.contains(items[i].name) {
                items[i].isSelected = true
            }
        }
        
        // Add "Done" button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // Configures the cell appearance based on the model state
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        
        // Visual Logic: If selected, show Checkmark and Blue Text. If not, show plain text.
        if item.isSelected {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .systemBlue
            cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = .systemFont(ofSize: 16)
        }
        
        return cell
    }
    
    // MARK: - Interaction Handling
    
    // Handles the toggle logic when a row is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1. Toggle the boolean state (true -> false, or false -> true)
        items[indexPath.row].isSelected.toggle()
        
        // 2. Reload only this specific row to update the checkmark UI immediately
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Actions
    
    @objc func doneTapped() {
        // Filter Logic: Create a new array containing ONLY the names of items where isSelected == true
        let selectedNames = items.filter { $0.isSelected }.map { $0.name }
        
        // Execute the closure to pass data back to the previous controller
        onSelectionComplete?(selectedNames)
        
        // Close the screen
        navigationController?.popViewController(animated: true)
    }
}
