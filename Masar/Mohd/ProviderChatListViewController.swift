//
//  ProviderChatListViewController.swift
//  Masar
//
//  Created by BP-36-212-13 on 31/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class ProviderChatListViewController: UIViewController {

    private let tableView = UITableView()
    private var conversations: [Conversation] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupTableView()
        
        // Providers only need to see active conversations they are participating in
        if let currentUid = Auth.auth().currentUser?.uid {
            startListeningForProviderConversations(currentUid: currentUid)
        }
    }

    private func setupNavigationBar() {
        title = "Client Messages" // Distinct title for Provider view

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Using your specific purple: RGB (96, 84, 234)
        appearance.backgroundColor = UIColor(red: 96/255, green: 84/255, blue: 234/255, alpha: 1)

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = titleAttributes
        appearance.titleTextAttributes = titleAttributes

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        tableView.rowHeight = 76
        tableView.tableFooterView = UIView() // Cleans up empty lines

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor), // Bleed color under nav bar
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func startListeningForProviderConversations(currentUid: String) {
        // Querying conversations where the provider is a participant
        listener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }

                var loadedConversations: [Conversation] = []
                let group = DispatchGroup()

                for doc in documents {
                    let data = doc.data()
                    let conversationId = doc.documentID
                    let participants = data["participants"] as? [String] ?? []
                    
                    guard let clientId = participants.first(where: { $0 != currentUid }) else { continue }

                    group.enter()
                    self.db.collection("users").document(clientId).getDocument { userSnap, _ in
                        defer { group.leave() }

                        let userData = userSnap?.data()
                        let clientUser = User(
                            id: clientId,
                            name: userData?["name"] as? String ?? "Client",
                            email: userData?["email"] as? String ?? "",
                            phone: userData?["phone"] as? String ?? "",
                            profileImageName: userData?["profileImage"] as? String
                        )

                        let conv = Conversation(
                            id: conversationId,
                            user: clientUser,
                            lastMessage: data["lastMessage"] as? String ?? "",
                            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        loadedConversations.append(conv)
                    }
                }

                group.notify(queue: .main) {
                    self.conversations = loadedConversations.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - TableView Extensions
extension ProviderChatListViewController: UITableViewDataSource, UITableViewDelegate {
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
        let chatVC = ChatViewController(conversation: conversations[indexPath.row])
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
