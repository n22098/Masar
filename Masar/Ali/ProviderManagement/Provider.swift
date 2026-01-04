import Foundation
import FirebaseFirestore

/// Provider: A data structure representing a service provider in the system.
/// OOD Principle: Data Modeling - This struct encapsulates all the properties
/// of a provider into a single, cohesive unit.
struct Provider {
    
    // MARK: - Properties
    // OOD Principle: Value Types - Using a 'struct' ensures that data is copied
    // rather than referenced, preventing accidental data changes across the app.
    var uid: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var role: String
    var status: String
    var category: String
    var imageName: String
    var profileImageURL: String? // Optional: because a user might not have uploaded a photo yet.
    
    // MARK: - Initializer
    
    /// Failable-style Initializer: Converts a Firebase Document into a Swift Object.
    /// OOD Principle: Abstraction - This hides the complexity of manual dictionary
    /// parsing from the View Controllers.
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        // Document ID is used as the unique identifier (UID)
        self.uid = document.documentID
        
        // Defensive Programming: Using Nil-Coalescing (??) to provide default values.
        // This ensures the app never crashes if a database field is missing.
        self.fullName = data["name"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.role = data["role"] as? String ?? "provider"
        
        // Status Mapping: Ensures the user's current account state (Active/Ban) is captured.
        self.status = data["status"] as? String ?? "Active"
        
        self.category = data["category"] as? String ?? "Uncategorized"
        
        // Local asset fallback for UI testing or placeholder images
        self.imageName = "profile1"
        
        // Optional Binding: Only assigns the URL if it actually exists in Firestore.
        self.profileImageURL = data["profileImageURL"] as? String
    }
}
