import Foundation
import UIKit

// 1. Define the Status Enum
enum BookingStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled" // Spelling matches your code
}

// 2. Define the Model as a CLASS (so data updates sync everywhere)
class BookingModel {
    let serviceName: String
    let date: String
    let price: String
    var status: BookingStatus // ✅ Changed to 'var' so it can be modified
    
    let providerName: String
    
    // Extra fields needed to prevent "Missing Argument" errors
    let seekerName: String
    let email: String
    let phoneNumber: String
    let instructions: String
    
    init(serviceName: String, date: String, price: String, status: BookingStatus, providerName: String, seekerName: String = "", email: String = "", phoneNumber: String = "", instructions: String = "") {
        self.serviceName = serviceName
        self.date = date
        self.price = price
        self.status = status
        self.providerName = providerName
        self.seekerName = seekerName
        self.email = email
        self.phoneNumber = phoneNumber
        self.instructions = instructions
    }
}
