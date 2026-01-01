import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Main View Controller
class MessageProViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    // MARK: - Properties
    // نستخدم MessageConversation الموجود في الملف الخارجي
    private var conversations: [MessageConversation] = []
    private let db = Firestore.firestore()
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🟣 [MessagePro] View did load")
        
        setupTableView()
        setupNavigationBar()
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupTableView() {
        if tableView != nil {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 80
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
            print("✅ [MessagePro] TableView configured from Storyboard")
        } else {
            print("⚠️ [MessagePro] TableView outlet not connected!")
        }
        
        emptyStateView?.isHidden = true
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Firebase
    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ [MessagePro] No logged in user")
            showEmptyState()
            return
        }
        
        print("🔍 [MessagePro] Listening for conversations for user: \(currentUid)")
        
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ [MessagePro] Error: \(error.localizedDescription)")
                    self.showEmptyState()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ [MessagePro] No snapshot documents")
                    self.showEmptyState()
                    return
                }
                
                print("📦 [MessagePro] Found \(documents.count) conversations")
                
                if documents.isEmpty {
                    self.showEmptyState()
                    self.conversations = []
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                    return
                }
                
                var newConversations: [MessageConversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let lastMessage = (data["lastMessage"] as? String) ?? (data["LastMessage"] as? String) ?? "Tap to start chatting"
                    let ts = (data["updatedAt"] as? Timestamp) ?? (data["lastUpdated"] as? Timestamp)
                    let date = ts?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []
                    
                    print("   📧 [MessagePro] Conversation: \(conversationId)")

                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        self.db.collection("users").document(otherUserId).getDocument { userSnap, error in
                            defer { group.leave() }
                            
                            if let error = error {
                                print("   ❌ [MessagePro] Error fetching user \(otherUserId): \(error.localizedDescription)")
                                return
                            }
                            
                            let name = userSnap?.data()?["name"] as? String ?? "Unknown User"
                            let email = userSnap?.data()?["email"] as? String ?? ""
                            print("   👤 [MessagePro] Found user: \(name)")
                            
                            let conversation = MessageConversation(
                                id: conversationId,
                                otherUserId: otherUserId,
                                otherUserName: name,
                                otherUserEmail: email,
                                lastMessage: lastMessage,
                                lastUpdated: date
                            )
                            newConversations.append(conversation)
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    print("✅ [MessagePro] Loaded \(self.conversations.count) conversations")
                    self.hideEmptyState()
                    self.tableView?.reloadData()
                }
            }
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        DispatchQueue.main.async {
            self.emptyStateView?.isHidden = false
            self.tableView?.isHidden = true
            print("📭 [MessagePro] Showing empty state")
        }
    }
    
    private func hideEmptyState() {
        DispatchQueue.main.async {
            self.emptyStateView?.isHidden = true
            self.tableView?.isHidden = false
            print("✅ [MessagePro] Hiding empty state")
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension MessageProViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = conversations.count
        print("📊 [MessagePro] Number of rows: \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell else {
            print("❌ [MessagePro] Failed to dequeue ConversationCell")
            return UITableViewCell()
        }
        
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation)
        
        print("   🔧 [MessagePro] Configured cell for: \(conversation.otherUserName)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversation = conversations[indexPath.row]
        print("👆 [MessagePro] Selected conversation with: \(conversation.otherUserName)")
        
        // ✅ الانتقال للشات - التعديل الجديد ليتوافق مع SimpleChatViewController
        let chatVC = SimpleChatViewController()
        
        // تحويل بيانات المحادثة إلى AppUser لتمريرها للشات
        let otherUser = AppUser(
            id: conversation.otherUserId,
            name: conversation.otherUserName,
            email: conversation.otherUserEmail,
            phone: "", // غير متوفرة هنا ولا نحتاجها في الشات
            role: "seeker" // افتراضي، سيتم تحديثه في الشات
        )
        
        chatVC.otherUser = otherUser
        chatVC.conversationId = conversation.id
        chatVC.title = conversation.otherUserName
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
