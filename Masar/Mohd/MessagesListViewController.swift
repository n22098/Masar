import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MessagesListViewController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView()
    // سنستخدم هذا المتغير لتخزين بيانات المزودين وعرضهم كأنهم محادثات
    private var conversations: [Conversation] = []
    
    private let db = Firestore.firestore()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupTableView()
        
        // استدعاء الدالة لجلب المزودين
        fetchAllProviders()
    }
    
    // MARK: - UI Setup

    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1) // اللون البنفسجي

        let titleLabel = UILabel()
        titleLabel.text = "Messages"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        tableView.rowHeight = 76

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Firebase Data Logic
    
    private func fetchAllProviders() {
        // التأكد من أن المستخدم مسجل دخول حتى لا نعرضه لنفسه (اختياري)
        let currentUid = Auth.auth().currentUser?.uid ?? ""

        // جلب جميع المستخدمين الذين لديهم الدور "provider"
        db.collection("users")
            .whereField("role", isEqualTo: "provider")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching providers: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No providers found")
                    return
                }

                var fetchedList: [Conversation] = []

                for doc in documents {
                    let data = doc.data()
                    let uid = data["uid"] as? String ?? doc.documentID
                    
                    // عدم عرض المستخدم لنفسه إذا كان هو أيضاً provider
                    if uid == currentUid { continue }

                    let name = data["name"] as? String ?? "Unknown Provider"
                    let email = data["email"] as? String ?? ""
                    let phone = data["phone"] as? String ?? ""
                    
                    // إنشاء كائن المستخدم
                    let providerUser = User(
                        id: uid,
                        name: name,
                        email: email,
                        phone: phone,
                        profileImageName: nil // يمكنك إضافة رابط الصورة إذا توفر في الفايربيس
                    )
                    
                    // إنشاء كائن محادثة وهمي لكي يظهر في القائمة
                    let conversationItem = Conversation(
                        id: uid, // نستخدم نفس ايدي المستخدم كـ ايدي للمحادثة مؤقتاً
                        user: providerUser,
                        lastMessage: "Tap to start chatting", // رسالة افتراضية
                        lastUpdated: Date()
                    )
                    
                    fetchedList.append(conversationItem)
                }

                DispatchQueue.main.async {
                    self.conversations = fetchedList
                    self.tableView.reloadData()
                    
                    // طباعة للتأكد في الكونسول
                    print("✅ Fetched \(fetchedList.count) providers from Firebase")
                }
            }
    }
}

// MARK: - Table Delegate

extension MessagesListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath) as! ConversationCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        
        // الانتقال لشاشة الشات عند الضغط
        let chatVC = ChatViewController(conversation: conversation)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
