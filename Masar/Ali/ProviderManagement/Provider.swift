import Foundation
import FirebaseFirestore

struct Provider {
    var uid: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var role: String
    var status: String
    var category: String
    var imageName: String
    var profileImageURL: String?
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.uid = document.documentID
        self.fullName = data["name"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.role = data["role"] as? String ?? "provider"
        // Mapping "providerRequestStatus" or "status" based on your Firestore screenshot
        self.status = data["status"] as? String ?? "Active"
        self.category = data["category"] as? String ?? "Uncategorized"
        self.imageName = "profile1"
        self.profileImageURL = data["profileImageURL"] as? String
    }
}
