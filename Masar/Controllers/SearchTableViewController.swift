import UIKit

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    private lazy var categorySegment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["IT Solutions", "Teaching", "Digital Services"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    var allProviders: [ServiceProviderModel] = [
        ServiceProviderModel(
            id: "1",
            name: "Sayed Husain",
            role: "Software Engineer",
            imageName: "it1",
            rating: 4.9,
            skills: ["HTML", "CSS", "JS", "PHP", "MySQL"],
            availability: "Sat-Thu",
            location: "Online",
            phone: "36666222"
        ),
        ServiceProviderModel(
            id: "2",
            name: "Joe Dean",
            role: "Network Technician",
            imageName: "it2",
            rating: 4.5,
            skills: ["Networking", "Security"],
            availability: "Sun-Thu",
            location: "Manama",
            phone: "33333333"
        ),
        ServiceProviderModel(
            id: "3",
            name: "Amin Altajer",
            role: "Computer Repair",
            imageName: "it3",
            rating: 4.8,
            skills: ["Hardware", "Software"],
            availability: "Daily",
            location: "Riffa",
            phone: "39999999"
        ),
        ServiceProviderModel(
            id: "4",
            name: "Kashmala Saleem",
            role: "Math Teacher",
            imageName: "t1",
            rating: 5.0,
            skills: ["Math", "Physics"],
            availability: "Weekends",
            location: "Online",
            phone: "34444444"
        ),
        ServiceProviderModel(
            id: "5",
            name: "Osama Hasan",
            role: "UI/UX Designer",
            imageName: "d1",
            rating: 4.6,
            skills: ["Figma", "Adobe XD"],
            availability: "Flexible",
            location: "Online",
            phone: "37777777"
        ),
        ServiceProviderModel(
            id: "6",
            name: "Vishal Santhosh",
            role: "Content Creator",
            imageName: "d3",
            rating: 4.8,
            skills: ["Video Editing", "Photography"],
            availability: "Mon-Sat",
            location: "Muharraq",
            phone: "38888888"
        )
    ]
    
    private var filteredProviders: [ServiceProviderModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        // إضافة الـ Segment Control
        tableView.tableHeaderView = createHeaderView()
        
        // عرض كل المزودين في البداية
        filteredProviders = allProviders
    }
    
    // MARK: - Setup
    private func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        headerView.backgroundColor = .systemBackground
        
        categorySegment.frame = CGRect(x: 16, y: 10, width: view.frame.width - 32, height: 40)
        headerView.addSubview(categorySegment)
        
        return headerView
    }
    
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let selectedCategory = sender.selectedSegmentIndex
        
        switch selectedCategory {
        case 0: // IT Solutions
            filteredProviders = allProviders.filter { $0.role.contains("Engineer") || $0.role.contains("Technician") || $0.role.contains("Repair") }
        case 1: // Teaching
            filteredProviders = allProviders.filter { $0.role.contains("Teacher") }
        case 2: // Digital Services
            filteredProviders = allProviders.filter { $0.role.contains("Designer") || $0.role.contains("Creator") }
        default:
            filteredProviders = allProviders
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProviders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath)
        
        let provider = filteredProviders[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = provider.name
        cell.detailTextLabel?.text = "\(provider.role) - ⭐️ \(provider.rating)"
        
        if let image = UIImage(named: provider.imageName) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        }
        
        cell.imageView?.layer.cornerRadius = 25
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProvider = filteredProviders[indexPath.row]
        performSegue(withIdentifier: "showServiceItem", sender: selectedProvider)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showServiceItem" {
            if let destVC = segue.destination as? ServiceItemTableViewController,
               let provider = sender as? ServiceProviderModel {
                destVC.providerData = provider
            }
        }
    }
}
