import Foundation
import FirebaseFirestore
import FirebaseAuth // 🔥 1. ضروري جداً لجلب رقم المستخدم

class ServiceManager {
    
    static let shared = ServiceManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Save Booking (حفظ الحجز)
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        print("💾 [ServiceManager] Starting to save booking...")
        print("📋 [ServiceManager] Booking details:")
        print("   - Service: \(booking.serviceName)")
        print("   - Seeker: \(booking.seekerName)")
        print("   - Email: \(booking.email ?? "N/A")")
        print("   - Status: \(booking.status.rawValue)")
        print("   - Date: \(booking.dateString)")
        
        do {
            let _ = try db.collection("bookings").addDocument(from: booking) { error in
                if let error = error {
                    print("❌ [ServiceManager] Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ [ServiceManager] Booking saved successfully to Firebase!")
                    print("🔔 [ServiceManager] Snapshot listener should trigger now...")
                    completion(true)
                }
            }
        } catch {
            print("❌ [ServiceManager] Encoding error: \(error.localizedDescription)")
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
                do {
                    var booking = try document.data(as: BookingModel.self)
                    // ✅ تحديث الـ ID من Firebase
                    booking.id = document.documentID
                    return booking
                } catch {
                    print("❌ Failed to decode booking: \(error)")
                    return nil
                }
            }
            completion(bookings)
        }
    }
    
    // MARK: - Fetch Bookings for Seeker (حجوزات المستخدم فقط)
    func fetchBookingsForSeeker(seekerEmail: String, completion: @escaping ([BookingModel]) -> Void) {
        print("🔍 Starting fetch for email: \(seekerEmail)")
        
        db.collection("bookings")
            .whereField("email", isEqualTo: seekerEmail)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching seeker bookings: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents in snapshot")
                    completion([])
                    return
                }
                
                print("📦 Found \(documents.count) documents")
                
                let bookings = documents.compactMap { document -> BookingModel? in
                    do {
                        var booking = try document.data(as: BookingModel.self)
                        // ✅ تحديث الـ ID من Firebase
                        booking.id = document.documentID
                        print("✅ Decoded booking: \(booking.serviceName)")
                        return booking
                    } catch {
                        print("❌ Failed to decode booking: \(error)")
                        return nil
                    }
                }
                
                print("✅ Successfully fetched \(bookings.count) bookings for: \(seekerEmail)")
                completion(bookings)
            }
    }
    
    // MARK: - Fetch Bookings for Provider (حجوزات Provider فقط) ✅ جديد
    func fetchBookingsForProvider(providerId: String, completion: @escaping ([BookingModel]) -> Void) {
        print("🔍 Starting fetch for provider: \(providerId)")
        
        db.collection("bookings")
            .whereField("providerId", isEqualTo: providerId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching provider bookings: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents in snapshot")
                    completion([])
                    return
                }
                
                print("📦 Found \(documents.count) documents for provider")
                
                let bookings = documents.compactMap { document -> BookingModel? in
                    do {
                        var booking = try document.data(as: BookingModel.self)
                        // ✅ CRITICAL: تحديث الـ ID من Firebase
                        booking.id = document.documentID
                        print("✅ Decoded booking: \(booking.serviceName) (ID: \(document.documentID))")
                        return booking
                    } catch {
                        print("❌ Failed to decode booking: \(error)")
                        return nil
                    }
                }
                
                print("✅ Successfully fetched \(bookings.count) bookings for provider: \(providerId)")
                completion(bookings)
            }
    }
    
    // MARK: - Update Status
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus, completion: @escaping (Bool) -> Void) {
        print("🔄 Updating booking \(bookingId) to status: \(newStatus.rawValue)")
        
        db.collection("bookings").document(bookingId).updateData([
            "status": newStatus.rawValue
        ]) { error in
            if let error = error {
                print("❌ Error updating status: \(error)")
                completion(false)
            } else {
                print("✅ Status updated successfully in Firebase")
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
