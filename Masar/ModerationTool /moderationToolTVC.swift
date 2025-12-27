import UIKit

class moderationToolTVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var categoryCell: ModerationCell!
    @IBOutlet weak var reportCell: ModerationCell!
    @IBOutlet weak var verificationCell: ModerationCell!
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCells()
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
    
    private func setupCells() {
        // نضبط النصوص ونخفي السهم الخارجي هنا 👇
        
        if let cell = categoryCell {
            cell.configure(title: "Category Management")
            cell.accessoryType = .none // إخفاء السهم الرمادي
        }
        
        if let cell = reportCell {
            cell.configure(title: "Report Management")
            cell.accessoryType = .none // إخفاء السهم الرمادي
        }
        
        if let cell = verificationCell {
            cell.configure(title: "Verification")
            cell.accessoryType = .none // إخفاء السهم الرمادي
        }
    }
    
    // لإلغاء التحديد عند العودة للصفحة
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
