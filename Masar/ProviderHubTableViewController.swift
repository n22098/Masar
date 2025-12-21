import UIKit

class ProviderHubTableViewController: UITableViewController {

    // MARK: - Outlets
    // اشبك هذه الثلاثة فقط (Drag & Drop)
    @IBOutlet weak var serviceCell: ActionItemCell!
    @IBOutlet weak var bookingCell: ActionItemCell!
    @IBOutlet weak var portfolioCell: ActionItemCell!

    override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigationBar()
            setupTableView()
            setupCellsData()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupNavigationBar()
        }

        func setupTableView() {
            // خلفية رمادية عشان تبرز البطاقات البيضاء
            tableView.backgroundColor = .systemGroupedBackground
            // إزالة الخطوط الفاصلة
            tableView.separatorStyle = .none
            // مسافة من الأعلى
            tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            
            // 🔥🔥 تكبير حجم الخلية (اجبارها تكون طويلة) 🔥🔥
            // جرب هذا الرقم، إذا حسيتها كبيرة مرة خله 90
            tableView.rowHeight = 90
        }

        func setupCellsData() {
            serviceCell.configure(title: "Service")
            bookingCell.configure(title: "Booking")
            portfolioCell.configure(title: "Portfolio")
        }

        func setupNavigationBar() {
            title = "Provider Hub"
            navigationController?.navigationBar.prefersLargeTitles = true
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
            
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.tintColor = .white
        }
    }
