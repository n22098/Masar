import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private init() {}
    
    // MARK: - Conversations
    func getConversations(userId: String, completion: @escaping ([Conversation]) -> Void) {
        db.collection("conversations")
            .whereField("seekerId", isEqualTo: userId)
            .order(by: "lastTime", descending: true)
            .addSnapshotListener { snap, error in
                let seekerConvos = snap?.documents.compactMap { Conversation(doc: $0) } ?? []
                
                self.db.collection("conversations")
                    .whereField("providerId", isEqualTo: userId)
                    .order(by: "lastTime", descending: true)
                    .getDocuments { snap, error in
                        let providerConvos = snap?.documents.compactMap { Conversation(doc: $0) } ?? []
                        let all = (seekerConvos + providerConvos).sorted { $0.lastTime > $1.lastTime }
                        completion(all)
                    }
            }
    }
    
    func createConversation(_ conv: Conversation, completion: @escaping (Bool) -> Void) {
        db.collection("conversations").document(conv.bookingId).setData(conv.toDict(), merge: true) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Messages
    func sendTextMessage(bookingId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, text: String, completion: @escaping (Bool) -> Void) {
        let msg = Message(bookingId: bookingId, senderId: senderId, senderName: senderName, receiverId: receiverId, receiverName: receiverName, text: text)
        
        db.collection("conversations").document(bookingId).collection("messages").document(msg.id).setData(msg.toDict()) { error in
            if error == nil {
                self.updateLastMessage(bookingId: bookingId, text: text)
            }
            completion(error == nil)
        }
    }
    
    func sendImage(bookingId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.7) else { completion(false); return }
        
        let ref = storage.reference().child("conversations/\(bookingId)/images/\(UUID().uuidString).jpg")
        
        ref.putData(data) { _, error in
            guard error == nil else { completion(false); return }
            
            ref.downloadURL { url, error in
                guard let urlString = url?.absoluteString else { completion(false); return }
                
                let msg = Message(bookingId: bookingId, senderId: senderId, senderName: senderName, receiverId: receiverId, receiverName: receiverName, imageURL: urlString, timestamp: Date(), isRead: false)
                
                self.db.collection("conversations").document(bookingId).collection("messages").document(msg.id).setData(msg.toDict()) { error in
                    if error == nil { self.updateLastMessage(bookingId: bookingId, text: "📷 Image") }
                    completion(error == nil)
                }
            }
        }
    }
    
    func sendDocument(bookingId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, data: Data, name: String, completion: @escaping (Bool) -> Void) {
        let ref = storage.reference().child("conversations/\(bookingId)/documents/\(name)")
        
        ref.putData(data) { _, error in
            guard error == nil else { completion(false); return }
            
            ref.downloadURL { url, error in
                guard let urlString = url?.absoluteString else { completion(false); return }
                
                let msg = Message(bookingId: bookingId, senderId: senderId, senderName: senderName, receiverId: receiverId, receiverName: receiverName, documentURL: urlString, documentName: name, timestamp: Date(), isRead: false)
                
                self.db.collection("conversations").document(bookingId).collection("messages").document(msg.id).setData(msg.toDict()) { error in
                    if error == nil { self.updateLastMessage(bookingId: bookingId, text: "📎 \(name)") }
                    completion(error == nil)
                }
            }
        }
    }
    
    func getMessages(bookingId: String, completion: @escaping ([Message]) -> Void) {
        db.collection("conversations").document(bookingId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snap, error in
                let msgs = snap?.documents.compactMap { Message(doc: $0) } ?? []
                completion(msgs)
            }
    }
    
    func markRead(bookingId: String, userId: String) {
        db.collection("conversations").document(bookingId).collection("messages")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snap, error in
                guard let docs = snap?.documents else { return }
                let batch = self.db.batch()
                docs.forEach { batch.updateData(["isRead": true], forDocument: $0.reference) }
                batch.commit()
            }
        db.collection("conversations").document(bookingId).updateData(["unreadCount": 0])
    }
    
    // 🔥 الدالة التي كانت مفقودة سابقاً
    private func updateLastMessage(bookingId: String, text: String) {
        db.collection("conversations").document(bookingId).updateData([
            "lastMessage": text,
            "lastTime": Timestamp(date: Date()),
            "unreadCount": FieldValue.increment(Int64(1))
        ])
    }
} // ✅ قوس إغلاق الكلاس المفقود
