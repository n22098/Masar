// ============================================
// File: Controllers/MainTabBarController.swift
// ============================================
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create test user for testing
        createTestUser()
        
        setupTabBarAppearance()
        setupTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabs()
    }
    
    // MARK: - Setup Tabs
    
    func setupTabs() {
        guard let user = UserManager.shared.currentUser else {
            print("⚠️ No current user found - creating test seeker")
            createTestUser()
            return
        }
        
        var controllers: [UIViewController] = []
        
        // ===================================
        // TAB 1: Search - للجميع
        // ===================================
        if let searchVC = createTableViewController(
            storyboardID: "SearchTableViewController",
            title: "Search",
            icon: "magnifyingglass",
            selectedIcon: "magnifyingglass"
        ) {
            controllers.append(searchVC)
        }
        
        // ===================================
        // TAB 2: Bookings - للجميع
        // ===================================
        if let bookingsVC = createTableViewController(
            storyboardID: "BookingHistoryTableViewController",
            title: "History",
            icon: "clock",
            selectedIcon: "clock.fill"
        ) {
            controllers.append(bookingsVC)
        }
        
        // ===================================
        // TAB 3: Messages - للجميع
        // ===================================
        if let messagesVC = createViewController(
            storyboardID: "MessageViewController",
            title: "Messages",
            icon: "message",
            selectedIcon: "message.fill"
        ) {
            controllers.append(messagesVC)
        }
        
        // ===================================
        // TAB 4: Service (أي صفحة service عندك)
        // ===================================
        if let serviceVC = createTableViewController(
            storyboardID: "ServiceItemTableViewController",
            title: "Service",
            icon: "bag",
            selectedIcon: "bag.fill"
        ) {
            controllers.append(serviceVC)
        }
        
        // ===================================
        // TAB 5: Profile - للجميع
        // ===================================
        if let profileVC = createViewController(
            storyboardID: "ProfileViewController",
            title: "Profile",
            icon: "person",
            selectedIcon: "person.fill"
        ) {
            controllers.append(profileVC)
        }
        
        // ===================================
        // TAB 6: Provider Dashboard - للـ Providers فقط! 🔥
        // ===================================
        if user.isProvider {
            if let dashboardVC = createTableViewController(
                storyboardID: "ProviderDashboardTableViewController",
                title: "Dashboard",
                icon: "briefcase",
                selectedIcon: "briefcase.fill"
            ) {
                controllers.append(dashboardVC)
                print("✅ Provider Dashboard tab added!")
                print("✅ User role: \(user.providerProfile?.role.displayName ?? "")")
            }
        } else {
            print("ℹ️ User is Seeker only - no Dashboard tab")
        }
        
        // Set all tabs
        viewControllers = controllers
        
        // Style
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
        
        print("✅ Tabs setup complete. Total tabs: \(controllers.count)")
    }
    
    // MARK: - Helper Methods
    
    /// For regular View Controllers
    private func createViewController(
        storyboardID: String,
        title: String,
        icon: String,
        selectedIcon: String
    ) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: storyboardID
        ) as? UIViewController else {
            print("⚠️ Could not find \(storyboardID) in storyboard")
            return nil
        }
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: selectedIcon)
        )
        
        return navController
    }
    
    /// For Table View Controllers
    private func createTableViewController(
        storyboardID: String,
        title: String,
        icon: String,
        selectedIcon: String
    ) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tableViewController = storyboard.instantiateViewController(
            withIdentifier: storyboardID
        ) as? UITableViewController else {
            print("⚠️ Could not find \(storyboardID) in storyboard")
            return nil
        }
        
        let navController = UINavigationController(rootViewController: tableViewController)
        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: selectedIcon)
        )
        
        return navController
    }
    
    // MARK: - Tab Bar Appearance
    
    private func setupTabBarAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = .white
            tabBar.backgroundColor = .white
        }
        
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 8
    }
    
    // MARK: - Test User Creation
    
    private func createTestUser() {
        // للاختبار: غير هذا الفلاق حسب اللي تبي تختبره
        let testAsProvider = true // true = provider, false = seeker
        
        if testAsProvider {
            // Create Provider User
            let providerProfile = ProviderProfile(
                role: .companyOwner, // جرب: .employee أو .departmentHead
                companyName: "شركة مسار للحلول التقنية",
                services: [
                    ServiceModel(
                        name: "تطوير تطبيقات iOS",
                        price: "500 BHD",
                        description: "تطوير تطبيقات احترافية",
                        deliveryTime: "14 يوم"
                    )
                ],
                totalBookings: 45,
                completedBookings: 42,
                rating: 4.9,
                joinedDate: "2024-01-15"
            )
            
            let user = User(
                name: "أحمد المنصوري",
                email: "ahmed@masar.com",
                phone: "+973 3344 5566",
                providerProfile: providerProfile
            )
            
            UserManager.shared.setCurrentUser(user)
            print("✅ Test Provider user created")
            
        } else {
            // Create Seeker User
            let user = User(
                name: "فاطمة علي",
                email: "fatima@email.com",
                phone: "+973 1122 3344"
            )
            
            UserManager.shared.setCurrentUser(user)
            print("✅ Test Seeker user created")
        }
    }
}

// ============================================
// EXTENSION: Refresh Tabs
// ============================================
extension MainTabBarController {
    
    func refreshTabs() {
        setupTabs()
        
        if UserManager.shared.isCurrentUserProvider() {
            selectedIndex = (viewControllers?.count ?? 1) - 1
        }
    }
    
    func switchToProviderDashboard() {
        guard UserManager.shared.isCurrentUserProvider() else { return }
        selectedIndex = (viewControllers?.count ?? 1) - 1
    }
}
