import Foundation
import FirebaseFirestore
// تم حذف FirebaseFirestoreSwift لأنه أصبح مدمجاً في النسخ الجديدة

class ServiceManager {
    
    static let shared = ServiceManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Save Booking (حفظ الحجز)
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        do {
            let _ = try db.collection("bookings").addDocument(from: booking) { error in
                if let error = error {
                    print("❌ Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Booking saved successfully")
                    completion(true)
                }
            }
        } catch {
            print("❌ Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Fetch All Bookings (جلب جميع الحجوزات) - 🛑 هذه كانت ناقصة
    func fetchAllBookings(completion: @escaping ([BookingModel]) -> Void) {
        db.collection("bookings")
            .order(by: "date", descending: false) // ترتيب حسب التاريخ
            .addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No bookings found")
                completion([])
                return
            }
            
            let bookings = documents.compactMap { document -> BookingModel? in
                try? document.data(as: BookingModel.self)
            }
            completion(bookings)
        }
    }
    
    // MARK: - Update Status (تحديث الحالة)
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).updateData([
            "status": newStatus.rawValue
        ]) { error in
            if let error = error {
                print("Error updating status: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Fetch All Services (جلب الخدمات)
    func fetchAllServices(completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let services = documents.compactMap { try? $0.data(as: ServiceModel.self) }
            completion(services)
        }
    }
    
    // MARK: - Delete Service (حذف خدمة)
    func deleteService(serviceId: String, completion: @escaping (Error?) -> Void) {
        db.collection("services").document(serviceId).delete { error in
            completion(error)
        }
    }
    
    // MARK: - Add Service (إضافة خدمة)
    func addService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        do {
            let _ = try db.collection("services").addDocument(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // MARK: - Update Service (تحديث خدمة)
    func updateService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        guard let id = service.id else { return }
        do {
            try db.collection("services").document(id).setData(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
}
