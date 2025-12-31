import FirebaseFirestore

class RatingService {
    
    static let shared = RatingService()
    private let db = Firestore.firestore()
    private let collectionName = "Rating"
    
    private init() {}
    
    // دالة رفع التقييم (تم التعديل لتقبل البيانات يدوياً)
    func uploadRating(stars: Double, feedback: String, bookingName: String, providerId: String? = nil, completion: @escaping (Error?) -> Void) {
        
        var data: [String: Any] = [
            "stars": stars,
            "feedback": feedback,
            "bookingName": bookingName,
            "date": Timestamp(date: Date()),
            "username": "Guest User" // يمكنك تغييرها لاحقاً لاسم المستخدم الحقيقي
        ]
        
        // إضافة providerId إذا كان موجوداً
        if let providerId = providerId {
            data["providerId"] = providerId
        }
        
        db.collection(collectionName).addDocument(data: data, completion: completion)
    }
    
    // دالة جلب التقييمات
    func fetchRatings(completion: @escaping ([Rating], Error?) -> Void) {
        db.collection(collectionName)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion([], error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                // تحويل البيانات يدوياً لتفادي خطأ المكتبة المفقودة
                var ratings: [Rating] = []
                for doc in documents {
                    let data = doc.data()
                    if let stars = data["stars"] as? Double,
                       let feedback = data["feedback"] as? String,
                       let bookingName = data["bookingName"] as? String {
                        
                        // معالجة التاريخ
                        let timestamp = data["date"] as? Timestamp
                        let date = timestamp?.dateValue() ?? Date()
                        let username = data["username"] as? String ?? "Guest"
                        
                        let newRating = Rating(stars: stars, feedback: feedback, date: date, bookingName: bookingName, username: username)
                        ratings.append(newRating)
                    }
                }
                
                completion(ratings, nil)
            }
    }
    
    // دالة جلب التقييمات الخاصة بمزود معين
    func fetchRatingsForProvider(providerId: String, completion: @escaping ([Rating], Error?) -> Void) {
        db.collection(collectionName)
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
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
                       let feedback = data["feedback"] as? String,
                       let bookingName = data["bookingName"] as? String {
                        
                        let timestamp = data["date"] as? Timestamp
                        let date = timestamp?.dateValue() ?? Date()
                        let username = data["username"] as? String ?? "Guest User"
                        
                        let newRating = Rating(stars: stars, feedback: feedback, date: date, bookingName: bookingName, username: username)
                        ratings.append(newRating)
                    }
                }
                
                completion(ratings, nil)
            }
    }
}
