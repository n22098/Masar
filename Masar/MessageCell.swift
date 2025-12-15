
//
//  MessageCell.swift
//  Masar
//
//  Created by BP-36-212-19 on 11/12/2025.
//

import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

   //user chat settings and spacing
    private func setupViews() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        bubbleView.addSubview(messageLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        contentView.addSubview(timeLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
//below is spacing
        messageLabel.setContentHuggingPriority(.required, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            leadingConstraint,
            trailingConstraint,

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),

            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2)
        ])
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }

    func configure(with message: Message) {
        messageLabel.text = message.text

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if message.isIncoming {
            leadingConstraint.isActive = true
        } else {
            trailingConstraint.isActive = true
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        timeLabel.text = formatter.string(from: message.date).lowercased()

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if message.isIncoming {
            bubbleView.backgroundColor = UIColor(red: 218/255, green: 245/255, blue: 189/255, alpha: 1)
            leadingConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = .white
            bubbleView.layer.borderColor = UIColor.systemGray4.cgColor
            bubbleView.layer.borderWidth = 1
            trailingConstraint.isActive = true
        }
    }

}
