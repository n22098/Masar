import Foundation
import FirebaseFirestore
import FirebaseAuth

class ServiceManager {
    
    static let shared = ServiceManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // =====================================================
    // MARK: - 1. BOOKINGS (الحجوزات)
    // =====================================================
    
    /// حفظ حجز جديد (يستخدمها الباحث)
    func saveBooking(booking: BookingModel, completion: @escaping (Bool) -> Void) {
        var finalBooking = booking
        if finalBooking.seekerId == nil {
            finalBooking.seekerId = Auth.auth().currentUser?.uid
        }
        
        do {
            let _ = try db.collection("bookings").addDocument(from: finalBooking) { error in
                completion(error == nil)
            }
        } catch {
            print("Encoding Error: \(error)")
            completion(false)
        }
    }
    
    /// جلب حجوزات الباحث فقط (لشاشة History)
    // MARK: - 1. دالة للباحث (Seeker) - تعرض حجوزاته فقط
        func fetchBookings(completion: @escaping ([BookingModel]) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("❌ Error: No user logged in!")
                completion([])
                return
            }
            
            print("🔍 أنا الآن أبحث عن حجوزات للمستخدم رقم: \(uid)")
            
            // ⚠️ ملاحظة: ألغيت الترتيب مؤقتاً للتأكد من ظهور البيانات
            // بمجرد أن تعمل، سنعيد الترتيب وننشئ الفهرس
            db.collection("bookings")
                .whereField("seekerId", isEqualTo: uid)
                //.order(by: "date", descending: true) // 👈 هذا السطر هو سبب المشكلة حالياً
                .addSnapshotListener { snapshot, error in
                    
                    if let error = error {
                        print("❌ خطأ في جلب البيانات: \(error.localizedDescription)")
                        // 🔥 انتبه: إذا ظهر رابط في الكونسول هنا، انسخه وضعه في المتصفح
                        completion([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ القائمة فارغة! لا توجد حجوزات لهذا المستخدم.")
                        completion([])
                        return
                    }
                    
                    print("✅ وجدنا \(documents.count) حجز لهذا المستخدم!")
                    
                    let bookings = documents.compactMap { try? $0.data(as: BookingModel.self) }
                    completion(bookings)
                }
        }
    
    /// جلب حجوزات مقدم الخدمة فقط (لشاشة Provider Bookings & Dashboard)
    /// 🔥 (هذه الدالة كانت تسبب لك مشكلة، الآن هي موجودة)
    func fetchProviderBookings(completion: @escaping ([BookingModel]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
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
    
    /// تحديث حالة الحجز (قبول/رفض/إكمال)
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).updateData(["status": newStatus.rawValue]) { error in
            completion(error == nil)
        }
    }
    
    /// حذف حجز
    func deleteBooking(bookingId: String, completion: @escaping (Bool) -> Void) {
        db.collection("bookings").document(bookingId).delete { error in
            completion(error == nil)
        }
    }
    
    // =====================================================
    // MARK: - 2. SERVICES (إدارة الخدمات) - الجزء المفقود
    // =====================================================
    
    /// جلب جميع الخدمات (لشاشة البحث الرئيسية)
    func fetchAllServices(completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services").getDocuments { snapshot, _ in
            let services = snapshot?.documents.compactMap { try? $0.data(as: ServiceModel.self) } ?? []
            completion(services)
        }
    }
    
    /// جلب خدمات مقدم خدمة معين (لشاشة Provider Services)
    func fetchServicesForProvider(providerId: String, completion: @escaping ([ServiceModel]) -> Void) {
        db.collection("services")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snapshot, _ in
                let services = snapshot?.documents.compactMap { try? $0.data(as: ServiceModel.self) } ?? []
                completion(services)
            }
    }
    
    /// إضافة خدمة جديدة
    func addService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        var serviceToSave = service
        
        // التأكد من إضافة ID المزود
        if serviceToSave.providerId == nil {
            serviceToSave.providerId = Auth.auth().currentUser?.uid
        }
        
        do {
            let _ = try db.collection("services").addDocument(from: serviceToSave, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    /// تحديث خدمة موجودة 🔥 (كانت ناقصة)
    func updateService(_ service: ServiceModel, completion: @escaping (Error?) -> Void) {
        guard let id = service.id else { return }
        do {
            try db.collection("services").document(id).setData(from: service, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    /// حذف خدمة 🔥 (كانت ناقصة)
    func deleteService(serviceId: String, completion: @escaping (Error?) -> Void) {
        db.collection("services").document(serviceId).delete { error in
            completion(error)
        }
    }
}
