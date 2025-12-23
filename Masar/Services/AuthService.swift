//
//  AuthService.swift
//  Masar
//
//  Created by BP-36-201-10 on 15/12/2025.
//
import FirebaseAuth

final class AuthService {

    static let shared = AuthService()
    private init() {}

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func signInIfNeeded(completion: @escaping () -> Void) {
        if Auth.auth().currentUser != nil {
            completion()
            return
        }

        Auth.auth().signInAnonymously { _, error in
            if let error = error {
                print("Auth error:", error)
                return
            }
            completion()
        }
    }
}

