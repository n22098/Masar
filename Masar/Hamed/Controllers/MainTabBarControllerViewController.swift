import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. إنشاء مستخدم تجريبي (لأغراض الاختبار)
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
        // 3. Messages (✅ تم التعديل حسب الصورة: MessageProViewController)
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
        
        // تعيين الكل في الشريط
        viewControllers = controllers
        
        // ألوان الشريط
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - Helper Methods
    
    // ✅ تم إصلاح هذه الدالة لإزالة التحذير الأصفر
    private func createFromProviderStoryboard(id: String, title: String, icon: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        
        // نستخدم الطريقة القياسية المباشرة لتجنب التحذيرات
        // ملاحظة: تأكد أن الـ ID موجود في الستوري بورد وإلا سيتوقف التطبيق (Crash)
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
    
    // ✅ تم وضع الاسم الصحيح MessageProViewController
    private func createMessagesViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        
        // استخدام الاسم كما ظهر في لقطة الشاشة
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
        
        // في حال لم يجد الاسم، يطبع خطأ وينشئ شاشة مؤقتة
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
        
        let user = User(
            name: "Hamed",
            email: "hamed@masar.com",
            phone: "33333333",
            providerProfile: providerProfile
        )
        
        UserManager.shared.setCurrentUser(user)
    }
}
