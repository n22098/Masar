import Foundation
import FirebaseFirestore

// 1. حذفنا Codable لأننا لا نحتاجه (نحن نقوم بالتحويل يدوياً)
struct Provider: Identifiable {
    
    // 2. بروتوكول Identifiable يطلب متغير اسمه id
    // نقوم بإنشائه كمتغير محسوب يرجع قيمة uid
    var id: String { uid }
    
    var uid: String
    var fullName: String
    var email: String
    var phone: String
    var username: String
    var category: String
    var status: String
    var imageName: String
    var role: String
    var aboutMe: String
    var skills: String
    

    // --- Standard Initializer ---
    init(uid: String = UUID().uuidString,
         fullName: String,
         email: String,
         phone: String,
         username: String,
         category: String,
         status: String = "Active",
         imageName: String = "default_profile",
         role: String = "Provider",
         aboutMe: String = "",
         skills: String = "") {
        
        self.uid = uid
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.username = username
        self.category = category
        self.status = status
        self.imageName = imageName
        self.role = role
        self.aboutMe = aboutMe
        self.skills = skills
    }

    // --- Firebase Initializer (Smart Filter) ---
    init?(uid: String, dictionary: [String: Any], validCategories: [String]) {
        self.uid = uid
        
        // تنظيف النص (لحل مشكلة المسافة في "Teaching ")
        let rawCategory = (dictionary["category"] as? String ?? "").trimmingCharacters(in: .whitespaces)
        
        // التحقق من أن التصنيف موجود في القائمة
        guard validCategories.contains(rawCategory) else {
            return nil // تجاهل المستخدم إذا كان التصنيف خطأ
        }
        
        self.category = rawCategory
        
        // باقي البيانات
        self.fullName = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.username = dictionary["name"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? "approved"
        self.imageName = dictionary["idCardURL"] as? String ?? "default_profile"
        self.role = "Provider"
        self.aboutMe = dictionary["aboutMe"] as? String ?? ""
        self.skills = dictionary["skills"] as? String ?? ""
    }
    
    // قاموس للحفظ (اختياري، تحتاجه فقط إذا كنت ترفع البيانات للفايربيس من التطبيق)
    var dictionary: [String: Any] {
        return [
            "name": fullName,
            "email": email,
            "phone": phone,
            "category": category,
            "status": status,
            "idCardURL": imageName,
            "role": role,
            "aboutMe": aboutMe,
            "skills": skills
        ]
    }
}
