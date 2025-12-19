import UIKit

class ProviderDashboardTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var currentUser: User?
    private var menuItems: [DashboardMenuItem] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Provider Dashboard"
        setupUI()
        loadUserData()
        setupMenuItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when returning to dashboard
        loadUserData()
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Table View Style
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Register cells
        tableView.register(DashboardHeaderCell.self, forCellReuseIdentifier: "HeaderCell")
        tableView.register(DashboardMenuCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    private func loadUserData() {
        currentUser = UserManager.shared.currentUser
        
        guard let user = currentUser, user.isProvider else {
            showAlert(title: "Error", message: "No provider profile found")
            return
        }
    }
    
    private func setupMenuItems() {
        guard let user = currentUser,
              let provider = user.providerProfile else { return }
        
        menuItems = []
        
        // Common items for all providers
        menuItems.append(DashboardMenuItem(
            icon: "briefcase.fill",
            title: "My Services",
            subtitle: "\(provider.services.count) services",
            color: UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0),
            action: { [weak self] in self?.showMyServices() }
        ))
        
        menuItems.append(DashboardMenuItem(
            icon: "calendar.badge.clock",
            title: "Incoming Bookings",
            subtitle: "View pending requests",
            color: UIColor.systemOrange,
            action: { [weak self] in self?.showIncomingBookings() }
        ))
        
        menuItems.append(DashboardMenuItem(
            icon: "chart.bar.fill",
            title: "My Reports",
            subtitle: "View statistics",
            color: UIColor.systemGreen,
            action: { [weak self] in self?.showReports() }
        ))
        
        // Role-specific items
        switch provider.role {
        case .companyOwner:
            menuItems.append(DashboardMenuItem(
                icon: "person.3.fill",
                title: "Manage Team",
                subtitle: "Add/remove employees",
                color: UIColor.systemPurple,
                action: { [weak self] in self?.showTeamManagement() }
            ))
            
            menuItems.append(DashboardMenuItem(
                icon: "building.2.fill",
                title: "Company Settings",
                subtitle: "Manage company",
                color: UIColor.systemBlue,
                action: { [weak self] in self?.showCompanySettings() }
            ))
            
        case .departmentHead:
            menuItems.append(DashboardMenuItem(
                icon: "list.clipboard.fill",
                title: "Assign Tasks",
                subtitle: "Delegate work to team",
                color: UIColor.systemIndigo,
                action: { [weak self] in self?.showTaskAssignment() }
            ))
            
            menuItems.append(DashboardMenuItem(
                icon: "person.2.fill",
                title: "My Team",
                subtitle: "View team members",
                color: UIColor.systemTeal,
                action: { [weak self] in self?.showTeamView() }
            ))
            
        case .employee:
            menuItems.append(DashboardMenuItem(
                icon: "checkmark.circle.fill",
                title: "My Tasks",
                subtitle: "View assigned tasks",
                color: UIColor.systemYellow,
                action: { [weak self] in self?.showMyTasks() }
            ))
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Header + Menu
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Header cell
        }
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Header Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! DashboardHeaderCell
            
            if let user = currentUser,
               let provider = user.providerProfile {
                cell.configure(
                    name: user.name,
                    role: provider.role.displayName,
                    company: provider.companyName,
                    rating: provider.rating,
                    totalBookings: provider.totalBookings
                )
            }
            
            return cell
        } else {
            // Menu Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! DashboardMenuCell
            let item = menuItems[indexPath.row]
            cell.configure(with: item)
            return cell
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180 // Header height
        }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let item = menuItems[indexPath.row]
            item.action()
        }
    }
    
    // MARK: - Navigation
    
    private func showMyServices() {
        let vc = MyServicesTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showIncomingBookings() {
        let vc = IncomingBookingsTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showReports() {
        let vc = ProviderReportsTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showTeamManagement() {
        let vc = TeamManagementTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showCompanySettings() {
        showAlert(title: "Coming Soon", message: "Company settings will be available soon")
    }
    
    private func showTaskAssignment() {
        showAlert(title: "Coming Soon", message: "Task assignment will be available soon")
    }
    
    private func showTeamView() {
        showAlert(title: "Coming Soon", message: "Team view will be available soon")
    }
    
    private func showMyTasks() {
        showAlert(title: "Coming Soon", message: "My tasks will be available soon")
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
