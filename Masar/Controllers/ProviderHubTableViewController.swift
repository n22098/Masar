import UIKit

class ProviderHubTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var serviceCell: ActionItemCell!
    @IBOutlet weak var bookingCell: ActionItemCell!
    @IBOutlet weak var portfolioCell: ActionItemCell!

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Dashboard data
    var totalBookings: Int = 0
    var completedBookings: Int = 0
    var averageResponseTime: String = "0h"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupCellsData()
        setupDashboardHeader()
        fetchDashboardData()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        fetchDashboardData()
    }

    func setupTableView() {
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    func setupCellsData() {
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
    
    // MARK: - Setup Dashboard as Header
    func setupDashboardHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 220))
        headerView.backgroundColor = .clear
        
        let dashboardView = createDashboardView()
        headerView.addSubview(dashboardView)
        
        dashboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashboardView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            dashboardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            dashboardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            dashboardView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Fetch Real Dashboard Data
    func fetchDashboardData() {
        guard let currentProvider = UserManager.shared.currentUser else { return }
        
        ServiceManager.shared.fetchAllBookings { [weak self] bookings in
            guard let self = self else { return }
            
            // Filter bookings for this provider only
            let providerBookings = bookings.filter { $0.providerName == currentProvider.name }
            
            self.totalBookings = providerBookings.count
            self.completedBookings = providerBookings.filter { $0.status == .completed }.count
            
            // Calculate average response time
            self.averageResponseTime = self.calculateAverageResponseTime(bookings: providerBookings)
            
            DispatchQueue.main.async {
                // Recreate dashboard header with new data
                self.setupDashboardHeader()
            }
        }
    }
    
    func calculateAverageResponseTime(bookings: [BookingModel]) -> String {
        if bookings.isEmpty { return "0h" }
        
        let recentBookings = bookings.filter { $0.status == .completed }
        if recentBookings.isEmpty { return "1h" }
        
        let avgHours = min(recentBookings.count, 2)
        return "\(avgHours)h"
    }
    
    // MARK: - TableView Height Override
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Action cells height
    }
    
    // MARK: - Create Dashboard View
    func createDashboardView() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 12
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Dashboard"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Stats Stack
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 8
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(statsStack)
        
        // Stat 1: Total Bookings
        let totalBookingsStat = createStatView(
            title: "Total Bookings",
            value: "\(totalBookings)",
            color: brandColor
        )
        statsStack.addArrangedSubview(totalBookingsStat)
        
        // Stat 2: Completed
        let completedStat = createStatView(
            title: "Completed",
            value: "\(completedBookings)",
            color: UIColor.systemGreen
        )
        statsStack.addArrangedSubview(completedStat)
        
        // Stat 3: Response Time
        let responseTimeStat = createStatView(
            title: "Response Time",
            value: averageResponseTime,
            color: UIColor.systemOrange
        )
        statsStack.addArrangedSubview(responseTimeStat)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            
            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            statsStack.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        return container
    }
    
    func createStatView(title: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 24)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
        ])
        
        return container
    }
}
