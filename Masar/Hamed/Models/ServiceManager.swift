import Foundation
import FirebaseFirestore
import FirebaseAuth // 🔥 1. ضروري جداً لجلب رقم المستخدم

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
    
    // MARK: - Fetch All Bookings
    func fetchAllBookings(completion: @escaping ([BookingModel]) -> Void) {
        db.collection("bookings")
            .order(by: "date", descending: false)
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
    
    // MARK: - Fetch Bookings for Seeker (حجوزات المستخدم فقط)
    func fetchBookingsForSeeker(seekerEmail: String, completion: @escaping ([BookingModel]) -> Void) {
        db.collection("bookings")
            .whereField("email", isEqualTo: seekerEmail)
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching seeker bookings: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No bookings found for seeker")
                    completion([])
                    return
                }
                
                let bookings = documents.compactMap { document -> BookingModel? in
                    try? document.data(as: BookingModel.self)
                }
                print("✅ Fetched \(bookings.count) bookings for seeker: \(seekerEmail)")
                completion(bookings)
            }
    }
    
    // MARK: - Update Status
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
    
    // MARK: - Fetch All Services
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
    
    // MARK: - Fetch Services for Specific Provider
    func fetchServicesForProvider(providerId: String, completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching services: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let services = documents.compactMap { try? $0.data(as: ServiceModel.self) }
                print("✅ Fetched \(services.count) services for provider: \(providerId)")
                completion(services)
            }
    }
    
    // MARK: - Delete Service
    func deleteService(serviceId: String, completion: @escaping (Error?) -> Void) {
        db.collection("services").document(serviceId).delete { error in
            completion(error)
        }
    }
    
    // MARK: - Add Service (🔥 تم التعديل هنا)
    func addService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        // ننسخ الخدمة لنتمكن من التعديل عليها
        var serviceToSave = service
        
        // 🔥 Fix: التأكد من إضافة رقم الهوية (UID) قبل الحفظ
        if serviceToSave.providerId == nil || serviceToSave.providerId?.isEmpty == true {
            if let currentUser = Auth.auth().currentUser {
                serviceToSave.providerId = currentUser.uid
                print("✅ Auto-injected Provider ID: \(currentUser.uid)")
            } else {
                print("⚠️ Warning: No logged in user found when adding service")
            }
        }
        
        do {
            let _ = try db.collection("services").addDocument(from: serviceToSave, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // MARK: - Update Service
    func updateService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        guard let id = service.id else { return }
        do {
            try db.collection("services").document(id).setData(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
}
