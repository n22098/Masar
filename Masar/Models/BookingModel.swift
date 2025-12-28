import Foundation
import FirebaseFirestore

// Booking Status Enum
enum BookingStatus: String, Codable {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled"
}

// Booking Model Struct
struct BookingModel: Codable, Identifiable {
    @DocumentID var id: String?
    
    let seekerName: String
    let serviceName: String
    let date: Date
    var status: BookingStatus
    let providerName: String
    let email: String
    let phoneNumber: String
    let price: Double
    let instructions: String?  // ✅ Changed to Optional
    let descriptionText: String
    
    // Converts Date to String for display purposes
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Example: Dec 25, 2025
        return formatter.string(from: date)
    }
    
    // Converts Double to String for display purposes
    var priceString: String {
        return String(format: "%.3f BHD", price) // Example: "50.000 BHD"
    }
}
