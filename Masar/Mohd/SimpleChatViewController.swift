import UIKit
import FirebaseFirestore
import FirebaseAuth

class SimpleChatViewController: UIViewController {
    
    var otherUser: AppUser! // الطرف الآخر (ضروري)
    var conversationId: String? // قد يكون nil إذا كانت محادثة جديدة
    
    private var messages: [Message] = [] // تأكد أن لديك Message struct
    private let tableView = UITableView()
    private let messageField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = otherUser.name
        view.backgroundColor = .systemBackground
        setupUI()
        
        // إذا كان لدينا ID، استمع للرسائل، وإلا أنشئ المحادثة أولاً
        if let id = conversationId {
            listenForMessages(convId: id)
        } else {
            ChatService.shared.createOrGetConversation(otherUser: otherUser) { [weak self] id in
                self?.conversationId = id
                self?.listenForMessages(convId: id)
            }
        }
    }
    
    private func setupUI() {
        // إعدادات الـ UI الخاصة بك
        messageField.borderStyle = .roundedRect
        messageField.placeholder = "Type a message..."
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [messageField, sendButton])
        stack.axis = .horizontal
        stack.spacing = 8
        
        view.addSubview(tableView)
        view.addSubview(stack)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -8)
        ])
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MsgCell")
    }
    
    private func listenForMessages(convId: String) {
        Firestore.firestore().collection("conversations")
            .document(convId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self?.messages = docs.compactMap { doc in
                    let data = doc.data()
                    return Message(
                        id: doc.documentID,
                        senderId: data["senderId"] as? String ?? "",
                        receiverId: data["receiverId"] as? String ?? "",
                        text: data["text"] as? String ?? "",
                        imageURL: nil,
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                self?.tableView.reloadData()
                if let count = self?.messages.count, count > 0 {
                    self?.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
                }
            }
    }
    
    @objc private func sendMessage() {
        guard let text = messageField.text, !text.isEmpty else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // ✅ تم الإصلاح: استخدام المعاملات الصحيحة للدالة (text, from, to)
        ChatService.shared.sendMessage(text: text, from: currentUid, to: otherUser.id)
        
        messageField.text = ""
    }
}

extension SimpleChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MsgCell", for: indexPath)
        let msg = messages[indexPath.row]
        let isMe = msg.senderId == Auth.auth().currentUser?.uid
        cell.textLabel?.text = msg.text
        cell.textLabel?.textAlignment = isMe ? .right : .left
        cell.textLabel?.textColor = isMe ? .blue : .black
        return cell
    }
}
