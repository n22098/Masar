import FirebaseFirestore

class RatingService {
    
    static let shared = RatingService()
    private let db = Firestore.firestore()
    private let collectionName = "ratings" // Changed to lowercase for consistency
    
    private init() {}
    
    // Upload Rating
    func uploadRating(stars: Double,
                     feedback: String,
                     bookingName: String,
                     providerId: String?,
                     seekerId: String? = nil,
                     seekerName: String? = nil,
                     completion: @escaping (Error?) -> Void) {
        
        print("💾 [RatingService] Uploading rating...")
        print("   - Stars: \(stars)")
        print("   - Feedback: \(feedback)")
        print("   - Service: \(bookingName)")
        print("   - Provider ID: \(providerId ?? "nil")")
        print("   - Seeker ID: \(seekerId ?? "nil")")
        
        var data: [String: Any] = [
            "stars": stars,
            "feedback": feedback,
            "bookingName": bookingName,
            "date": Timestamp(date: Date()),
            "username": seekerName ?? UserManager.shared.currentUser?.name ?? "Guest User"
        ]
        
        if let providerId = providerId {
            data["providerId"] = providerId
        }
        
        if let seekerId = seekerId {
            data["seekerId"] = seekerId
        }
        
        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                print("❌ [RatingService] Error uploading: \(error.localizedDescription)")
            } else {
                print("✅ [RatingService] Rating uploaded successfully!")
            }
            completion(error)
        }
    }
    
    // Fetch ratings for a specific provider
    func fetchRatingsForProvider(providerId: String, completion: @escaping ([Rating], Error?) -> Void) {
        print("🔍 [RatingService] Fetching ratings for provider: \(providerId)")
        
        db.collection(collectionName)
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ [RatingService] Fetch error: \(error.localizedDescription)")
                    completion([], error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ [RatingService] No documents found")
                    completion([], nil)
                    return
                }
                
                print("📦 [RatingService] Found \(documents.count) ratings")
                
                var ratings: [Rating] = []
                for doc in documents {
                    let data = doc.data()
                    if let stars = data["stars"] as? Double,
                       let feedback = data["feedback"] as? String,
                       let bookingName = data["bookingName"] as? String {
                        
                        let timestamp = data["date"] as? Timestamp
                        let date = timestamp?.dateValue() ?? Date()
                        let username = data["username"] as? String ?? "Guest User"
                        let providerId = data["providerId"] as? String
                        let seekerId = data["seekerId"] as? String
                        
                        var rating = Rating(stars: stars,
                                          feedback: feedback,
                                          date: date,
                                          bookingName: bookingName,
                                          username: username,
                                          providerId: providerId,
                                          seekerId: seekerId)
                        rating.id = doc.documentID
                        ratings.append(rating)
                    }
                }
                
                print("✅ [RatingService] Successfully parsed \(ratings.count) ratings")
                completion(ratings, nil)
            }
    }
    
    // Calculate average rating for a provider
    func getAverageRating(for providerId: String, completion: @escaping (Double, Int) -> Void) {
        fetchRatingsForProvider(providerId: providerId) { ratings, error in
            guard error == nil, !ratings.isEmpty else {
                completion(0.0, 0)
                return
            }
            
            let total = ratings.reduce(0.0) { $0 + $1.stars }
            let average = total / Double(ratings.count)
            completion(average, ratings.count)
        }
    }
}
