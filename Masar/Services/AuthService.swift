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
        if let savedId = UserDefaults.standard.string(forKey: "userId") {
            completion()
            Firestore.firestore()
                .collection("users")
                .document(Auth.auth().currentUser!.uid)
                .setData([
                    "name": "New User",
                    "username": "new_user",
                    "avatarEmoji": "👤"
                ], merge: true)

            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let user = result?.user {
                UserDefaults.standard.set(user.uid, forKey: "userId")
                completion()
            }
        }
    }

}

