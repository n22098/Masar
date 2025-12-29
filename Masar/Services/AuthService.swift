//
//  AuthService.swift
//  Masar
//
//  Created by BP-36-201-10 on 15/12/2025.
//
import FirebaseAuth
import FirebaseFirestore

final class AuthService {

    static let shared = AuthService()
    private init() {}

    // Change this to get the UID directly from FirebaseAuth
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    func signInIfNeeded(completion: @escaping () -> Void) {
        // 1. Check if already signed in
        if let user = Auth.auth().currentUser {
            print("✅ Already logged in as: \(user.uid)")
            completion()
            return
        }

        // 2. Sign in anonymously
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Auth error:", error.localizedDescription)
                return
            }
            
            if let user = result?.user {
                print("✅ Signed in anonymously as: \(user.uid)")
            }
            
            completion()
        }
    }
}
