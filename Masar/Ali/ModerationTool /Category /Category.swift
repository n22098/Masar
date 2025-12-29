//
//  Category.swift
//  Masar
//
//  Created by BP-36-213-19 on 28/12/2025.
//
import Foundation

struct Category: Codable {
    let name: String
    let iconName: String? // Optional: if you want to show an icon
    
    // MARK: - Persistence Logic
    
    // This matches the call you have in your SeekerView
    static func loadCategories() -> [Category]? {
        // Example using UserDefaults (common for simple apps)
        if let data = UserDefaults.standard.data(forKey: "SavedCategories") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Category].self, from: data) {
                return decoded
            }
        }
        
        // Return some default categories if nothing is saved yet
        return [
            Category(name: "All", iconName: nil),
            Category(name: "Reports", iconName: nil),
            Category(name: "Verification", iconName: nil)
        ]
    }
    
    static func saveCategories(_ categories: [Category]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "SavedCategories")
        }
    }
}
