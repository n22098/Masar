import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderMessagesTableViewController: UITableViewController {

    // MARK: - Properties
    // نستخدم المودل الجديد MessageConversation الذي وضعناه في ملف منفصل
    private var conversations: [MessageConversation] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPurpleDesign()
        
        // تسجيل الخلية
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .systemBackground
        
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selection, animated: true)
        }
    }
    
    deinit {
        listener?.remove()
    }

    // MARK: - UI Design
    private func setupPurpleDesign() {
        title = "Messages"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // اللون البنفسجي
        appearance.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
    }

    // MARK: - Firebase Logic
    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // جلب المحادثات التي يكون البروفايدر طرفاً فيها
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching conversations: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.conversations = []
                    self.tableView.reloadData()
                    return
                }
               
                var newConversations: [MessageConversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    
                    let lastMessageText = (data["lastMessage"] as? String) ?? (data["LastMessage"] as? String) ?? ""
                    let ts = (data["updatedAt"] as? Timestamp) ?? (data["lastUpdated"] as? Timestamp)
                    let lastUpdatedDate = ts?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []

                    // البحث عن الطرف الآخر (السيكر)
                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        
                        self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                            defer { group.leave() }
                            
                            var userName = "Unknown User"
                            var userEmail = ""
                            
                            if let userData = userSnap?.data() {
                                userName = userData["name"] as? String ?? "Unknown"
                                userEmail = userData["email"] as? String ?? ""
                            }
                            
                            let conversation = MessageConversation(
                                id: conversationId,
                                otherUserId: otherUserId,
                                otherUserName: userName,
                                otherUserEmail: userEmail,
                                lastMessage: lastMessageText,
                                lastUpdated: lastUpdatedDate
                            )
                            newConversations.append(conversation)
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation)
        return cell
    }

    // MARK: - Navigation (FIXED)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        
        let chatVC = SimpleChatViewController()
        
        // 🛠 التعديل هنا:
        // بما أن الشات يتوقع (AppUser)، سنقوم بإنشاء كائن مؤقت من البيانات المتوفرة لدينا
        let otherUser = AppUser(
            id: conversation.otherUserId,
            name: conversation.otherUserName,
            email: conversation.otherUserEmail,
            phone: "", // لا نحتاجه في الشات
            role: "seeker" // نفترض أنه باحث لأننا في شاشة البروفايدر
        )
        
        // تمرير البيانات بالطريقة الجديدة
        chatVC.otherUser = otherUser
        chatVC.conversationId = conversation.id
        
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
