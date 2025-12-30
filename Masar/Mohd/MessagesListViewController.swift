import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MessagesListViewController: UIViewController {

    private let tableView = UITableView()
    private var conversations: [Conversation] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("✅ MessagesListViewController OPENED")   // مهم حتى نتأكد هذا الـVC هو اللي ينفتح
        view.backgroundColor = .systemBackground

        setupHeader()
        setupTableView()

        loadMessagesScreen()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // listener?.remove()
    }

    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)

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

    // MARK: - Role based loading (provider -> conversations, seeker -> providers)

    private func loadMessagesScreen() {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }

        // نحاول نجيب role بأكثر من طريقة (حتى لو docID مو هو uid)
        resolveUserRole(currentUid: currentUid) { [weak self] role in
            guard let self = self else { return }
            print("👤 role = \(role)")

            if role.lowercased() == "provider" {
                self.startListeningForConversations(currentUid: currentUid)
            } else {
                self.fetchAllProviders() // نفس منطقك القديم للسيكر
            }
        }
    }

    private func resolveUserRole(currentUid: String, completion: @escaping (String) -> Void) {
        // 1) إذا docID = uid
        db.collection("users").document(currentUid).getDocument { [weak self] doc, _ in
            if let data = doc?.data() {
                let role =
                    (data["role"] as? String) ??
                    (data["Role"] as? String) ??
                    (data["userType"] as? String) ??
                    (data["type"] as? String) ?? ""
                if !role.isEmpty {
                    completion(role)
                    return
                }
            }

            guard let self = self else { return }

            // 2) إذا uid مخزون كحقل
            self.db.collection("users")
                .whereField("uid", isEqualTo: currentUid)
                .limit(to: 1)
                .getDocuments { snap, _ in
                    if let data = snap?.documents.first?.data() {
                        let role =
                            (data["role"] as? String) ??
                            (data["Role"] as? String) ??
                            (data["userType"] as? String) ??
                            (data["type"] as? String) ?? ""
                        completion(role)
                    } else {
                        completion("") // ما لقينا role
                    }
                }
        }
    }

    // MARK: - Provider: listen conversations

    private func startListeningForConversations(currentUid: String) {
        print("🔍 Provider: Fetching conversations for UID: \(currentUid)")

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

                    let lastMessageText =
                        (data["lastMessage"] as? String) ??
                        (data["LastMessage"] as? String) ?? ""

                    let ts =
                        (data["lastUpdated"] as? Timestamp) ??
                        (data["updatedAt"] as? Timestamp)

                    let lastUpdatedDate = ts?.dateValue() ?? Date()

                    let participants = data["participants"] as? [String] ?? []
                    guard let otherUserId = participants.first(where: { $0 != currentUid }) else { continue }

                    group.enter()
                    self.db.collection("users").document(otherUserId).getDocument { userSnap, _ in
                        defer { group.leave() }

                        var userName = "Unknown"
                        var userEmail = ""
                        var userPhone = ""
                        var userImage: String? = nil

                        if let userData = userSnap?.data() {
                            userName = userData["name"] as? String ?? "Unknown"
                            userEmail = userData["email"] as? String ?? ""
                            userPhone = userData["phone"] as? String ?? ""
                            userImage = userData["profileImage"] as? String
                        }

                        let otherUser = User(
                            id: otherUserId,
                            name: userName,
                            email: userEmail,
                            phone: userPhone,
                            profileImageName: userImage
                        )

                        let conv = Conversation(
                            id: conversationId,
                            user: otherUser,
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

    // MARK: - Seeker: your original providers list

    private func fetchAllProviders() {
        let currentUid = Auth.auth().currentUser?.uid ?? ""

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
                    if uid == currentUid { continue }

                    let name = data["name"] as? String ?? "Unknown Provider"
                    let email = data["email"] as? String ?? ""
                    let phone = data["phone"] as? String ?? ""

                    let providerUser = User(
                        id: uid,
                        name: name,
                        email: email,
                        phone: phone,
                        profileImageName: nil
                    )

                    let conversationItem = Conversation(
                        id: uid,
                        user: providerUser,
                        lastMessage: "Tap to start chatting",
                        lastUpdated: Date()
                    )

                    fetchedList.append(conversationItem)
                }

                DispatchQueue.main.async {
                    self.conversations = fetchedList
                    self.tableView.reloadData()
                    print("✅ Fetched \(fetchedList.count) providers from Firebase")
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
        let chatVC = ChatViewController(conversation: conversation)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
