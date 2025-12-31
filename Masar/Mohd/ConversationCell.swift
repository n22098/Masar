//
//  ConversationCell.swift
//  Masar
//
//  Created by BP-36-212-19 on 11/12/2025.
//

import UIKit

final class ConversationCell: UITableViewCell {

    static let reuseIdentifier = "ConversationCell"

    // MARK: - UI Components (Programmatic)
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - UI Components (Storyboard - Optional)
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var nameLabelOutlet: UILabel?
    @IBOutlet weak var lastMessageLabel: UILabel?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        setupProgrammaticViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Storyboard mode - UI already setup
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup for Storyboard mode
        profileImageView?.layer.cornerRadius = 30
        profileImageView?.clipsToBounds = true
    }

    // MARK: - Setup (Programmatic)
    private func setupProgrammaticViews() {
        selectionStyle = .none

        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.font = UIFont.systemFont(ofSize: 32)
        contentView.addSubview(avatarLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        contentView.addSubview(nameLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        contentView.addSubview(subtitleLabel)

        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel
        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            avatarLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            subtitleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1)
        ])
    }

    // MARK: - Configure
    // ✅ Use MessageConversation instead of Conversation
    func configure(with conversation: MessageConversation) {
        // Check if using Storyboard outlets or programmatic views
        if let profileImageView = profileImageView,
           let nameLabelOutlet = nameLabelOutlet,
           let lastMessageLabel = lastMessageLabel {
            // Storyboard mode
            nameLabelOutlet.text = conversation.otherUserName
            lastMessageLabel.text = conversation.lastMessage
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        } else {
            // Programmatic mode
            nameLabel.text = conversation.otherUserName
            subtitleLabel.text = conversation.lastMessage
            avatarLabel.text = "👤"
        }
    }
}
