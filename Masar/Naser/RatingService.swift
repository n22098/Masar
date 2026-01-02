import FirebaseFirestore

class RatingService {
    
    static let shared = RatingService()
    private let db = Firestore.firestore()
    private let collectionName = "Rating"
    
    private init() {}
    
    // دالة الرفع (كما هي)
    func uploadRating(stars: Double, feedback: String, providerId: String, username: String, bookingName: String?, completion: @escaping (Error?) -> Void) {
        
        let data: [String: Any] = [
            "stars": stars,
            "feedback": feedback,
            "date": Timestamp(date: Date()),
            "username": username,
            "providerId": providerId,
            "bookingName": bookingName ?? ""
        ]
        
        db.collection(collectionName).addDocument(data: data) { error in
            completion(error)
        }
    }
    
    // 🔥 دالة الجلب (تستقبل for: providerId لفلترة التقييمات)
    func fetchRatings(for providerId: String, completion: @escaping ([Rating], Error?) -> Void) {
        
        var query = db.collection(collectionName).order(by: "date", descending: true)
        
        // إذا كان الآيدي موجود، جيب تقييماته هو بس
        if !providerId.isEmpty {
            query = db.collection(collectionName)
                .whereField("providerId", isEqualTo: providerId)
                // .order(by: "date", descending: true) // ملاحظة: قد يحتاج فهرس في فايربيس
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }
            
            var ratings: [Rating] = []
            for doc in documents {
                let data = doc.data()
                if let stars = data["stars"] as? Double,
                   let feedback = data["feedback"] as? String {
                    
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    let username = data["username"] as? String ?? "Guest"
                    let bookingName = data["bookingName"] as? String
                    
                    let newRating = Rating(
                        stars: stars,
                        feedback: feedback,
                        date: date,
                        bookingName: bookingName,
                        username: username
                    )
                    ratings.append(newRating)
                }
            }
            // ترتيب يدوي في حال الفلترة أثرت على الترتيب
            ratings.sort { $0.date > $1.date }
            
            completion(ratings, nil)
        }
    }
}
