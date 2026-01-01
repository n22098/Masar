import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

final class ChatService {

    static let shared = ChatService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Helpers
    func conversationId(currentUserId: String, otherUserId: String) -> String {
        let ids = [currentUserId, otherUserId].sorted()
        return ids.joined(separator: "_")
    }
    
    // MARK: - Conversation Management
    func createOrGetConversation(otherUser: AppUser, completion: @escaping (String) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let convId = conversationId(currentUserId: currentUid, otherUserId: otherUser.id)
        
        let ref = db.collection("conversations").document(convId)
        ref.getDocument { snapshot, _ in
            if snapshot?.exists == true {
                completion(convId)
            } else {
                ref.setData([
                    "participants": [currentUid, otherUser.id],
                    "lastMessage": "",
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { _ in
                    completion(convId)
                }
            }
        }
    }

    // MARK: - Sending Messages
    
    // دالة موحدة لإرسال النص أو الصورة
    func sendMessage(text: String?, imageURL: String? = nil, from senderId: String, to receiverId: String) {
        let conversationId = conversationId(currentUserId: senderId, otherUserId: receiverId)
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()

        var messageData: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        if let text = text, !text.isEmpty {
            messageData["text"] = text
        }
        
        if let imageURL = imageURL {
            messageData["imageURL"] = imageURL
        }

        // 1. حفظ الرسالة
        messageRef.setData(messageData)
        
        // 2. تحديث المحادثة بآخر رسالة
        var lastMsg = "Sent an image"
        if let text = text, !text.isEmpty {
            lastMsg = text
        }
        
        conversationRef.setData([
            "participants": [senderId, receiverId],
            "lastMessage": lastMsg,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    // MARK: - Image Handling (Cloudinary)
    
    // الدالة التي كانت مفقودة وتسبب الخطأ
    func sendImageUsingCloudinary(image: UIImage, from senderId: String, to receiverId: String) {
        uploadImageToCloudinary(image: image) { [weak self] urlString in
            guard let self = self, let url = urlString else { return }
            print("✅ Image uploaded: \(url)")
            // إرسال الرسالة مع رابط الصورة
            self.sendMessage(text: nil, imageURL: url, from: senderId, to: receiverId)
        }
    }

    // دالة الرفع إلى Cloudinary
    func uploadImageToCloudinary(image: UIImage, completion: @escaping (String?) -> Void) {
        let cloudName = "deyq46kjs" // تم أخذه من الصورة السابقة
        let uploadPreset = "ml_default" // ⚠️ تأكد من تغيير هذا إلى الـ Preset الخاص بك من إعدادات Cloudinary
        
        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        var body = Data()
        
        // Upload Preset
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")
        
        // Image Data
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Cloudinary Upload Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let urlString = json["secure_url"] as? String {
                    completion(urlString)
                } else {
                    print("⚠️ Could not parse Cloudinary response")
                    completion(nil)
                }
            } catch {
                print("❌ JSON Error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Listening
    
    func listenForMessages(currentUserId: String, otherUserId: String, onUpdate: @escaping ([Message]) -> Void) -> ListenerRegistration {
        let conversationId = conversationId(currentUserId: currentUserId, otherUserId: otherUserId)

        return db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Listener error:", error)
                    return
                }

                let messages = snapshot?.documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    return Message(
                        id: doc.documentID,
                        senderId: data["senderId"] as? String ?? "",
                        receiverId: data["receiverId"] as? String ?? "",
                        text: data["text"] as? String,
                        imageURL: data["imageURL"] as? String,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []
                
                onUpdate(messages)
            }
    }
}

// Extension to help appending strings to Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
