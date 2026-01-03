import UIKit

// The Model
struct ServiceItemOption {
    let name: String
    var isSelected: Bool
}

class ServiceItemsSelectionTableViewController: UITableViewController {

    // ✅ UPDATED: Organized "Master Catalog" of Services
    // هذه القائمة تمثل "Tags" يمكن للمزود اختيارها لتحديد تفاصيل خدمته بدقة
    var items: [ServiceItemOption] = [
        
        //MARK: - General Add-ons (تنفع للكل)
        ServiceItemOption(name: "Online Consultation", isSelected: false), // استشارة أونلاين
        ServiceItemOption(name: "Urgent Service (Priority)", isSelected: false), // خدمة مستعجلة
        ServiceItemOption(name: "Home Visit", isSelected: false), // زيارة منزلية
        
        //MARK: - IT & Technical Support
        ServiceItemOption(name: "PC & Laptop Repair", isSelected: false),
        ServiceItemOption(name: "Virus & Malware Removal", isSelected: false),
        ServiceItemOption(name: "Data Recovery", isSelected: false),
        ServiceItemOption(name: "Wi-Fi & Network Setup", isSelected: false),
        ServiceItemOption(name: "Software Installation", isSelected: false),
        ServiceItemOption(name: "Custom PC Building", isSelected: false),
        
        //MARK: - Digital & Creative Services
        ServiceItemOption(name: "Logo & Brand Identity", isSelected: false),
        ServiceItemOption(name: "Mobile App Development", isSelected: false),
        ServiceItemOption(name: "Website Maintenance", isSelected: false),
        ServiceItemOption(name: "UX/UI Design", isSelected: false),
        ServiceItemOption(name: "Video Editing & Montage", isSelected: false),
        ServiceItemOption(name: "Social Media Management", isSelected: false),
        
        //MARK: - Education & Training
        ServiceItemOption(name: "Private Tutoring", isSelected: false),
        ServiceItemOption(name: "Exam Preparation", isSelected: false),
        ServiceItemOption(name: "Coding Lessons (Python/Swift)", isSelected: false),
        ServiceItemOption(name: "English Language Training", isSelected: false),
        ServiceItemOption(name: "CV & Resume Review", isSelected: false),
        ServiceItemOption(name: "Project Mentorship", isSelected: false)
    ]
    
    // Variable to receive previously selected items
    var previouslySelectedItems: [String] = []
    
    var onSelectionComplete: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Services"
        
        // Logic to check previously selected items
        for i in 0..<items.count {
            if previouslySelectedItems.contains(items[i].name) {
                items[i].isSelected = true
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func doneTapped() {
        let selectedNames = items.filter { $0.isSelected }.map { $0.name }
        onSelectionComplete?(selectedNames)
        navigationController?.popViewController(animated: true)
    }
    
}
