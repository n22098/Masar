import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageProViewController: UIViewController {

    // MARK: - Properties
    private let tableView = UITableView()
    private var conversations: [Conversation] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupHeader()
        setupTableView()
        startListeningForConversations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // listener?.remove() // ألغِ التعليق إذا أردت إيقاف التحديث عند الخروج
    }

    // MARK: - UI Setup
    private func setupHeader() {
        // تصميم الهيدر البنفسجي
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)

        let titleLabel = UILabel()
        titleLabel.text = "Incoming Messages"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor), // تغطية النوتش
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Firebase Logic
    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ Error: No user logged in")
            return
        }
        
        print("🔍 Fetching chats for UID: \(currentUid)")

        // الاستماع لمجموعة المحادثات
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching conversations: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                
                print("✅ Found \(documents.count) conversations")

                var newConversations: [Conversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let lastMessageText = data["lastMessage"] as? String ?? ""
                    let timestamp = data["lastUpdated"] as? Timestamp
                    let lastUpdatedDate = timestamp?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []

                    // البحث عن معرف الطرف الآخر (الذي ليس أنا)
                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        
                        // جلب بيانات المستخدم من جدول users
                        self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                            defer { group.leave() }
                            
                            var userName = "Unknown User"
                            var userEmail = ""
                            var userPhone = ""
                            var userImage: String? = nil
                            
                            // مطابقة الحقول مع الصورة التي أرسلتها
                            if let userData = userSnap?.data() {
                                userName = userData["name"] as? String ?? "Unknown"
                                userEmail = userData["email"] as? String ?? ""
                                userPhone = userData["phone"] as? String ?? ""
                                // الصورة قد تكون غير موجودة في الداتابيس
                                userImage = userData["profileImage"] as? String
                            } else {
                                print("⚠️ User document not found for ID: \(otherUserId)")
                            }
                            
                            let otherUser = User(
                                id: otherUserId,
                                name: userName,
                                email: userEmail,
                                phone: userPhone,
                                profileImageName: userImage
                            )
                            
                            let conversation = Conversation(
                                id: conversationId,
                                user: otherUser,
                                lastMessage: lastMessageText,
                                lastUpdated: lastUpdatedDate
                            )
                            newConversations.append(conversation)
                        }
                    }
                }

                group.notify(queue: .main) {
                    // ترتيب المحادثات: الأحدث في الأعلى
                    self.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - TableView Extensions
extension MessageProViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversation = conversations[indexPath.row]
        
        // هنا يتم الانتقال لصفحة الشات التفصيلية
        // تأكد أن ChatViewController يستقبل كائن User أو Conversation
        // let chatVC = ChatViewController(user: conversation.user)
        // navigationController?.pushViewController(chatVC, animated: true)
        
        print("Selected chat with: \(conversation.user.name)")
    }
}
