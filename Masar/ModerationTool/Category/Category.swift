import Foundation

struct Category: Codable {
    var name: String
    
    static func saveCategories(_ categories: [Category]) {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "saved_categories")
        }
    }
    
    static func loadCategories() -> [Category]? {
        if let data = UserDefaults.standard.data(forKey: "saved_categories"),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            return decoded
        }
        return nil
    }
}
