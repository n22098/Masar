import Foundation

struct Category: Equatable, Codable {
    var Categoryid = UUID()
    var name: String
    var iconName: String // Useful for SF Symbols
    var colorHex: String // To store a representation of the category color
    
    // File Persistence Setup
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("plist")
    
    // Save Data
    static func saveCategories(_ categories: [Category]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedCategories = try? propertyListEncoder.encode(categories)
        try? codedCategories?.write(to: archiveURL, options: .noFileProtection)
    }
    
    // Load Data
    static func loadCategories() -> [Category]? {
        guard let codedCategories = try? Data(contentsOf: archiveURL) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Category>.self, from: codedCategories)
    }
    
    // Sample Data for UI Testing
    static func loadSampleCategories() -> [Category] {
        let cat1 = Category(name: "Work", iconName: "briefcase", colorHex: "#FF0000")
        let cat2 = Category(name: "Personal", iconName: "person", colorHex: "#00FF00")
        let cat3 = Category(name: "Shopping", iconName: "cart", colorHex: "#0000FF")
        
        return [cat1, cat2, cat3]
    }
    
    // Equatable Comparison
    static func ==(lhs: Category, rhs: Category) -> Bool {
        return lhs.Categoryid == rhs.Categoryid
    }
}
