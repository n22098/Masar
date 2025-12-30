import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessageProViewController: UIViewController {

    private let tableView = UITableView()
    private var conversations: [Conversation] = []
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. تغيير لون الخلفية للتأكد أن الكود يعمل
        view.backgroundColor = .systemBackground
        
        print("🟣 تم تحميل MessageProViewController بنجاح")
        
        setupHeader()
        setupTableView()
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 2. إخفاء العنوان الأسود الكبير (System Navigation Bar)
        navigationController?.isNavigationBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // إعادة إظهاره عند الخروج من الصفحة
        navigationController?.isNavigationBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // --- بقية الكود (تصميم الهيدر والجدول) ---
    
    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1) // لون بنفسجي

        let titleLabel = UILabel()
        titleLabel.text = "Incoming Messages" // العنوان الجديد
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
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
        tableView.rowHeight = 80
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func startListeningForConversations() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                var newConversations: [Conversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let lastMessage = (data["lastMessage"] as? String) ?? (data["LastMessage"] as? String) ?? ""
                    let ts = (data["updatedAt"] as? Timestamp) ?? (data["lastUpdated"] as? Timestamp)
                    let date = ts?.dateValue() ?? Date()
                    let participants = data["participants"] as? [String] ?? []

                    if let otherUserId = participants.first(where: { $0 != currentUid }) {
                        group.enter()
                        self?.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                            defer { group.leave() }
                            let name = userSnap?.data()?["name"] as? String ?? "Unknown"
                            let user = User(id: otherUserId, name: name, email: "", phone: "", profileImageName: nil)
                            newConversations.append(Conversation(id: conversationId, user: user, lastMessage: lastMessage, lastUpdated: date))
                        }
                    }
                }

                group.notify(queue: .main) {
                    self?.conversations = newConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self?.tableView.reloadData()
                }
            }
    }
}

extension MessageProViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { conversations.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController(conversation: conversations[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
