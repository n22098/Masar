import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MessagesListViewController: UIViewController {

    private let tableView = UITableView()
    private var conversations: [MessageConversation] = []  // ✅ Changed to MessageConversation

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // 1. إعداد البار العلوي باللون الجديد
        setupNavigationBar()
        
        // 2. إعداد الجدول
        setupTableView()

        // 3. تحميل البيانات
        loadMessagesScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ضمان ظهور العنوان الكبير عند العودة لهذه الصفحة
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - Navigation Bar Setup (التعديل هنا)
    private func setupNavigationBar() {
        navigationItem.title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // ✅ هذا هو اللون الجديد الموحد (98, 84, 243)
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear // إزالة الخط الفاصل السفلي لنظافة التصميم
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        tableView.rowHeight = 76

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Firebase Logic

    private func loadMessagesScreen() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        resolveUserRole(currentUid: currentUid) { [weak self] role in
            guard let self = self else { return }
            if role.lowercased() == "provider" {
                self.startListeningForConversations(currentUid: currentUid)
            } else {
                self.fetchAllProviders()
            }
        }
    }

    private func resolveUserRole(currentUid: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(currentUid).getDocument { [weak self] doc, _ in
            if let data = doc?.data() {
                let role = (data["role"] as? String) ?? (data["userType"] as? String) ?? ""
                if !role.isEmpty {
                    completion(role)
                    return
                }
            }
            guard let self = self else { return }
            self.db.collection("users").whereField("uid", isEqualTo: currentUid).limit(to: 1).getDocuments { snap, _ in
                let role = snap?.documents.first?.data()["role"] as? String ?? ""
                completion(role)
            }
        }
    }

    private func startListeningForConversations(currentUid: String) {
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                var newConversations: [MessageConversation] = []  // ✅ Changed
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let lastMessageText = (data["lastMessage"] as? String) ?? ""
                    let ts = (data["lastUpdated"] as? Timestamp) ?? (data["updatedAt"] as? Timestamp)
                    let lastUpdatedDate = ts?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []
                    
                    guard let otherUserId = participants.first(where: { $0 != currentUid }) else { continue }

                    group.enter()
                    self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                        defer { group.leave() }
                        let userData = userSnap?.data()
                        let userName = userData?["name"] as? String ?? "Unknown"
                        let userEmail = userData?["email"] as? String ?? ""
                        
                        // ✅ Create MessageConversation instead of Conversation
                        let conv = MessageConversation(
                            id: conversationId,
                            otherUserId: otherUserId,
                            otherUserName: userName,
                            otherUserEmail: userEmail,
                            lastMessage: lastMessageText,
                            lastUpdated: lastUpdatedDate
                        )
                        newConversations.append(conv)
                    }
                }

                group.notify(queue: .main) {
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                }
            }
    }

    private func fetchAllProviders() {
        let currentUid = Auth.auth().currentUser?.uid ?? ""
        db.collection("users").whereField("role", isEqualTo: "provider").getDocuments { [weak self] snapshot, _ in
            guard let self = self, let documents = snapshot?.documents else { return }

            var fetchedList: [MessageConversation] = []  // ✅ Changed
            for doc in documents {
                let data = doc.data()
                let uid = data["uid"] as? String ?? doc.documentID
                if uid == currentUid { continue }

                let providerName = data["name"] as? String ?? "Unknown Provider"
                let providerEmail = data["email"] as? String ?? ""
                
                // ✅ Create MessageConversation instead of Conversation
                let conversationItem = MessageConversation(
                    id: uid,
                    otherUserId: uid,
                    otherUserName: providerName,
                    otherUserEmail: providerEmail,
                    lastMessage: "Tap to start chatting",
                    lastUpdated: Date()
                )
                fetchedList.append(conversationItem)
            }
            DispatchQueue.main.async {
                self.conversations = fetchedList
                self.tableView.reloadData()
            }
        }
    }
}

extension MessagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath) as! ConversationCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        
        // ✅ Use SimpleChatViewController instead of ChatViewController
        let chatVC = SimpleChatViewController()
        chatVC.conversationId = conversation.id
        chatVC.otherUserId = conversation.otherUserId
        chatVC.otherUserName = conversation.otherUserName
        chatVC.title = conversation.otherUserName
        chatVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
