import Foundation
import FirebaseFirestore

struct Provider {
    var id: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var category: String
    var status: String
    var imageName: String
    var roleType: String

    // 1. Standard Initializer (for creating objects in code)
    init(id: String = UUID().uuidString,
         fullName: String,
         email: String,
         phone: String,
         username: String,
         category: String,
         status: String = "Active",
         imageName: String = "default_profile",
         roleType: String = "Provider") {
        
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.username = username
        self.category = category
        self.status = status
        self.imageName = imageName
        self.roleType = roleType
    }

    // 2. Firebase Initializer (Maps Firebase keys to your code)
    init?(id: String, dictionary: [String: Any]) {
        // Updated to match your Firebase screenshot: "name" instead of "fullName"
        guard let nameFromDB = dictionary["name"] as? String,
              let emailFromDB = dictionary["email"] as? String else {
            return nil
        }
        
        self.id = id
        self.fullName = nameFromDB
        self.email = emailFromDB
        
        // Match Firebase "phone" key
        self.phone = dictionary["phone"] as? String ?? ""
        
        // Match Firebase "username" or default to email if missing
        self.username = dictionary["username"] as? String ?? emailFromDB
        
        // Match Firebase "categoryName" key
        self.category = dictionary["categoryName"] as? String ?? (dictionary["category"] as? String ?? "General")
        
        self.status = dictionary["status"] as? String ?? "Active"
        self.imageName = dictionary["imageName"] as? String ?? "default_profile"
        self.roleType = dictionary["roleType"] as? String ?? "Provider"
    }

    // 3. Dictionary for Saving (Maps your code back to Firebase keys)
    var dictionary: [String: Any] {
        return [
            "name": fullName,       // Keep consistent with your DB screenshot
            "email": email,
            "phone": phone,
            "username": username,
            "categoryName": category, // Keep consistent with your DB screenshot
            "status": status,
            "imageName": imageName,
            "roleType": roleType
        ]
    }
}
