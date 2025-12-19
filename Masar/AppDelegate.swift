import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 🔥 حط كود الاختبار هنا
        createTestUser()
        
        return true
    }
    
    // MARK: - Test User Creation
    private func createTestUser() {
        // Test: Create provider user
        let testProvider = ProviderProfile(
            role: .companyOwner,
            companyName: "شركة الاختبار",
            services: []
        )
        
        let testUser = User(
            name: "أحمد",
            email: "test@test.com",
            phone: "12345678",
            providerProfile: testProvider // حط nil لو تبي Seeker
        )
        
        UserManager.shared.setCurrentUser(testUser)
        print("✅ Test user created!")
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Release resources
    }
}
