// ===================================================================================
// SERVICE MANAGER (SINGLETON)
// ===================================================================================
// PURPOSE: A centralized manager for handling all Database interactions related to
// Services and Bookings.
//
// KEY FEATURES:
// 1. Singleton: Only one instance handles all network requests.
// 2. Booking Management: Create, Fetch, Update, and Delete bookings.
// 3. Service Management: Create, Fetch, Update, and Delete service listings.
// 4. Role-Based Fetching: Fetches different data depending on if the user is a Seeker or Provider.
// 5. Error Handling: Uses closures to return success/failure states to the UI.
// ===================================================================================

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ServiceManager {
    
    // MARK: - Singleton Setup
    static let shared = ServiceManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // =====================================================
    // MARK: - 1. BOOKINGS MANAGEMENT
    // =====================================================
    
    // Saves a new booking to Firestore. Used by the Seeker during checkout.
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        var finalBooking = booking
        // Ensure the booking is linked to the current user
        if finalBooking.seekerId == nil {
            finalBooking.seekerId = Auth.auth().currentUser?.uid
        }
        
        do {
            // "addDocument" automatically creates a new unique ID
            let _ = try db.collection("bookings").addDocument(from: finalBooking) { error in
                completion(error == nil)
            }
        } catch {
            print("Encoding Error: \(error)")
            completion(false)
        }
    }
    
    // Fetches bookings specifically for the Seeker (My Bookings)
    // Uses a Listener for real-time updates.
    func fetchBookings(completion: @escaping ([BookingModel]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in!")
            completion([])
            return
        }
        
        print("Fetching bookings for user ID: \(uid)")
        
        // Query: Get bookings where 'seekerId' matches current user
        db.collection("bookings")
            .whereField("seekerId", isEqualTo: uid)
            // Note: Ordering is temporarily disabled to ensure data retrieval works first.
            // .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("List is empty! No bookings found.")
                    completion([])
                    return
                }
                
                print("Found \(documents.count) bookings for this user!")
                
                // Convert Firestore documents into BookingModel objects
                let bookings = documents.compactMap { try? $0.data(as: BookingModel.self) }
                completion(bookings)
            }
    }
    
    // Fetches bookings specifically for the Provider (Incoming Jobs)
    func fetchProviderBookings(completion: @escaping ([BookingModel]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        // Query: Get bookings where 'providerId' matches current user
        db.collection("bookings")
            .whereField("providerId", isEqualTo: uid)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let bookings = documents.compactMap { try? $0.data(as: BookingModel.self) }
                completion(bookings)
            }
    }
    
    // Updates the status of a booking (e.g., Pending -> Approved)
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).updateData(["status": newStatus.rawValue]) { error in
            completion(error == nil)
        }
    }
    
    // Deletes a booking from the database
    func deleteBooking(bookingId: String, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).delete { error in
            completion(error == nil)
        }
    }
    
    // =====================================================
    // MARK: - 2. SERVICES MANAGEMENT
    // =====================================================
    
    // Fetches all available services for the Search/Home screen
    func fetchAllServices(completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services").getDocuments { snapshot, _ in
            let services = snapshot?.documents.compactMap { try? $0.data(as: ServiceModel.self) } ?? []
            completion(services)
        }
    }
    
    // Fetches services created by a specific provider (For "My Services" screen)
    func fetchServicesForProvider(providerId: String, completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snapshot, _ in
                let services = snapshot?.documents.compactMap { try? $0.data(as: ServiceModel.self) } ?? []
                completion(services)
            }
    }
    
    // Creates a new Service listing
    func addService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        var serviceToSave = service
        
        // Ensure provider ID is attached
        if serviceToSave.providerId == nil {
            serviceToSave.providerId = Auth.auth().currentUser?.uid
        }
        
        do {
            let _ = try db.collection("services").addDocument(from: serviceToSave, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // Updates an existing Service
    func updateService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        guard let id = service.id else { return }
        do {
            try db.collection("services").document(id).setData(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // Deletes a Service listing
    func deleteService(serviceId: String, completion: @escaping (Error?) -> Void) {
        db.collection("services").document(serviceId).delete { error in
            completion(error)
        }
    }
}
