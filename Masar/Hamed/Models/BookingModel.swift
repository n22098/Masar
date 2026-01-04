// ===================================================================================
// BOOKING MODEL
// ===================================================================================
// PURPOSE: Represents a service appointment in the application.
//
// KEY FEATURES:
// 1. Firestore Integration: Uses @DocumentID to automatically map the database ID.
// 2. State Management: Uses an Enum to track if a booking is Upcoming, Completed, or Canceled.
// 3. Data Formatting: Includes computed properties to format Dates and Prices for the UI.
// ===================================================================================

import Foundation
import FirebaseFirestore

// MARK: - 1. Booking Status Enum
// We use a String-based Enum to ensure status values are consistent across the app and database.
enum BookingStatus: String, Codable {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled"
}

// MARK: - 2. Booking Data Structure
// Conforms to 'Codable' for easy JSON serialization with Firebase.
// Conforms to 'Identifiable' for easy list management.
struct BookingModel: Codable, Identifiable {
    
    // MARK: - Firestore Mapping
    // @DocumentID tells Firestore to automatically map the document's unique ID string
    // to this property when decoding. This is critical for updating/deleting specific bookings.
    @DocumentID var id: String?
    
    // MARK: - Core Properties
    let serviceName: String
    let providerName: String
    var seekerName: String
    let date: Date
    var status: BookingStatus
    let totalPrice: Double
    let notes: String?
    
    // MARK: - Contact & Reference Details
    var email: String?
    let phoneNumber: String?
    let providerId: String?
    var seekerId: String?
    let serviceId: String?
    let descriptionText: String?

    // Helper property to access notes as instructions
    var instructions: String? {
        return notes
    }

    // MARK: - Formatting Helpers (Computed Properties)
    // These properties handle the logic of converting raw data into user-friendly text.
    // This keeps the View Controllers clean and logic-free.

    // Formats the Date object into a readable string (e.g., "Jan 15, 2026 at 3:00 PM")
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Formats the Double price into a currency string (e.g., "15.000 BHD")
    var priceString: String {
        return String(format: "%.3f BHD", totalPrice)
    }
}
