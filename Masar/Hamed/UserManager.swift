import Foundation

class UserManager {
    static let shared = UserManager()
    private init() {}
    
    // استخدام AppUser
    private(set) var currentUser: AppUser? {
        didSet { saveCurrentUser() }
    }
    
    func setCurrentUser(_ user: AppUser) {
        self.currentUser = user
    }
    
    func logout() {
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    func loadCurrentUser() {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decoded = try? JSONDecoder().decode(AppUser.self, from: savedUser) {
            self.currentUser = decoded
        }
    }
    
    func isCurrentUserProvider() -> Bool {
        return currentUser?.isProvider ?? false
    }
    
    func getCurrentProviderProfile() -> ProviderProfile? {
        return currentUser?.providerProfile
    }
}
