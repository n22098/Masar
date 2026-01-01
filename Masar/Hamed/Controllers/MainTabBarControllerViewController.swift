import UIKit
import FirebaseAuth // 🔥 ضروري للتحقق من المستخدم الحقيقي

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. إعداد شكل الشريط
        setupTabBarAppearance()
        
        // 2. بناء التابات (بدون إنشاء مستخدم وهمي)
        setupTabs()
    }
    
    func setupTabs() {
        var controllers: [UIViewController] = []
        
        // ---------------------------------------------------------
        // 1. Search (دائماً موجود)
        // ---------------------------------------------------------
        let searchVC = createFromProviderStoryboard(
            id: "SearchTableViewController",
            title: "Search",
            icon: "magnifyingglass"
        )
        controllers.append(searchVC)
        
        // ---------------------------------------------------------
        // 2. History (دائماً موجود)
        // ---------------------------------------------------------
        let historyVC = createFromProviderStoryboard(
            id: "BookingHistoryTableViewController",
            title: "History",
            icon: "clock"
        )
        controllers.append(historyVC)
        
        // ---------------------------------------------------------
        // 3. Messages (دائماً موجود ويجلب من الفايربيس)
        // ---------------------------------------------------------
        let messagesVC = createMessagesViewController()
        controllers.append(messagesVC)
        
        // ---------------------------------------------------------
        // 4. Provider Hub (يظهر فقط إذا كان المستخدم مسجل دخول)
        // ---------------------------------------------------------
        // ملاحظة: يمكنك تعديل الشرط لاحقاً للتحقق من نوع المستخدم من الفايرستور
        if Auth.auth().currentUser != nil {
            let providerHubVC = createFromProviderStoryboard(
                id: "ProviderHubTableViewController",
                title: "Provider Hub",
                icon: "briefcase"
            )
            controllers.append(providerHubVC)
        }
        
        // ---------------------------------------------------------
        // 5. Profile (دائماً موجود)
        // ---------------------------------------------------------
        let profileVC = createFromProviderStoryboard(
            id: "ProfileTableViewController",
            title: "Profile",
            icon: "person"
        )
        controllers.append(profileVC)
        
        // تعيين التابات
        viewControllers = controllers
        
        // ألوان الشريط
        tabBar.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - Helper Methods
    
    private func createFromProviderStoryboard(id: String, title: String, icon: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Provider", bundle: nil)
        
        // نستخدم Instantiate العادي، تأكد أن الـ ID صحيح في الستوري بورد
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
        
        // ✅ التأكد من الاسم الصحيح: ConversationsViewController
        if let messagesVC = storyboard.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController {
            
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
        
        print("❌ Error: Could not find 'ConversationsViewController' in Provider.storyboard")
        return UIViewController() // يرجع شاشة فارغة بدلاً من الكراش
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
}
