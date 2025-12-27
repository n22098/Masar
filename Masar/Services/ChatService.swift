import FirebaseFirestore
import FirebaseStorage

final class ChatService {

    static let shared = ChatService()
    private init() {}

    private let db = Firestore.firestore()

    func conversationId(currentUserId: String, otherUserId: String) -> String {
        let ids = [currentUserId, otherUserId].sorted()
        return ids.joined(separator: "_")
    }

    func sendMessage(
        text: String,
        from senderId: String,
        to receiverId: String
    ) {
        let conversationId = conversationId(
            currentUserId: senderId,
            otherUserId: receiverId
        )

        let conversationRef = db
            .collection("conversations")
            .document(conversationId)

        let messageRef = conversationRef
            .collection("messages")
            .document()

        let messageData: [String: Any] = [
            "senderId": senderId,
            "receiverId": receiverId,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]

        messageRef.setData(messageData)

        conversationRef.setData(
            [
                "participants": [senderId, receiverId],
                "lastMessage": text,
                "updatedAt": FieldValue.serverTimestamp()
            ],
            merge: true
        )
    }
    func uploadImageToCloudinary(
        image: UIImage,
        completion: @escaping (String?) -> Void
    ) {
        let cloudName = "deyq46kjs"
        let uploadPreset = "chat_unsigned"

        let url = URL(string:
            "https://api.cloudinary.com/v1_1/deyq46kjs/image/upload"
        )!

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let secureURL = json["secure_url"] as? String
            else {
                completion(nil)
                return
            }

            completion(secureURL)
        }.resume()
    }
    func sendImageUsingCloudinary(
        image: UIImage,
        from senderId: String,
        to receiverId: String
    ) {
        uploadImageToCloudinary(image: image) { imageURL in
            guard let imageURL = imageURL else { return }

            let conversationId = self.conversationId(
                currentUserId: senderId,
                otherUserId: receiverId
            )

            let conversationRef = self.db
                .collection("conversations")
                .document(conversationId)

            let messageRef = conversationRef
                .collection("messages")
                .document()

            let messageData: [String: Any] = [
                "senderId": senderId,
                "receiverId": receiverId,
                "imageURL": imageURL,
                "timestamp": FieldValue.serverTimestamp()
            ]

            messageRef.setData(messageData)

            conversationRef.setData(
                [
                    "participants": [senderId, receiverId],
                    "lastMessage": "📷 Image",
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                merge: true
            )
        }
    }


    func sendImage(
        image: UIImage,
        from senderId: String,
        to receiverId: String
    ) {
        let conversationId = conversationId(
            currentUserId: senderId,
            otherUserId: receiverId
        )

        //compress for uplaod
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        let imageId = UUID().uuidString
        let storageRef = Storage.storage()
            .reference()
            .child("chat_images/\(conversationId)/\(imageId).jpg")

        storageRef.putData(imageData) { _, error in
            if let error = error {
                print("Image upload error:", error)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL error:", error)
                    return
                }

                guard let imageURL = url?.absoluteString else { return }

                let conversationRef = self.db
                    .collection("conversations")
                    .document(conversationId)

                let messageRef = conversationRef
                    .collection("messages")
                    .document()

                let messageData: [String: Any] = [
                    "senderId": senderId,
                    "receiverId": receiverId,
                    "imageURL": imageURL,
                    "timestamp": FieldValue.serverTimestamp()
                ]

                messageRef.setData(messageData)

                conversationRef.setData(
                    [
                        "participants": [senderId, receiverId],
                        "lastMessage": "📷 Image",
                        "updatedAt": FieldValue.serverTimestamp()
                    ],
                    merge: true
                )
            }
        }
    }
    


    func loadMessages(
        currentUserId: String,
        otherUserId: String,
        completion: @escaping ([Message]) -> Void
    ) {
        let conversationId = conversationId(
            currentUserId: currentUserId,
            otherUserId: otherUserId
        )

        db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in

                if let error = error {
                    print("Load messages error:", error)
                    completion([])
                    return
                }

                let messages = snapshot?.documents.compactMap { doc -> Message? in
                    let data = doc.data()

                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let text = data["text"] as? String
                    let imageURL = data["imageURL"] as? String

                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    return Message(
                        id: doc.documentID,
                        senderId: senderId,
                        receiverId: receiverId,
                        text: text,
                        imageURL: imageURL,
                        timestamp: timestamp
                    )


                    return Message(
                        id: doc.documentID,
                        senderId: senderId,
                        receiverId: receiverId,
                        text: text,
                        imageURL: imageURL,
                        timestamp: timestamp
                    )

                } ?? []

                completion(messages)
            }
    }
    
    func listenForMessages(
        currentUserId: String,
        otherUserId: String,
        onUpdate: @escaping ([Message]) -> Void
    ) {
        
        let conversationId = conversationId(
            currentUserId: currentUserId,
            otherUserId: otherUserId
        )

        db.collection("conversations")
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

                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let text = data["text"] as? String
                    let imageURL = data["imageURL"] as? String

                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    return Message(
                        id: doc.documentID,
                        senderId: senderId,
                        receiverId: receiverId,
                        text: text,
                        imageURL: imageURL,
                        timestamp: timestamp
                    )

                } ?? []


                onUpdate(messages)
            }
    }

}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
