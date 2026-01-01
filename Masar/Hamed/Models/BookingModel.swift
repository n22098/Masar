import Foundation
import FirebaseFirestore

// 1. الحالات
enum BookingStatus: String, Codable {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled"
}

// 2. المودل الموحد
struct BookingModel: Codable {
    var id: String?
    let serviceName: String
    let providerName: String
    
    // ✅ تم التعديل هنا: (let -> var) عشان تقدر تعدل الاسم قبل الحفظ
    var seekerName: String
    
    let date: Date
    var status: BookingStatus
    let totalPrice: Double
    let notes: String?
    
    var email: String?
    let phoneNumber: String?
    let providerId: String?
    var seekerId: String?
    let serviceId: String?
    let descriptionText: String?

    // خاصية مساعدة للتعليمات (لحل مشكلة instructions missing)
    var instructions: String? {
        return notes
    }

    // تنسيق التاريخ للعرض
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // تنسيق السعر للعرض
    var priceString: String {
        return String(format: "%.3f BHD", totalPrice)
    }
}
