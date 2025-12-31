//
//  File.swift
//  Masar
//
//  Created by BP-36-201-10 on 21/12/2025.
//
import Foundation
import FirebaseFirestore

struct Seeker {
    var uid: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var role: String
    var status: String
    var imageName: String // Keeping this for your UI compatibility
    
    // Initialize from Firebase Document
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        self.uid = document.documentID
        self.fullName = data["name"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.role = data["role"] as? String ?? "seeker"
        self.status = data["status"] as? String ?? "Active"
        self.imageName = "profile1" // Default placeholder since Firebase uses URLs
    }
    
    // Initializer for creating a new user manually (if needed)
    init(fullName: String, email: String, phone: String, username: String, status: String, imageName: String, roleType: String) {
        self.uid = "" // Will be assigned by Firebase
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.username = username
        self.role = roleType
        self.status = status
        self.imageName = imageName
    }
}
