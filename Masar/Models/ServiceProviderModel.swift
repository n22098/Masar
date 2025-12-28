import Foundation

// MARK: - Service Provider Model
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
    
    // Services
    var services: [ServiceModel]?
    
    // Portfolio data
    let aboutMe: String
    let portfolio: [PortfolioItem]
    let certifications: [Certification]
    let reviews: [ClientReview]
    let experience: String
    let completedProjects: Int
}

// MARK: - Portfolio Item
// (هذا هو الجزء الذي كان ناقصاً ويسبب الأخطاء)
struct PortfolioItem {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let technologies: [String]
    let completionDate: String
    let clientName: String?
    let projectLink: String?
}

// MARK: - Certification
struct Certification {
    let id: String
    let name: String
    let issuer: String
    let issueDate: String
    let expiryDate: String?
    let imageName: String?
    let credentialID: String?
}

// MARK: - Client Review
struct ClientReview {
    let id: String
    let clientName: String
    let clientImageName: String?
    let rating: Double
    let comment: String
    let date: String
    let serviceName: String
}
