import UIKit

// Define a simple structure for your data
struct VerificationItem {
    let title: String
    let subtitle: String
}

class VerificationVC: UITableViewController {

    // 1. Create your data array
    let data = [
        VerificationItem(title: "Identity Check", subtitle: "Verify your national ID"),
        VerificationItem(title: "Phone Number", subtitle: "Confirm your mobile +973 XXXX"),
        VerificationItem(title: "Email Address", subtitle: "Verify your work email")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Verification"
        
        // This removes empty cell lines at the bottom
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We only need one section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count // Returns the number of items in our array
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use the identifier "cell" that you set in Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "showVerificationCell", for: indexPath)

        let item = data[indexPath.row]

        // 2. Access labels using the Tags we set (1 and 2)
        if let titleLabel = cell.viewWithTag(1) as? UILabel {
            titleLabel.text = item.title
        }
        
        if let subtitleLabel = cell.viewWithTag(2) as? UILabel {
            subtitleLabel.text = item.subtitle
        }

        return cell
    }
    
    // Optional: Handle what happens when a user taps a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = data[indexPath.row]
        print("Selected: \(selectedItem.title)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
