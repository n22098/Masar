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
            id: "SearchTableViewController", // تأكد أن هذا الـ ID موجود في الستوري بورد
            title: "Search",
            icon: "magnifyingglass"
        )
        controllers.append(searchVC)
        
        // ---------------------------------------------------------
        // 2. History (من الستوري بورد)
        // ---------------------------------------------------------
        let historyVC = createFromProviderStoryboard(
            id: "BookingHistoryTableViewController", // تأكد أن هذا الـ ID موجود في الستوري بورد
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
        // 4. Provider Hub (التعديل الجديد والمهم هنا) 🛠️
        // ---------------------------------------------------------
        if user.isProvider {
            // الآن نقوم بتحميل الشاشة التي صممناها من الـ Storyboard
            // بدلاً من إنشائها بالكود
            let providerHubVC = createFromProviderStoryboard(
                id: "ProviderHubTableViewController", // ⚠️ مهم جداً: تأكد أنك وضعت هذا الاسم في الـ Identity Inspector
                title: "Provider Hub",
                icon: "briefcase"
            )
            controllers.append(providerHubVC)
        }
        
        // ---------------------------------------------------------
        // 5. Profile (شاشة مؤقتة)
        // ---------------------------------------------------------
        let profileVC = createPlaceholderViewController(
            title: "Profile",
            icon: "person",
            selectedIcon: "person.fill"
        )
        controllers.append(profileVC)
        
        // تعيين الكل في الشريط
        viewControllers = controllers
        
        // ألوان الشريط
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0) // اللون البنفسجي
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - Helper Methods
    
    // دالة لتحميل الشاشات من الـ Storyboard
    private func createFromProviderStoryboard(id: String, title: String, icon: String) -> UIViewController {
        
        // تأكد أن اسم ملف الستوري بورد هو "Provider" (أو "Main" حسب ملفك)
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        
        // تحميل الكنترولر باستخدام الـ ID
        // ملاحظة: إذا صار كراش هنا، يعني الـ ID في الكود لا يطابق الـ ID في الستوري بورد
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
    
    // دالة لإنشاء شاشات فارغة (مؤقتة)
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
        // بيانات تجريبية كاملة
        let providerProfile = ProviderProfile(
            role: .companyOwner,
            companyName: "Masar Company",
            services: [
                // 👇 التصليح هنا: الأسعار أرقام (20.0) وليست نصوص ("20")
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
