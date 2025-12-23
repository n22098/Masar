import UIKit

// الموديل
struct ServiceItemOption {
    let name: String
    var isSelected: Bool
}

class ServiceItemsSelectionTableViewController: UITableViewController {

    // بيانات الخدمات
    var items: [ServiceItemOption] = [
        ServiceItemOption(name: "SEO Optimization", isSelected: false),
        ServiceItemOption(name: "1 Year Free Hosting", isSelected: false),
        ServiceItemOption(name: "Domain Name Registration", isSelected: false),
        ServiceItemOption(name: "Logo Design", isSelected: false),
        ServiceItemOption(name: "SSL Certificate", isSelected: false),
        ServiceItemOption(name: "Content Writing", isSelected: false),
        ServiceItemOption(name: "Social Media Integration", isSelected: false),
        ServiceItemOption(name: "3 Months Support", isSelected: false),
        ServiceItemOption(name: "Google Analytics Setup", isSelected: false)
    ]
    
    // ✅ متغير جديد لاستقبال الاختيارات السابقة
    var previouslySelectedItems: [String] = []
    
    var onSelectionComplete: (([String]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Add-ons"
        
        // ✅ الحل هنا: نقوم بتفعيل الـ checkbox للعناصر المختارة سابقاً
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
