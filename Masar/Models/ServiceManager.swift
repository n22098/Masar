import Foundation
import FirebaseFirestore

class ServiceManager {
    static let shared = ServiceManager()
    let db = Firestore.firestore()
    
    // MARK: - 1. إدارة الخدمات (Services)
    
    /// جلب جميع الخدمات من الفايربيس
    func fetchAllServices(completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services").getDocuments { (snapshot, error) in
            if let error = error {
                print("❌ Error fetching services: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var servicesArray: [ServiceModel] = []
            for document in snapshot?.documents ?? [] {
                do {
                    let service = try document.data(as: ServiceModel.self)
                    servicesArray.append(service)
                } catch {
                    print("⚠️ Error decoding service: \(error)")
                }
            }
            completion(servicesArray)
        }
    }
    
    /// إضافة خدمة جديدة
    func addService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("services").addDocument(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    /// تحديث خدمة موجودة
    func updateService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        guard let serviceId = service.id else { return }
        do {
            try db.collection("services").document(serviceId).setData(from: service, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    /// حذف خدمة
    func deleteService(serviceId: String, completion: @escaping (Error?) -> Void) {
        db.collection("services").document(serviceId).delete(completion: completion)
    }
    
    // MARK: - 2. إدارة الحجوزات (Bookings)
    
    /// حفظ حجز جديد
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("bookings").addDocument(from: booking) { error in
                if let error = error {
                    print("❌ Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Booking saved successfully!")
                    completion(true)
                }
            }
        } catch {
            print("⚠️ Error encoding booking: \(error)")
            completion(false)
        }
    }
    
    /// جلب جميع الحجوزات (مرتبة بالتاريخ)
    func fetchAllBookings(completion: @escaping ([BookingModel]) -> Void) {
        db.collection("bookings").order(by: "date", descending: true).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("❌ Error fetching bookings: \(error?.localizedDescription ?? "Unknown")")
                completion([])
                return
            }
            
            let bookings = documents.compactMap { try? $0.data(as: BookingModel.self) }
            completion(bookings)
        }
    }
    
    /// تحديث حالة الحجز (قبول/رفض/إكمال)
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).updateData([
            "status": newStatus.rawValue
        ]) { error in
            if let error = error {
                print("❌ Error updating status: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
