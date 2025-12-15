import FirebaseFirestore

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

                    guard
                        let senderId = data["senderId"] as? String,
                        let receiverId = data["receiverId"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }

                    return Message(
                        id: doc.documentID,
                        senderId: senderId,
                        receiverId: receiverId,
                        text: text,
                        timestamp: timestamp.dateValue()
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

                    guard
                        let senderId = data["senderId"] as? String,
                        let receiverId = data["receiverId"] as? String,
                        let text = data["text"] as? String
                    else {
                        return nil
                    }

                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    return Message(
                        id: doc.documentID,
                        senderId: senderId,
                        receiverId: receiverId,
                        text: text,
                        timestamp: timestamp
                    )
                } ?? []


                onUpdate(messages)
            }
    }

}
