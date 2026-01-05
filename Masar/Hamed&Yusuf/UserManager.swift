// ===================================================================================
// USER MANAGER (SINGLETON)
// ===================================================================================
// PURPOSE: Manages the global state of the current user throughout the application.
//
// KEY FEATURES:
// 1. Singleton Pattern: Ensures only one instance exists to manage user data globally.
// 2. Data Persistence: Saves the user to UserDefaults so they remain logged in after app restart.
// 3. JSON Encoding/Decoding: Converts the complex User object to data for storage.
// 4. Role Management: Helper methods to quickly check if the user is a Provider.
// ===================================================================================

import Foundation

class UserManager {
    
    // MARK: - Singleton Setup
    // 'static let shared' creates the single shared instance of this class.
    static let shared = UserManager()
    
    // 'private init' prevents other parts of the app from creating new instances.
    private init() {}
    
    // MARK: - Properties
    // Holds the currently logged-in user data.
    // The 'didSet' observer automatically saves the user whenever this variable changes.
    private(set) var currentUser: AppUser? {
        didSet { saveCurrentUser() }
    }
    
    // MARK: - Session Management
    
    // Updates the current user (e.g., after Login or Profile Update)
    func setCurrentUser(_ user: AppUser) {
        self.currentUser = user
    }
    
    // Clears user data to log them out effectively
    func logout() {
        self.currentUser = nil
        // Remove data from local storage
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Data Persistence (UserDefaults)
    
    // Encodes the AppUser object into Data (JSON) to store it in UserDefaults.
    // This is necessary because UserDefaults can only store basic types (String, Int) by default.
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    // Decodes the Data back into an AppUser object when the app launches.
    // This restores the session so the user doesn't have to log in every time.
    func loadCurrentUser() {
        if let savedUser = UserDefaults.standard.data(forKey: "currentUser"),
           let decoded = try? JSONDecoder().decode(AppUser.self, from: savedUser) {
            self.currentUser = decoded
        }
    }
    
    // MARK: - Helper Methods
    
    // Checks if the logged-in user is a Service Provider
    func isCurrentUserProvider() -> Bool {
        return currentUser?.isProvider ?? false
    }
    
    // Retrieves the provider-specific profile details (if they exist)
    func getCurrentProviderProfile() -> ProviderProfile? {
        return currentUser?.providerProfile
    }
}
