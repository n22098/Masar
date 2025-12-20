import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        createTestUser()
        setupTabBarAppearance()
        setupTabs()
    }
    
    func setupTabs() {
        guard let user = UserManager.shared.currentUser else {
            createTestUser()
            return
        }
        
        var controllers: [UIViewController] = []
        
        // 1. Search
        let searchVC = createFromProviderStoryboard(
            "SearchTableViewController",
            title: "Search",
            icon: "magnifyingglass"
        )
        controllers.append(searchVC)
        
        // 2. History
        let historyVC = createFromProviderStoryboard(
            "BookingHistoryTableViewController",
            title: "History",
            icon: "clock"
        )
        controllers.append(historyVC)
        
        // 3. Messages
        let messagesVC = createPlaceholderViewController(
            title: "Messages",
            icon: "message",
            selectedIcon: "message.fill"
        )
        controllers.append(messagesVC)
        
        // 4. Services (Dashboard سابقا)
        if user.isProvider {
            let servicesVC = ProviderDashboardTableViewController()
            servicesVC.title = "Services"
            
            let navController = UINavigationController(rootViewController: servicesVC)
            navController.navigationBar.prefersLargeTitles = true
            servicesVC.navigationItem.largeTitleDisplayMode = .always
            
            navController.tabBarItem = UITabBarItem(
                title: "Services",
                image: UIImage(systemName: "briefcase"),
                selectedImage: UIImage(systemName: "briefcase.fill")
            )
            controllers.append(navController)
        }
        
        // 5. Profile
        let profileVC = createPlaceholderViewController(
            title: "Profile",
            icon: "person",
            selectedIcon: "person.fill"
        )
        controllers.append(profileVC)
        
        viewControllers = controllers
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - Helper Methods
    
    private func createFromProviderStoryboard(
        _ id: String,
        title: String,
        icon: String
    ) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Provider", bundle: nil) // تأكد أن الاسم Provider أو Main حسب ملفك
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        
        // هذا السطر مهم جداً لإظهار العنوان بعد حذف الهيدر البنفسجي
        vc.title = title
        
        let nav = UINavigationController(rootViewController: vc)
        
        // تفعيل العنوان الكبير (يسار)
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
        // ... (نفس كود المستخدم السابق) ...
        let providerProfile = ProviderProfile(
             role: .companyOwner,
             companyName: "Masar Company",
             services: [ServiceModel(name: "Service 1", price: "100", description: "Desc")],
             totalBookings: 45,
             completedBookings: 42,
             rating: 4.9,
             joinedDate: "2024-01-15"
         )
         
         let user = User(
             name: "Ahmed",
             email: "ahmed@test.com",
             phone: "12345678",
             providerProfile: providerProfile
         )
         
         UserManager.shared.setCurrentUser(user)
    }
}
