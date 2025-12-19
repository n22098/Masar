import Foundation

struct ServiceProviderModel {
    let id: String
    let name: String
    let role: String
    let imageName: String
    let rating: Double
    let skills: [String]
    let availability: String
    let location: String
    let phone: String
    
    // ✅ Add this
    var services: [ServiceModel]? // List of services this provider offers
}
