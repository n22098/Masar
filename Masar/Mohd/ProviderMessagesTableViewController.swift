import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderMessagesTableViewController: UITableViewController {

    // MARK: - Properties (المتغيرات)
    private var conversations: [MessageConversation] = []  // ✅ Changed to MessageConversation
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle (دورة حياة الشاشة)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. تطبيق تصميم الهيدر البنفسجي
        setupPurpleDesign()
        
        // 2. إعدادات الجدول
        // تسجيل الخلية (تأكد أن ConversationCell موجود في مشروعك)
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0) // هامش للخط الفاصل
        tableView.tableFooterView = UIView() // إزالة الخطوط الفارغة في الأسفل
        tableView.backgroundColor = .systemBackground
        
        // 3. بدء الاستماع للرسائل من الفايربيس
        startListeningForConversations()
    }
    
    // عند العودة للشاشة، نقوم بإلغاء تحديد الصف لجمالية التصميم
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selection = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selection, animated: true)
        }
    }
    
    // إزالة المستمع عند إغلاق الشاشة لتوفير الذاكرة
    deinit {
        listener?.remove()
    }

    // MARK: - UI Design (تصميم الهيدر)
    private func setupPurpleDesign() {
        title = "Messages"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // اللون البنفسجي الخاص بتطبيقك (RGB: 112, 79, 217)
        appearance.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        
        // جعل لون العنوان أبيض
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // تطبيق الإعدادات على النافيجيشن بار
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // جعل لون زر الرجوع (Back Button) أبيض
        navigationController?.navigationBar.tintColor = .white
        
        // جعل الـ Status Bar (أيقونات البطارية والساعة) باللون الأبيض
        navigationController?.navigationBar.barStyle = .black
    }

    // MARK: - Firebase Logic (جلب البيانات)
    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ Error: No user logged in")
            return
        }
        
        print("🔍 Fetching conversations for UID: \(currentUid)")
        
        // الاستعلام: هات أي محادثة أنا مشارك فيها (سواء كنت سيكر أو بروفايدر)
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching conversations: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No conversations found")
                    self.conversations = []
                    self.tableView.reloadData()
                    return
                }
               
                var newConversations: [MessageConversation] = []  // ✅ Changed
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    
                    // قراءة آخر رسالة (يدعم الحروف الكبيرة والصغيرة في التسمية)
                    let lastMessageText = (data["lastMessage"] as? String) ?? (data["LastMessage"] as? String) ?? ""
                    
                    // قراءة الوقت
                    let ts = (data["updatedAt"] as? Timestamp) ?? (data["lastUpdated"] as? Timestamp)
                    let lastUpdatedDate = ts?.dateValue() ?? Date()
                    
                    let participants = data["participants"] as? [String] ?? []

                    // المنطق: البحث عن الـ ID المختلف عني (الطرف الآخر)
                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        
                        // جلب بيانات الطرف الآخر (الاسم والصورة)
                        self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                            defer { group.leave() }
                            
                            var userName = "Unknown User"
                            var userEmail = ""
                            
                            if let userData = userSnap?.data() {
                                userName = userData["name"] as? String ?? "Unknown"
                                userEmail = userData["email"] as? String ?? ""
                            }
                            
                            // ✅ Create MessageConversation instead of Conversation
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

                // بعد اكتمال جلب كل الأسماء، نحدث الجدول
                group.notify(queue: .main) {
                    // ترتيب المحادثات: الأحدث في الأعلى
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                    print("✅ TableView reloaded with \(self.conversations.count) conversations")
                }
            }
    }

    // MARK: - Table view data source (إعدادات الجدول)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }
        
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation) // تأكد أن دالة configure تدعم تحميل الصورة
        return cell
    }

    // MARK: - Navigation (الانتقال للشات)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        
        // ✅ Use SimpleChatViewController instead of ChatViewController
        let chatVC = SimpleChatViewController()
        chatVC.conversationId = conversation.id
        chatVC.otherUserId = conversation.otherUserId
        chatVC.otherUserName = conversation.otherUserName
        chatVC.title = conversation.otherUserName
        
        // إخفاء التبويب السفلي ليعطي مساحة أكبر للشات
        chatVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
