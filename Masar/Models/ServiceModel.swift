import Foundation

struct ServiceModel {
    var id: String
    var name: String
    var price: String
    var description: String
    var icon: String
    
    // Properties needed for the controller
    var deliveryTime: String
    var features: [String]
    
    // Existing properties
    var category: String
    var isActive: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         price: String,
         description: String,
         icon: String = "briefcase.fill",
         deliveryTime: String = "TBD",
         features: [String] = [],
         category: String = "IT Solutions",
         isActive: Bool = true) {
        
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.icon = icon
        self.deliveryTime = deliveryTime
        self.features = features
        self.category = category
        self.isActive = isActive
    }
}
