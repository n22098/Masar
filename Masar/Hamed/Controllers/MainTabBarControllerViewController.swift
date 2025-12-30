import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. إنشاء مستخدم تجريبي لتفعيل وضع "مقدم الخدمة"
        createTestUser()
        
        // 2. إعداد شكل الشريط
        setupTabBarAppearance()
        
        // 3. بناء التابات
        setupTabs()
    }
    
    func setupTabs() {
        // التأكد من وجود مستخدم
        guard let user = UserManager.shared.currentUser else {
            createTestUser()
            setupTabs() // إعادة المحاولة بعد الإنشاء
            return
        }
        
        var controllers: [UIViewController] = []
        
        // ---------------------------------------------------------
        // 1. Search (من الستوري بورد)
        // ---------------------------------------------------------
        let searchVC = createFromProviderStoryboard(
            id: "SearchTableViewController",
            title: "Search",
            icon: "magnifyingglass"
        )
        controllers.append(searchVC)
        
        // ---------------------------------------------------------
        // 2. History (✅ FIXED - استخدام الشاشة الحقيقية)
        // ---------------------------------------------------------
        let historyVC = createFromProviderStoryboard(
            id: "BookingHistoryTableViewController",
            title: "History",
            icon: "clock"
        )
        controllers.append(historyVC)
        
        // ---------------------------------------------------------
        // 3. Messages (شاشة مؤقتة)
        // ---------------------------------------------------------
        let messagesVC = createPlaceholderViewController(
            title: "Messages",
            icon: "message",
            selectedIcon: "message.fill"
        )
        controllers.append(messagesVC)
        
        // ---------------------------------------------------------
        // 4. Provider Hub
        // ---------------------------------------------------------
        if user.isProvider {
            let providerHubVC = createFromProviderStoryboard(
                id: "ProviderHubTableViewController",
                title: "Provider Hub",
                icon: "briefcase"
            )
            controllers.append(providerHubVC)
        }
        
        // ---------------------------------------------------------
        // 5. Profile
        // ---------------------------------------------------------
        let profileVC = createFromProviderStoryboard(
            id: "ProfileTableViewController",
            title: "Profile",
            icon: "person"
        )
        controllers.append(profileVC)
        
        // تعيين الكل في الشريط
        viewControllers = controllers
        
        // ألوان الشريط
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - Helper Methods
    
    private func createFromProviderStoryboard(id: String, title: String, icon: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        
        vc.title = title
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        vc.navigationItem.largeTitleDisplayMode = .always
        
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            tag: 0
        )
        
        return nav
    }
    
    private func createPlaceholderViewController(title: String, icon: String, selectedIcon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.title = title
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        vc.navigationItem.largeTitleDisplayMode = .always
        
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: selectedIcon)
        )
        return nav
    }
    
    private func setupTabBarAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func createTestUser() {
        let providerProfile = ProviderProfile(
            role: .companyOwner,
            companyName: "Masar Company",
            services: [
                ServiceModel(name: "Home Cleaning", price: 20.0, description: "Deep cleaning"),
                ServiceModel(name: "AC Repair", price: 35.0, description: "Split unit maintenance")
            ],
            totalBookings: 45,
            completedBookings: 42,
            rating: 4.9,
            joinedDate: "2024-01-15"
        )
        
        let user = User(
            name: "Hamed",
            email: "hamed@masar.com",
            phone: "33333333",
            providerProfile: providerProfile
        )
        
        UserManager.shared.setCurrentUser(user)
    }
}
