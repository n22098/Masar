import UIKit

class ProviderDashboardTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var currentUser: User?
    private var menuItems: [DashboardMenuItem] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // 👇 التعديل هنا: غيرنا العنوان إلى Services
            title = "Services"
            
            setupUI()
            loadUserData()
            setupMenuItems()
        }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // تسجيل الخلايا
        tableView.register(DashboardHeaderCell.self, forCellReuseIdentifier: "HeaderCell")
        tableView.register(DashboardMenuCell.self, forCellReuseIdentifier: "MenuCell")
    }
    
    private func loadUserData() {
        currentUser = UserManager.shared.currentUser
    }
    
    // MARK: - Menu Setup
    
    private func setupMenuItems() {
        guard let provider = currentUser?.providerProfile else { return }
        
        menuItems = [
            // 1. My Services
            DashboardMenuItem(
                icon: "briefcase.fill",
                title: "My Services",
                subtitle: "\(provider.services.count) services",
                color: UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0),
                action: { [weak self] in self?.showMyServices() }
            ),
            
            // 2. My Bookings
            DashboardMenuItem(
                icon: "calendar.badge.clock",
                title: "My Bookings",
                subtitle: "View bookings",
                color: .systemOrange,
                action: { [weak self] in self?.showMyBookings() }
            ),
            
            // 3. Provider Profile
            DashboardMenuItem(
                icon: "person.circle.fill",
                title: "Provider Profile",
                subtitle: "Edit profile",
                color: .systemPurple,
                action: { [weak self] in self?.showAlert("Coming Soon", "Profile editing coming soon") }
            )
        ]
        
        // ❌ تم حذف خيار Manage Team من هنا بناءً على طلبك
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 } // Header
        return menuItems.count // Menu Items
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // خلية الهيدر (المعلومات الشخصية)
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! DashboardHeaderCell
            if let user = currentUser, let provider = user.providerProfile {
                cell.configure(
                    name: user.name,
                    role: provider.role.displayName,
                    company: "Masar Company", // ✅ تم التعديل هنا لتظهر Masar Company دائماً
                    rating: provider.rating,
                    totalBookings: provider.totalBookings
                )
            }
            return cell
        } else {
            // خلية القائمة
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! DashboardMenuCell
            cell.configure(with: menuItems[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 180 }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            menuItems[indexPath.row].action()
        }
    }
    
    // MARK: - Navigation Actions
    
    private func showMyServices() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // استخدام الاسم الصحيح للملف الذي أنشأته
        if let vc = storyboard.instantiateViewController(withIdentifier: "MyServicesViewController") as? ProviderServicesTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert("Error", "Could not find MyServicesViewController in Storyboard")
        }
    }
    
    private func showMyBookings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = try? storyboard.instantiateViewController(withIdentifier: "BookingHistoryTableViewController") {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert("Error", "Booking History not found in storyboard")
        }
    }
    
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
