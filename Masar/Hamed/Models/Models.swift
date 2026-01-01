import Foundation
import FirebaseFirestore

enum ServiceCategory {
    case itSolutions
    case teaching
    case digitalServices
}

// تم حذف ServiceProviderModel وأيضاً ServiceModel لأنهما معرفان في ملفات منفصلة

struct Message {
    var id: String
    var bookingId: String
    var senderId: String
    var senderName: String
    var receiverId: String
    var receiverName: String
    var text: String?
    var imageURL: String?
    var documentURL: String?
    var documentName: String?
    var timestamp: Date
    var isRead: Bool
    
    // Initializer
    init(id: String = UUID().uuidString, bookingId: String, senderId: String, senderName: String, receiverId: String, receiverName: String, text: String? = nil, imageURL: String? = nil, documentURL: String? = nil, documentName: String? = nil, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.bookingId = bookingId
        self.senderId = senderId
        self.senderName = senderName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.text = text
        self.imageURL = imageURL
        self.documentURL = documentURL
        self.documentName = documentName
        self.timestamp = timestamp
        self.isRead = isRead
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "bookingId": bookingId,
            "senderId": senderId,
            "senderName": senderName,
            "receiverId": receiverId,
            "receiverName": receiverName,
            "timestamp": Timestamp(date: timestamp),
            "isRead": isRead
        ]
        if let text = text { dict["text"] = text }
        if let imageURL = imageURL { dict["imageURL"] = imageURL }
        if let documentURL = documentURL { dict["documentURL"] = documentURL }
        if let documentName = documentName { dict["documentName"] = documentName }
        return dict
    }
    
    init?(doc: DocumentSnapshot) {
        guard let data = doc.data() else { return nil }
        self.id = data["id"] as? String ?? doc.documentID
        self.bookingId = data["bookingId"] as? String ?? ""
        self.senderId = data["senderId"] as? String ?? ""
        self.senderName = data["senderName"] as? String ?? ""
        self.receiverId = data["receiverId"] as? String ?? ""
        self.receiverName = data["receiverName"] as? String ?? ""
        self.text = data["text"] as? String
        self.imageURL = data["imageURL"] as? String
        self.documentURL = data["documentURL"] as? String
        self.documentName = data["documentName"] as? String
        self.isRead = data["isRead"] as? Bool ?? false
        if let ts = data["timestamp"] as? Timestamp {
            self.timestamp = ts.dateValue()
        } else {
            self.timestamp = Date()
        }
    }
}

struct Conversation {
    var id: String
    var bookingId: String
    var seekerId: String
    var seekerName: String
    var providerId: String
    var providerName: String
    var serviceName: String
    var lastMessage: String
    var lastTime: Date
    var unreadCount: Int
    
    init(id: String = UUID().uuidString, bookingId: String, seekerId: String, seekerName: String, providerId: String, providerName: String, serviceName: String, lastMessage: String = "", lastTime: Date = Date(), unreadCount: Int = 0) {
        self.id = id
        self.bookingId = bookingId
        self.seekerId = seekerId
        self.seekerName = seekerName
        self.providerId = providerId
        self.providerName = providerName
        self.serviceName = serviceName
        self.lastMessage = lastMessage
        self.lastTime = lastTime
        self.unreadCount = unreadCount
    }
    
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "bookingId": bookingId,
            "seekerId": seekerId,
            "seekerName": seekerName,
            "providerId": providerId,
            "providerName": providerName,
            "serviceName": serviceName,
            "lastMessage": lastMessage,
            "lastTime": Timestamp(date: lastTime),
            "unreadCount": unreadCount
        ]
    }
    
    init?(doc: DocumentSnapshot) {
        guard let data = doc.data() else { return nil }
        self.id = data["id"] as? String ?? doc.documentID
        self.bookingId = data["bookingId"] as? String ?? ""
        self.seekerId = data["seekerId"] as? String ?? ""
        self.seekerName = data["seekerName"] as? String ?? ""
        self.providerId = data["providerId"] as? String ?? ""
        self.providerName = data["providerName"] as? String ?? ""
        self.serviceName = data["serviceName"] as? String ?? ""
        self.lastMessage = data["lastMessage"] as? String ?? ""
        self.unreadCount = data["unreadCount"] as? Int ?? 0
        if let ts = data["lastTime"] as? Timestamp {
            self.lastTime = ts.dateValue()
        } else {
            self.lastTime = Date()
        }
    }
}

