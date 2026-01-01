import Foundation

struct AppUser: Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var role: String
    var profileImageName: String?
    
    // هل هو باحث نشط؟
    var isSeekerActive: Bool
    // بروفايل مقدم الخدمة (اختياري)
    var providerProfile: ProviderProfile?
    
    var isProvider: Bool {
        return providerProfile != nil
    }
    
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
