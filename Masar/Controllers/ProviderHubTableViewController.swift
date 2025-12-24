import UIKit

class ProviderHubTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var serviceCell: ActionItemCell!
    @IBOutlet weak var bookingCell: ActionItemCell!
    @IBOutlet weak var portfolioCell: ActionItemCell!

    // لون التطبيق (البنفسجي)
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

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
        // لون خلفية رمادي فاتح جداً ليبرز البطاقات البيضاء
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .none
        
        // مسافات من الأعلى والأسفل
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        
        // ارتفاع الخلية المناسب للتصميم الجديد
        tableView.rowHeight = 100
    }

    func setupCellsData() {
        // ✅ الآن هذا الكود سيعمل بدون أخطاء حمراء
        serviceCell.configure(title: "Services",
                            iconName: "briefcase.fill",
                            brandColor: brandColor)
        
        bookingCell.configure(title: "Bookings",
                            iconName: "calendar.badge.clock",
                            brandColor: brandColor)
        
        portfolioCell.configure(title: "Portfolio",
                              iconName: "photo.on.rectangle.angled",
                              brandColor: brandColor)
    }

    func setupNavigationBar() {
        title = "Provider Hub"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
}
