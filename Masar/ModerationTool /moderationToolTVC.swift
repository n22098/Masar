import UIKit

class moderationToolTVC: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // DO NOT call setupCells() here anymore.
    }
    
    // MARK: - Setup
    private func setupUI() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.title = "Moderations Tool"
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
    }
    
    // MARK: - Table View Delegate
    
    // This is the safest place to configure Static Cells.
    // It runs right before the cell is drawn on the screen.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Use optional casting (as?) to safely check the cell type
        if let category = cell as? Categorycell {
            category.configure(title: "Category Management")
            category.accessoryType = .none
        }
        else if let report = cell as? reportCell {
            report.configure(title: "Report Management")
            report.accessoryType = .none
        }
        else if let verification = cell as? verificationCell {
            verification.configure(title: "Verification")
            verification.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
