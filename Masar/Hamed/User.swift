// ===================================================================================
// APP USER MODEL
// ===================================================================================
// PURPOSE: The central data structure representing a user in the application.
//
// KEY FEATURES:
// 1. Codable Support: Can be easily converted to/from JSON for Firebase and UserDefaults.
// 2. Role Management: Distinguishes between "Seekers" and "Providers".
// 3. Optional Association: Contains an optional 'ProviderProfile' linked to the user.
// ===================================================================================

import Foundation

struct AppUser: Codable {
    
    // MARK: - Properties
    let id: String              // Unique Identifier (Primary Key)
    var name: String
    var email: String
    var phone: String
    var role: String            // "seeker", "provider", or "admin"
    var profileImageName: String? // URL or Local Path to profile picture
    
    // Status Flag: Determines if the user is currently active as a seeker
    var isSeekerActive: Bool
    
    // Nested Object: Contains extra data specific to Service Providers.
    // This is Optional (?) because not all users are providers.
    var providerProfile: ProviderProfile?
    
    // MARK: - Computed Properties
    // Helper to quickly check user type without complex logic.
    // Returns TRUE if the user has a provider profile associated.
    var isProvider: Bool {
        return providerProfile != nil
    }
    
    // MARK: - Initializer
    // Custom init with default values allows for flexible object creation.
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         phone: String,
         role: String = "seeker",
         profileImageName: String? = nil,
         isSeekerActive: Bool = true,
         providerProfile: ProviderProfile? = nil) {
        
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.role = role
        self.profileImageName = profileImageName
        self.isSeekerActive = isSeekerActive
        self.providerProfile = providerProfile
    }
}
