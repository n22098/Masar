import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MessagesListViewController: UIViewController {

    private let tableView = UITableView()
    // نستخدم MessageConversation المعرف في ملف خارجي
    private var conversations: [MessageConversation] = []
    // نستخدم AppUser
    private var providers: [AppUser] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        setupNavigationBar()
        setupTableView()
        loadMessagesScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selection, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Messages"
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 80
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadMessagesScreen() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // جلب المحادثات أولاً
        startListeningForConversations(currentUid: currentUid)
    }

    private func startListeningForConversations(currentUid: String) {
        listener?.remove()
        
        // استمع للمحادثات
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    // لا توجد محادثات؟ اعرض البروفايدرز إذا كان المستخدم Seeker
                    self.conversations = []
                    self.fetchProvidersIfSeeker(currentUid: currentUid)
                    return
                }
                
                // معالجة المحادثات
                self.processConversations(documents: documents, currentUid: currentUid)
            }
    }
    
    private func processConversations(documents: [QueryDocumentSnapshot], currentUid: String) {
        var loadedConversations: [MessageConversation] = []
        let group = DispatchGroup()

        for doc in documents {
            let data = doc.data()
            let participants = data["participants"] as? [String] ?? []
            guard let otherUserId = participants.first(where: { $0 != currentUid }) else { continue }

            group.enter()
            db.collection("users").document(otherUserId).getDocument { snapshot, _ in
                defer { group.leave() }
                let userData = snapshot?.data()
                let name = userData?["name"] as? String ?? "Unknown"
                let email = userData?["email"] as? String ?? ""
                
                let lastMsg = data["lastMessage"] as? String ?? "Chat"
                let ts = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                
                let conv = MessageConversation(
                    id: doc.documentID,
                    otherUserId: otherUserId,
                    otherUserName: name,
                    otherUserEmail: email,
                    lastMessage: lastMsg,
                    lastUpdated: ts
                )
                loadedConversations.append(conv)
            }
        }
        
        group.notify(queue: .main) {
            self.conversations = loadedConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
            self.providers = [] // إخفاء البروفايدرز لأن لدينا محادثات
            self.tableView.reloadData()
        }
    }
    
    private func fetchProvidersIfSeeker(currentUid: String) {
        // التحقق من أن المستخدم ليس بروفايدر
        db.collection("users").document(currentUid).getDocument { snapshot, _ in
            let role = snapshot?.data()?["role"] as? String ?? "seeker"
            if role != "provider" {
                self.fetchAllProviders(currentUid: currentUid)
            } else {
                self.tableView.reloadData()
            }
        }
    }

    private func fetchAllProviders(currentUid: String) {
        db.collection("users").whereField("role", isEqualTo: "provider").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            self.providers = documents.compactMap { doc -> AppUser? in
                if doc.documentID == currentUid { return nil }
                let data = doc.data()
                return AppUser(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Provider",
                    email: data["email"] as? String ?? "",
                    phone: "", role: "provider"
                )
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
}

extension MessagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !conversations.isEmpty ? conversations.count : providers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        
        if !conversations.isEmpty {
            cell.configure(with: conversations[indexPath.row])
        } else {
            // عرض البروفايدر كأنه محادثة فارغة
            let provider = providers[indexPath.row]
            // ✅ تم الإصلاح: تمرير نص فارغ "" بدلاً من nil
            let tempConv = MessageConversation(
                id: "",
                otherUserId: provider.id,
                otherUserName: provider.name,
                otherUserEmail: provider.email,
                lastMessage: "Start Chatting",
                lastUpdated: Date()
            )
            cell.configure(with: tempConv)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatVC = SimpleChatViewController()
        var targetUser: AppUser
        var convId: String?
        
        if !conversations.isEmpty {
            let conv = conversations[indexPath.row]
            targetUser = AppUser(id: conv.otherUserId, name: conv.otherUserName, email: conv.otherUserEmail, phone: "")
            convId = conv.id
        } else {
            targetUser = providers[indexPath.row]
            convId = nil
        }
        
        // تمرير البيانات للشات
        chatVC.otherUser = targetUser
        chatVC.conversationId = convId
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
