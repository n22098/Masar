import Foundation

struct User: Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var profileImageName: String?
    
    // Every user is a seeker by default
    var isSeekerActive: Bool
    
    // Provider profile (optional - only if user is a provider)
    var providerProfile: ProviderProfile?
    
    // Computed property to check if user is a provider
    var isProvider: Bool {
        return providerProfile != nil
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String,
         phone: String,
         profileImageName: String? = nil,
         isSeekerActive: Bool = true,
         providerProfile: ProviderProfile? = nil) {
        
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.profileImageName = profileImageName
        self.isSeekerActive = isSeekerActive
        self.providerProfile = providerProfile
    }
    
    // Custom Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case profileImageName
        case isSeekerActive
        case providerProfile
    }
}
