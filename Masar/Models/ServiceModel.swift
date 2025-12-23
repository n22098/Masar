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
    
    // 3. App Specific Data (Optional fields)
    var icon: String?
    var addOns: [String]?
    var deliveryTime: String?
    var features: [String]?
    var isActive: Bool?
    
    // MARK: - Computed Properties
    
    // 4. Helper to display price as formatted string
    var formattedPrice: String {
        return String(format: "BHD %.3f", price)
    }
    
    // MARK: - Coding Keys
    
    // 5. Mapping Keys for Firebase
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title" // Maps Firebase "title" to Swift "name"
        case price
        case description
        case category
        case providerName
        
        // Optional fields
        case icon
        case addOns
        case deliveryTime
        case features
        case isActive
    }
    
    // MARK: - Initializer
    
    // 6. Manual Init for creating test data or new services
    init(id: String = UUID().uuidString,
         name: String,
         price: Double,
         description: String,
         category: String = "IT Solutions",
         providerName: String? = nil,
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
        self.icon = icon
        self.addOns = addOns
        self.deliveryTime = deliveryTime
        self.features = features
        self.isActive = isActive
    }
}
