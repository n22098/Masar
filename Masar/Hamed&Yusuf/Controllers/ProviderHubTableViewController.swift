// ===================================================================================
// PROVIDER HUB VIEW CONTROLLER
// ===================================================================================
// PURPOSE: The main dashboard for Service Providers.
//
// KEY FEATURES:
// 1. Dashboard Metrics: Shows Total Bookings, Completed Jobs, and Response Time.
// 2. Navigation Hub: Central point to access Services, Bookings, and Portfolio.
// 3. Real-Time Data: Updates the dashboard instantly when new bookings arrive.
// 4. Custom UI: Programmatically builds the stats cards for a polished look.
// ===================================================================================

import UIKit

class ProviderHubTableViewController: UITableViewController {

    // MARK: - Outlets
    // Connections to the static cells in the Storyboard
    @IBOutlet weak var serviceCell: ActionItemCell!
    @IBOutlet weak var bookingCell: ActionItemCell!
    @IBOutlet weak var portfolioCell: ActionItemCell!

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Dashboard Data
    // Local variables to hold statistics fetched from Firestore
    var totalBookings: Int = 0
    var completedBookings: Int = 0
    var averageResponseTime: String = "0h"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupCellsData() // Configures the static cells
        setupDashboardHeader() // Draws the initial dashboard
        fetchDashboardData() // Starts fetching live data
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        // Refresh data every time the screen appears
        fetchDashboardData()
    }

    // MARK: - UI Setup
    func setupTableView() {
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }

    // Configure the static cells using our custom 'ActionItemCell' methods
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
    
    // MARK: - Dashboard Header
    // Programmatically creates and inserts the statistics view at the top of the table
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
    
    // MARK: - Data Fetching
    // Uses ServiceManager to get all bookings for THIS provider
    func fetchDashboardData() {
        ServiceManager.shared.fetchProviderBookings { [weak self] bookings in
            guard let self = self else { return }
            
            // Calculate metrics based on the fetched array
            self.totalBookings = bookings.count
            self.completedBookings = bookings.filter { $0.status == .completed }.count
            
            // Calculate logic for response time
            self.averageResponseTime = self.calculateAverageResponseTime(bookings: bookings)
            
            // Update the UI on main thread
            DispatchQueue.main.async {
                self.setupDashboardHeader()
            }
        }
    }
    
    // Mock logic for response time calculation (for demonstration)
    func calculateAverageResponseTime(bookings: [BookingModel]) -> String {
        if bookings.isEmpty { return "0h" }
        
        let recentBookings = bookings.filter { $0.status == .completed }
        if recentBookings.isEmpty { return "1h" }
        
        let avgHours = min(recentBookings.count, 2)
        return "\(avgHours)h"
    }
    
    // MARK: - TableView Configuration
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Standard height for action cells
    }
    
    // MARK: - Programmatic UI Components
    // Creates the white card containing the 3 stats
    func createDashboardView() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        // Shadow for depth
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 12
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Dashboard"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        // Horizontal Stack for Stats
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 8
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(statsStack)
        
        // 1. Total Bookings
        let totalBookingsStat = createStatView(
            title: "Total Bookings",
            value: "\(totalBookings)",
            color: brandColor
        )
        statsStack.addArrangedSubview(totalBookingsStat)
        
        // 2. Completed Jobs
        let completedStat = createStatView(
            title: "Completed",
            value: "\(completedBookings)",
            color: UIColor.systemGreen
        )
        statsStack.addArrangedSubview(completedStat)
        
        // 3. Response Time
        let responseTimeStat = createStatView(
            title: "Response Time",
            value: averageResponseTime,
            color: UIColor.systemOrange
        )
        statsStack.addArrangedSubview(responseTimeStat)
        
        // Auto Layout Constraints
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
    
    // Helper to create individual stat squares
    func createStatView(title: String, value: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1) // Light background
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
