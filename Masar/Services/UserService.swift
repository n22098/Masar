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

                guard let data = snapshot?.data(),
                      let name = data["name"] as? String else {
                    completion(nil)
                    return
                }

                // نملأ البيانات بناءً على المودل الجديد
                let user = User(
                    id: self.currentUserId,
                    name: name,
                    email: data["email"] as? String ?? "", // جلب الإيميل
                    phone: data["phone"] as? String ?? "", // جلب الهاتف
                    profileImageName: data["profileImageUrl"] as? String // ربط رابط الصورة
                )

                completion(user)
            }
    }
    
    // تحديث البيانات (نحدث الإيميل لأن اليوزرزنيم غير موجود في المودل)
    func updateEmail(_ email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData(["email": email])
    }
}
