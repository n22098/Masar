import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTestUser()
        
        setupTabBarAppearance()
        
        setupTabs()
    }
    
    func setupTabs() {
        // Verify that a user exists
        guard let user = UserManager.shared.currentUser else {
            createTestUser()
            setupTabs()
            return
        }
        
        var controllers: [UIViewController] = []
        
        // ---------------------------------------------------------
        // 1. Search
        // ---------------------------------------------------------
        let searchVC = createFromProviderStoryboard(
            id: "SearchTableViewController",
            title: "Search",
            icon: "magnifyingglass"
        )
        controllers.append(searchVC)
        
        // ---------------------------------------------------------
        // 2. History
        // ---------------------------------------------------------
        let historyVC = createFromProviderStoryboard(
            id: "BookingHistoryTableViewController",
            title: "History",
            icon: "clock"
        )
        controllers.append(historyVC)
        
        // ---------------------------------------------------------
        // 3. Messages
        // ---------------------------------------------------------
        let messagesVC = createMessagesViewController()
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
        
        viewControllers = controllers
        
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
    
    private func createMessagesViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        
        if let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessageProViewController") as? UIViewController {
            
            messagesVC.title = "Messages"
            let nav = UINavigationController(rootViewController: messagesVC)
            nav.navigationBar.prefersLargeTitles = true
            
            nav.tabBarItem = UITabBarItem(
                title: "Messages",
                image: UIImage(systemName: "message"),
                selectedImage: UIImage(systemName: "message.fill")
            )
            
            return nav
        }
        
        print("❌ Error: Could not find 'MessageProViewController' in Provider.storyboard")
        
        return createPlaceholderViewController(
            title: "Messages",
            icon: "message",
            selectedIcon: "message.fill"
        )
    }
    
    private func createPlaceholderViewController(title: String, icon: String, selectedIcon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = title
        
        let label = UILabel()
        label.text = "\(title)\n(Not Found)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        vc.view.addSubview(label)
        label.frame = vc.view.bounds
        
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        
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
            appearance.backgroundColor = .systemBackground
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
        
        let user = AppUser(
            name: "Hamed",
            email: "hamed@masar.com",
            phone: "33333333",
            providerProfile: providerProfile
        )
        
        UserManager.shared.setCurrentUser(user)
    }
}
