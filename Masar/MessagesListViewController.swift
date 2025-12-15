//
//  MessagesListViewController.swift
//  Masar
//
//  Created by BP-36-212-19 on 11/12/2025.
//

import UIKit

final class MessagesListViewController: UIViewController, UITableViewDelegate {


    
    private let tableView = UITableView()
    private var conversations: [Conversation] = []
    
    
    private let headerView = UIView()
    private let headerTitleLabel = UILabel()

    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()

    private let containerView = UIView()

    private let user = User(
        id: UUID(),
        name: "Sayed Husain",
        subtitle: "Software Engineer",
        avatarEmoji: "👨🏻"
    )


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupContent()
    }
    
    
    private func loadMockData() {
        conversations = [
            Conversation(
                id: UUID(),
                user: User(id: UUID(), name: "Sayed Husain", subtitle: "Software Engineer", avatarEmoji: "👨🏻"),
                lastMessage: "Sure, send me your requirements",
                lastUpdated: Date()
            ),
            Conversation(
                id: UUID(),
                user: User(id: UUID(), name: "Aisha Noor", subtitle: "UI Designer", avatarEmoji: "👩🏽‍🎨"),
                lastMessage: "I’ll update the Figma today",
                lastUpdated: Date()
            ),
            Conversation(
                id: UUID(),
                user: User(id: UUID(), name: "Omar Khalid", subtitle: "Backend Developer", avatarEmoji: "👨🏾‍💻"),
                lastMessage: "API is ready",
                lastUpdated: Date()
            )
        ]
    }


    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1.0)
        view.addSubview(headerView)

        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerTitleLabel.text = "Messages"
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        headerView.addSubview(headerTitleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 64),

            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    private func setupContent() {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        view.addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.isUserInteractionEnabled = true
        backgroundView.addSubview(containerView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(openChat))
        containerView.addGestureRecognizer(tap)

        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.text = user.avatarEmoji
        avatarLabel.font = UIFont.systemFont(ofSize: 36)
        containerView.addSubview(avatarLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        containerView.addSubview(nameLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = user.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        containerView.addSubview(subtitleLabel)

        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel
        containerView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 72),

            avatarLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),

            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -1),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 1),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8)
        ])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let conversation = conversations[indexPath.row]

            let chatVC = ChatViewController(
                user: conversation.user,
                messages: []
            )

            navigationController?.pushViewController(chatVC, animated: true)
        }

    @objc private func openChat() {
        let messages: [Message] = [
            Message(id: UUID(), text: "Hello, I need to create a website for my work", isIncoming: true, date: Date()),
            Message(id: UUID(), text: """
Sure, send me your requirement details
and I will help you with my template
or create new one if you have
specific design
""", isIncoming: false, date: Date()),
            Message(id: UUID(), text: "Ok Thanks, I will send you after a few hours", isIncoming: true, date: Date()),
            Message(id: UUID(), text: "Thanks!", isIncoming: false, date: Date())
            
        ]

        let chatVC = ChatViewController(user: user, messages: messages)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
