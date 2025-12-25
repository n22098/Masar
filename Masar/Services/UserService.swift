import Foundation
import FirebaseAuth
import FirebaseFirestore

final class UserService {

    static let shared = UserService()
    private init() {}

    private let db = Firestore.firestore()

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard !currentUserId.isEmpty else {
            completion(nil)
            return
        }

        db.collection("users")
            .document(currentUserId)
            .getDocument { snapshot, _ in

                guard
                    let data = snapshot?.data(),
                    let name = data["name"] as? String,
                    let username = data["username"] as? String
                else {
                    completion(nil)
                    return
                }

                let user = User(
                    id: self.currentUserId,
                    name: name,
                    username: username,
                    profileImageUrl: nil
                )

                completion(user)
            }
    }

    func updateProfile(name: String, username: String, avatarEmoji: String) {
        guard !currentUserId.isEmpty else { return }

        db.collection("users")
            .document(currentUserId)
            .updateData([
                "name": name,
                "username": username,
                "avatarEmoji": avatarEmoji
            ])
    }
}
