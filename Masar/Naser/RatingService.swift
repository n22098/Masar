import FirebaseFirestore

/// RatingService: A dedicated service class for handling all rating-related database operations.
/// OOD Principle: Singleton Pattern - Ensures only one instance of this service exists
/// to manage database traffic efficiently.
class RatingService {
    
    // MARK: - Properties
    
    /// static let shared: The single, globally accessible instance of RatingService.
    static let shared = RatingService()
    
    /// Private reference to the Firestore database (Encapsulation).
    private let db = Firestore.firestore()
    
    /// The name of the collection in Firestore to avoid hardcoding strings multiple times.
    private let collectionName = "Rating"
    
    /// Private initializer prevents other classes from creating new instances of this service.
    private init() {}
    
    // MARK: - Database Operations
    
    /// uploadRating: Sends a new rating document to Firestore.
    /// OOD Principle: Abstraction - The View Controller doesn't need to know how Firestore works;
    /// it just calls this method.
    func uploadRating(stars: Double, feedback: String, providerId: String, username: String, bookingName: String?, completion: @escaping (Error?) -> Void) {
        
        // Mapping local variables into a Dictionary format for Firestore
        let data: [String: Any] = [
            "stars": stars,
            "feedback": feedback,
            "date": Timestamp(date: Date()), // Records the exact moment the rating was given
            "username": username,
            "providerId": providerId,
            "bookingName": bookingName ?? "" // Handles optional booking name safely
        ]
        
        // Adding the document to the collection
        db.collection(collectionName).addDocument(data: data) { error in
            // completion: Returns the result (success or error) back to the caller
            completion(error)
        }
    }
    
    /// fetchRatings: Retrieves ratings from Firestore, optionally filtered by provider.
    /// @escaping: Used because the network request is asynchronous and returns later.
    func fetchRatings(for providerId: String, completion: @escaping ([Rating], Error?) -> Void) {
        
        // Start with a general query ordered by date
        var query = db.collection(collectionName).order(by: "date", descending: true)
        
        // OOD Logic: Conditional Filtering.
        // If a specific providerId is provided, narrow down the results.
        if !providerId.isEmpty {
            query = db.collection(collectionName)
                .whereField("providerId", isEqualTo: providerId)
            // Note: Manual sorting is used below to avoid needing a complex composite index in Firebase.
        }
        
        // Execute the network request
        query.getDocuments { snapshot, error in
            if let error = error {
                completion([], error) // Return empty array and the error if it fails
                return
            }
            
            // Safety Check: Ensure the snapshot contains documents
            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }
            
            var ratings: [Rating] = []
            
            // Parsing: Converting Firestore 'Documents' into our 'Rating' Swift Model objects.
            for doc in documents {
                let data = doc.data()
                
                // Manual unwrapping and type casting for data integrity
                if let stars = data["stars"] as? Double,
                   let feedback = data["feedback"] as? String {
                    
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    let username = data["username"] as? String ?? "Guest"
                    let bookingName = data["bookingName"] as? String
                    
                    // Create the Model Object
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
            
            // Post-Processing: Sort the ratings locally so the newest ones appear at the top.
            ratings.sort { $0.date > $1.date }
            
            // Return the finished list to the UI
            completion(ratings, nil)
        }
    }
}
