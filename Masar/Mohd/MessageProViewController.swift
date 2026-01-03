import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageProViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView! // تأكد من ربطه أو حذفه إذا لم يكن موجوداً
    
    private var conversations: [MessageConversation] = []
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // إخفاء البار العلوي في القائمة لإعطاء شكل نظيف
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // إزالة الخطوط الزائدة
        tableView.rowHeight = 80
    }
    
    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.conversations = []
                    self.tableView.reloadData()
                    return
                }
                
                var newConversations: [MessageConversation] = []
                let group = DispatchGroup()
                
                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let participants = data["participants"] as? [String] ?? []
                    
                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                            defer { group.leave() }
                            let userData = userSnap?.data()
                            let name = userData?["name"] as? String ?? "Unknown"
                            let email = userData?["email"] as? String ?? ""
                            
                            let lastMsg = data["lastMessage"] as? String ?? ""
                            let ts = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                            
                            let conv = MessageConversation(
                                id: conversationId,
                                otherUserId: otherUserId,
                                otherUserName: name,
                                otherUserEmail: email,
                                lastMessage: lastMsg,
                                lastUpdated: ts
                            )
                            newConversations.append(conv)
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // تأكد أن الـ Identifier في الستوري بورد هو "ConversationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        
        let conversation = conversations[indexPath.row]
        
        // 🔥 محاولة ضبط البيانات سواء كان كلاس مخصص أو عادي
        if let convCell = cell as? ConversationCell {
            convCell.configure(with: conversation)
        } else {
            // Fallback: إذا لم تكن الخلية مخصصة، نستخدم الإعدادات الافتراضية
            var content = cell.defaultContentConfiguration()
            content.text = conversation.otherUserName
            content.secondaryText = conversation.lastMessage
            content.image = UIImage(systemName: "person.circle.fill")
            content.imageProperties.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        
        // 🔥 الانتقال لنفس شاشة الشات الموحدة
        let chatVC = SimpleChatViewController()
        let otherUser = AppUser(
            id: conversation.otherUserId,
            name: conversation.otherUserName,
            email: conversation.otherUserEmail,
            phone: "",
            role: "seeker"
        )
        chatVC.otherUser = otherUser
        chatVC.conversationId = conversation.id
        chatVC.hidesBottomBarWhenPushed = true
        
        // إظهار البار العلوي عند الدخول للشات
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
