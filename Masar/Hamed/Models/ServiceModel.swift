import Foundation
import FirebaseFirestore

struct ServiceModel: Codable, Identifiable {
    
    // MARK: - Properties
    
    // تم الإبقاء عليه كما هو، وسيتم تعبئته تلقائياً من Firestore
    @DocumentID var id: String?
    
    var name: String
    var price: Double
    var description: String
    var category: String
    var providerName: String?
    var providerId: String?
    
    var icon: String?
    var addOns: [String]?
    var deliveryTime: String?
    var features: [String]?
    var isActive: Bool?
    
    var formattedPrice: String {
        return String(format: "BHD %.3f", price)
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        // حذفت الـ id من هنا لأنه @DocumentID
        case name = "title"
        case price
        case description
        case category
        case providerName
        case providerId
        case icon
        case addOns
        case deliveryTime
        case features
        case isActive
    }
    
    // MARK: - Initializer
    init(name: String,
         price: Double,
         description: String,
         category: String = "",
         providerName: String? = nil,
         providerId: String? = nil,
         icon: String? = "briefcase.fill",
         addOns: [String]? = nil,
         deliveryTime: String? = nil,
         features: [String]? = nil,
         isActive: Bool? = true) {
        
        // لا نحتاج لتعيين id يدوياً هنا
        self.name = name
        self.price = price
        self.description = description
        self.category = category
        self.providerName = providerName
        self.providerId = providerId
        self.icon = icon
        self.addOns = addOns
        self.deliveryTime = deliveryTime
        self.features = features
        self.isActive = isActive
    }
}
