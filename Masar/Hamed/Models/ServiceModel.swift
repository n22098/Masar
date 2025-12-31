import Foundation
import FirebaseFirestore

struct ServiceModel: Codable, Identifiable {
    
    // MARK: - Properties
    
    // 1. Document ID from Firebase
    @DocumentID var id: String?
    
    // 2. Core Data (Matches Firebase)
    var name: String
    var price: Double
    var description: String
    var category: String
    var providerName: String?
    
    // 🔥 NEW: Added providerId to link with profile
    var providerId: String?
    
    // 3. App Specific Data (Optional fields)
    var icon: String?
    var addOns: [String]?
    var deliveryTime: String?
    var features: [String]?
    var isActive: Bool?
    
    // MARK: - Computed Properties
    
    var formattedPrice: String {
        return String(format: "BHD %.3f", price)
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title" // Maps Firebase "title" to Swift "name"
        case price
        case description
        case category
        case providerName
        case providerId // 🔥 Make sure this matches the field name in Firestore (e.g., "uid" or "providerId")
        
        // Optional fields
        case icon
        case addOns
        case deliveryTime
        case features
        case isActive
    }
    
    // MARK: - Initializer
    
    init(id: String = UUID().uuidString,
         name: String,
         price: Double,
         description: String,
         category: String = "IT Solutions",
         providerName: String? = nil,
         providerId: String? = nil, // 🔥 Added to init
         icon: String? = "briefcase.fill",
         addOns: [String]? = nil,
         deliveryTime: String? = nil,
         features: [String]? = nil,
         isActive: Bool? = true) {
        
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.category = category
        self.providerName = providerName
        self.providerId = providerId // 🔥
        self.icon = icon
        self.addOns = addOns
        self.deliveryTime = deliveryTime
        self.features = features
        self.isActive = isActive
    }
}
