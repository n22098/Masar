import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // 1. Create local test user
        createTestUser()
        
        // 2. 🔥 Test fetching data from Firebase console
        testFirebaseFetch()
        
        return true
    }
    
    // MARK: - Firebase Fetch Test
    private func testFirebaseFetch() {
        print("\n⏳ Starting Firebase connection test...")
        
        ServiceManager.shared.fetchAllServices { services in
            print("\n----- 📡 FIREBASE DATA RESULT -----")
            
            if services.isEmpty {
                print("⚠️ No services found! Check your Firestore collection name.")
            } else {
                print("✅ Connection Successful! Found \(services.count) services:")
                for service in services {
                    // We use 'service.name' because we mapped it to 'title' in ServiceModel
                    print("🔹 Service: \(service.name)")
                    print("💰 Price: \(service.formattedPrice)")
                    print("-----------------------------")
                }
            }
            print("-----------------------------------\n")
        }
    }
    
    // MARK: - Test User Creation
    private func createTestUser() {
        // Test: Create provider user
        let testProvider = ProviderProfile(
            role: .companyOwner,
            companyName: "Test Company",
            services: []
        )
        
        let testUser = User(
            name: "Ahmed",
            email: "test@test.com",
            phone: "12345678",
            providerProfile: testProvider
        )
        
        UserManager.shared.setCurrentUser(testUser)
        print("✅ Local test user created!")
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Release resources
    }
}
