import Foundation
import FirebaseFirestore

// Rating Model
struct Rating: Codable {
    @DocumentID var id: String?
    var stars: Double
    var feedback: String
    var date: Date
    var bookingName: String
    var username: String
    var providerId: String?  // ID of the provider being rated
    var seekerId: String?    // ID of the seeker who rated
    
    // Computed property for formatted date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Initialize with default values
    init(stars: Double = 0.0,
         feedback: String = "",
         date: Date = Date(),
         bookingName: String = "",
         username: String = "Guest",
         providerId: String? = nil,
         seekerId: String? = nil) {
        self.stars = stars
        self.feedback = feedback
        self.date = date
        self.bookingName = bookingName
        self.username = username
        self.providerId = providerId
        self.seekerId = seekerId
    }
}
