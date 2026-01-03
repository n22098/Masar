import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    private let bubbleView = UIView()
    private let playIconView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
    private let messageImageView = UIImageView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusImageView = UIImageView()
    var onImageTapped: ((UIImage) -> Void)?
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!
    
    private let outgoingColor = UIColor(red: 220/255, green: 248/255, blue: 198/255, alpha: 1) // أخضر واتساب ✅
    private let incomingColor = UIColor.white // أبيض ✅

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        playIconView.tintColor = .white
        playIconView.translatesAutoresizingMaskIntoConstraints = false
        playIconView.contentMode = .scaleAspectFit
        messageImageView.addSubview(playIconView)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.05
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowRadius = 1
        contentView.addSubview(bubbleView)

        messageImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageDidTap))
        messageImageView.addGestureRecognizer(tap)
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.clipsToBounds = true
        messageImageView.layer.cornerRadius = 12
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .gray

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.tintColor = .gray

        let stack = UIStackView(arrangedSubviews: [messageImageView, messageLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(stack)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(statusImageView)

        imageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: 200)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            stack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4),

            
            playIconView.centerXAnchor.constraint(equalTo: messageImageView.centerXAnchor),
                playIconView.centerYAnchor.constraint(equalTo: messageImageView.centerYAnchor),
                playIconView.widthAnchor.constraint(equalToConstant: 40),
                playIconView.heightAnchor.constraint(equalToConstant: 40),
            
            statusImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -6),
            statusImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            statusImageView.widthAnchor.constraint(equalToConstant: 15),
            statusImageView.heightAnchor.constraint(equalToConstant: 15),

            // ✅ الوقت داخل الفقاعة وفي الأسفل
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -6),
            timeLabel.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -4)
        ])

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }

    func configure(with message: Message, currentUserId: String) {
        let isMe = message.senderId == currentUserId
        bubbleView.backgroundColor = isMe ? outgoingColor : incomingColor
        leadingConstraint.isActive = !isMe
        trailingConstraint.isActive = isMe
        statusImageView.isHidden = !isMe

        let isVideo = message.imageURL?.contains(".mp4") ?? false
        playIconView.isHidden = !isVideo
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)

        // Reset image to avoid flickering during cell reuse
        messageImageView.image = nil

        if let imageURL = message.imageURL, !imageURL.isEmpty {
            messageImageView.isHidden = false
            imageHeightConstraint.isActive = true // Ensure the 200pt height is forced
            loadImage(from: imageURL)
        } else {
            messageImageView.isHidden = true
            imageHeightConstraint.isActive = false // Collapse the image area if no URL exists
        }
        
        // Handle text visibility
        messageLabel.text = message.text
        messageLabel.isHidden = (message.text == nil || message.text!.isEmpty)
        
        statusImageView.image = UIImage(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark")
        statusImageView.tintColor = message.isRead ? .systemBlue : .gray
        
        // IMPORTANT: Force the cell to recalculate its height
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    @objc private func imageDidTap() {
        // Check if we actually have an image to show
        guard let image = messageImageView.image else { return }
        onImageTapped?(image) // Send the image through the closure
    }
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.messageImageView.image = image }
        }.resume()
    }
}
