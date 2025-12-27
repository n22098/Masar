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
        if let uid = Auth.auth().currentUser?.uid {
            // User already signed in — do NOT overwrite data
            completion()
            return
        }

        Auth.auth().signInAnonymously { result, error in
            guard let user = result?.user else { return }

            let uid = user.uid
            let userRef = Firestore.firestore().collection("users").document(uid)

            userRef.getDocument { snapshot, _ in
                if snapshot?.exists == false {
                    // Create user ONLY if it does not exist
                    userRef.setData([
                        "name": "New User",
                        "username": "new_user",
                        "profileImageUrl": ""
                    ])
                }
                completion()
            }
        }
    }


}

