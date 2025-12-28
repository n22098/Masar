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

    var currentUserId: String {
        UserDefaults.standard.string(forKey: "userId") ?? ""
    }

//same user ID
    func signInIfNeeded(completion: @escaping () -> Void) {
        if let _ = Auth.auth().currentUser {
            completion()
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Auth error:", error)
                return
            }
            completion()
        }
    }


}

