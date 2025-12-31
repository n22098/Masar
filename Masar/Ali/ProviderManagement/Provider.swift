import Foundation
import FirebaseFirestore

struct Provider {
    var uid: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var category: String
    var status: String
    var imageName: String
    var role: String
    

    // 1. Standard Initializer (for creating objects in code)
    init(uid: String = UUID().uuidString,
         fullName: String,
         email: String,
         phone: String,
         username: String,
         category: String,
         status: String = "Active",
         imageName: String = "default_profile",
         role: String = "Provider") {
        
        self.uid = uid
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.username = username
        self.category = category
        self.status = status
        self.imageName = imageName
        self.role = role
    }

    // 2. Firebase Initializer - Updated to match your ACTUAL Firebase fields
    init?(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        
        // Map Firebase fields to struct properties
        self.fullName = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.username = dictionary["name"] as? String ?? ""  // Using name as username if not present
        self.category = dictionary["category"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? "approved"
        self.imageName = dictionary["idCardURL"] as? String ?? "default_profile"
        self.role = "Provider"
        
        // Debug print to see what we're getting
        print("📝 Provider created: \(self.fullName), Category: \(self.category), Status: \(self.status)")
    }

    // 3. Dictionary for Saving (Maps your code back to Firebase keys)
    var dictionary: [String: Any] {
        return [
            "name": fullName,
            "email": email,
            "phone": phone,
            "category": category,
            "status": status,
            "idCardURL": imageName,
            "role": role
        ]
    }
}
