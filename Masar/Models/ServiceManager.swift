import Foundation
import FirebaseFirestore

class ServiceManager {
    static let shared = ServiceManager()
    
    // 👇 حذفنا كلمة private ليصبح متاحاً عند الحاجة، ولكن الأفضل استخدام الدوال
    let db = Firestore.firestore()
    
    // 1. جلب الخدمات
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
    
    // 2. حفظ الحجز
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("bookings").addDocument(from: booking) { error in
                if let error = error {
                    print("❌ Error saving: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Booking saved!")
                    completion(true)
                }
            }
        } catch {
            print("⚠️ Error encoding: \(error)")
            completion(false)
        }
    }
    
    // 3. جلب الحجوزات (🔥 الدالة الجديدة)
    func fetchAllBookings(completion: @escaping ([BookingModel]) -> Void) {
        db.collection("bookings").order(by: "date", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("❌ Error fetching bookings: \(error.localizedDescription)")
                completion([])
                return
            }
            
            var bookingsArray: [BookingModel] = []
            for document in snapshot?.documents ?? [] {
                do {
                    let booking = try document.data(as: BookingModel.self)
                    bookingsArray.append(booking)
                } catch {
                    print("⚠️ Error decoding booking: \(error)")
                }
            }
            print("✅ Fetched \(bookingsArray.count) bookings")
            completion(bookingsArray)
        }
    }
}
