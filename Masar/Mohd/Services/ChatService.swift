import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit

final class ChatService {

    static let shared = ChatService()
    private init() {}

    private let db = Firestore.firestore()
    private let cloudName = "dsjx9ehz2" // Updated cloud name
    private let uploadPreset = "ml_default"

    // MARK: - Helpers
    func conversationId(currentUserId: String, otherUserId: String) -> String {
        let ids = [currentUserId, otherUserId].sorted()
        return ids.joined(separator: "_")
    }

    // MARK: - Sending Messages
    func sendMessage(text: String?, imageURL: String? = nil, from senderId: String, to receiverId: String) {
        let conversationId = conversationId(currentUserId: senderId, otherUserId: receiverId)
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()

        var messageData: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        
        if let text = text, !text.isEmpty { messageData["text"] = text }
        if let imageURL = imageURL { messageData["imageURL"] = imageURL }

        messageRef.setData(messageData)
        
        var lastMsg = "Sent an attachment"
        if let text = text, !text.isEmpty { lastMsg = text } else if imageURL != nil {
            lastMsg = imageURL!.contains(".mp4") ? "🎥 Video" : "🖼 Image"
        }
        
        conversationRef.setData([
            "participants": [senderId, receiverId],
            "lastMessage": lastMsg,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
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
                    print("Listener error: \(error.localizedDescription)")
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
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                } ?? []
                
                onUpdate(messages)
            }
    }
    
    // MARK: - Media Upload Logic (Unified)
    
    func sendImageUsingCloudinary(image: UIImage, from senderId: String, to receiverId: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        uploadMediaToCloudinary(data: imageData, isVideo: false) { [weak self] urlString in
            guard let self = self, let url = urlString else { return }
            self.sendMessage(text: nil, imageURL: url, from: senderId, to: receiverId)
        }
    }

    func sendVideoUsingCloudinary(videoURL: URL, from senderId: String, to receiverId: String) {
        guard let videoData = try? Data(contentsOf: videoURL) else { return }
        uploadMediaToCloudinary(data: videoData, isVideo: true) { [weak self] urlString in
            guard let self = self, let url = urlString else { return }
            self.sendMessage(text: nil, imageURL: url, from: senderId, to: receiverId)
        }
    }

    private func uploadMediaToCloudinary(data: Data, isVideo: Bool, completion: @escaping (String?) -> Void) {
        let resourceType = isVideo ? "video" : "image"
        guard let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/\(resourceType)/upload") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")
        body.append("--\(boundary)\r\n")
        
        let filename = isVideo ? "video.mp4" : "image.jpg"
        let mimeType = isVideo ? "video/mp4" : "image/jpeg"
        
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Cloudinary Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let urlString = json["secure_url"] as? String else {
                completion(nil)
                return
            }
            completion(urlString)
        }.resume()
    }
}

// MARK: - Data Extension
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
