import Foundation

class UserManager {
    
    static let shared = UserManager()
    
    // Singleton pattern
    private init() {}
    
    // Current logged in user
    private(set) var currentUser: User? {
        didSet {
            // Save to UserDefaults when user changes
            saveCurrentUser()
        }
    }
    
    // MARK: - User Management
    
    func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    func logout() {
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Provider Check
    
    func isCurrentUserProvider() -> Bool {
        return currentUser?.isProvider ?? false
    }
    
    func getCurrentProviderProfile() -> ProviderProfile? {
        return currentUser?.providerProfile
    }
    
    // MARK: - Persistence (Simple UserDefaults storage)
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    func loadCurrentUser() {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decoded = try? JSONDecoder().decode(User.self, from: savedUser) {
            self.currentUser = decoded
        }
    }
}
