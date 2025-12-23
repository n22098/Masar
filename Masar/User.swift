import Foundation

struct User {
    let id: String
    var name: String
    var username: String
    var email: String
    var phone: String
    let avatarEmoji: String
    var profileImageName: String?
    var isSeekerActive: Bool
    var providerProfile: ProviderProfile?

    var isProvider: Bool {
        providerProfile != nil
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        username: String,
        email: String,
        phone: String,
        avatarEmoji: String,
        profileImageName: String? = nil,
        isSeekerActive: Bool = true,
        providerProfile: ProviderProfile? = nil
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.phone = phone
        self.avatarEmoji = avatarEmoji
        self.profileImageName = profileImageName
        self.isSeekerActive = isSeekerActive
        self.providerProfile = providerProfile
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
        case phone
        case avatarEmoji
        case profileImageName
        case isSeekerActive
        case providerProfile
    }
}
