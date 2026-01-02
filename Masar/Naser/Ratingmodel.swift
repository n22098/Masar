import Foundation

// MARK: - Rating Model
struct Rating: Codable {
    let stars: Double
    let feedback: String
    let date: Date
    let bookingName: String?
    let username: String
    
    init(stars: Double, feedback: String, date: Date, bookingName: String?, username: String) {
        self.stars = stars
        self.feedback = feedback
        self.date = date
        self.bookingName = bookingName
        self.username = username
    }
}
