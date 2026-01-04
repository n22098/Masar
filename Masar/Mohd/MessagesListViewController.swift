import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MessagesListViewController: UIViewController {

    private let tableView = UITableView()
    private var conversations: [MessageConversation] = []
    private var providers: [AppUser] = []
    private var imageCache: [String: UIImage] = [:] // ✅ Cache for images

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
        startListeningForConversations(currentUid: currentUid)
    }

    private func startListeningForConversations(currentUid: String) {
        listener?.remove()
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents, !documents.isEmpty else {
                    self?.conversations = []
                    self?.fetchProvidersIfSeeker(currentUid: currentUid)
                    return
                }
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
            db.collection("users").document(otherUserId).getDocument { [weak self] snapshot, _ in
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
                
                // ✅ Load profile image immediately
                if let imageUrl = userData?["profileImageUrl"] as? String ?? userData?["imageName"] as? String {
                    self?.loadImage(from: imageUrl, for: otherUserId)
                }
            }
        }
        
        group.notify(queue: .main) {
            self.conversations = loadedConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
            self.providers = []
            self.tableView.reloadData()
        }
    }
    
    private func fetchProvidersIfSeeker(currentUid: String) {
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
        db.collection("users").whereField("role", isEqualTo: "provider").getDocuments { [weak self] snapshot, _ in
            guard let self = self, let documents = snapshot?.documents else { return }
            self.providers = documents.compactMap { doc -> AppUser? in
                if doc.documentID == currentUid { return nil }
                let data = doc.data()
                let imageUrl = data["profileImageUrl"] as? String ?? data["imageName"] as? String
                
                // ✅ Load provider images
                if let url = imageUrl {
                    self.loadImage(from: url, for: doc.documentID)
                }
                
                return AppUser(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Provider",
                    email: data["email"] as? String ?? "",
                    phone: "",
                    role: "provider",
                    profileImageName: imageUrl
                )
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    // ✅ Optimized image loading with caching
    private func loadImage(from urlString: String, for userId: String) {
        // Check cache first
        if imageCache[userId] != nil { return }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageCache[userId] = image
                    self?.tableView.reloadData()
                }
            }
        }.resume()
    }
}

extension MessagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !conversations.isEmpty ? conversations.count : providers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        
        if !conversations.isEmpty {
            let conv = conversations[indexPath.row]
            cell.configure(with: conv)
            
            // ✅ Use cached image
            if let cachedImage = imageCache[conv.otherUserId] {
                cell.setProfileImage(cachedImage)
            } else {
                cell.setProfileImage(UIImage(systemName: "person.circle.fill") ?? UIImage())
            }
        } else {
            let provider = providers[indexPath.row]
            let tempConv = MessageConversation(
                id: "",
                otherUserId: provider.id,
                otherUserName: provider.name,
                otherUserEmail: provider.email,
                lastMessage: "Start Chatting",
                lastUpdated: Date()
            )
            cell.configure(with: tempConv)
            
            // ✅ Use cached image
            if let cachedImage = imageCache[provider.id] {
                cell.setProfileImage(cachedImage)
            } else {
                cell.setProfileImage(UIImage(systemName: "person.circle.fill") ?? UIImage())
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = SimpleChatViewController()
        if !conversations.isEmpty {
            let conv = conversations[indexPath.row]
            chatVC.otherUser = AppUser(id: conv.otherUserId, name: conv.otherUserName, email: conv.otherUserEmail, phone: "")
            chatVC.conversationId = conv.id
        } else {
            chatVC.otherUser = providers[indexPath.row]
        }
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
