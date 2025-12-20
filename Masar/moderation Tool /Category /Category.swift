import Foundation

struct Category: Equatable, Codable {
    var id = UUID()
    var name: String
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("plist")
    
    static func saveCategories(_ categories: [Category]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedCategories = try? propertyListEncoder.encode(categories)
        try? codedCategories?.write(to: archiveURL, options: .noFileProtection)
    }
    
    static func loadCategories() -> [Category]? {
        guard let codedCategories = try? Data(contentsOf: archiveURL) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Category>.self, from: codedCategories)
    }
    
    static func loadSampleCategories() -> [Category] {
        return [Category(name: "Work"), Category(name: "Personal")]
    }
    
    static func ==(lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
