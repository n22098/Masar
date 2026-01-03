//
//  File.swift
//  Masar
//
//  Created by BP-36-201-10 on 21/12/2025.
//import Foundation
import FirebaseFirestore

struct Seeker {
    var uid: String
    var name: String
    var email: String
    var phone: String
    var username: String
    var role: String
    var status: String
    var profileImageURL: String? // Added to match Firestore screenshot
    var imageName: String // Keeping for UI compatibility
    
    // Initialize from Firebase Document
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        self.uid = data["uid"] as? String ?? document.documentID
        self.name = data["name"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.role = data["role"] as? String ?? "seeker"
        self.status = data["status"] as? String ?? "Active"
        self.profileImageURL = data["profileImageURL"] as? String
        self.imageName = "profile1"
    }
    
    // Initializer for manual creation
    init(fullName: String, email: String, phone: String, username: String, status: String, imageName: String, roleType: String, profileImageURL: String? = nil) {
        self.uid = ""
        self.name = fullName
        self.email = email
        self.phone = phone
        self.username = username
        self.role = roleType
        self.status = status
        self.imageName = imageName
        self.profileImageURL = profileImageURL
    }
}
