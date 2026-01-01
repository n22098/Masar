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

    // غيرنا User إلى AppUser
    func fetchCurrentUser(completion: @escaping (AppUser?) -> Void) {
        guard !currentUserId.isEmpty else {
            completion(nil)
            return
        }

        db.collection("users")
            .document(currentUserId)
            .getDocument { snapshot, _ in

                guard let data = snapshot?.data(),
                      let name = data["name"] as? String else {
                    completion(nil)
                    return
                }

                // نستخدم AppUser هنا
                let user = AppUser(
                    id: self.currentUserId,
                    name: name,
                    email: data["email"] as? String ?? "",
                    phone: data["phone"] as? String ?? "",
                    role: data["role"] as? String ?? "seeker", // إضافة الرول
                    profileImageName: data["profileImageUrl"] as? String
                )

                completion(user)
            }
    }
    
    func updateEmail(_ email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData(["email": email])
    }
}
