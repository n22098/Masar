import FirebaseFirestore

class RatingService {
    // نستخدم "shared" للوصول للخدمة بسهولة من أي مكان
    static let shared = RatingService()
    private let db = Firestore.firestore()
    
    func uploadRating(_ rating: Rating, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("Rating").addDocument(from: rating) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
}
