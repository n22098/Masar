import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"
   //uikit display image
    private let messageImageView = UIImageView()

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

    private func setupViews() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        bubbleView.addSubview(messageLabel)
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.layer.cornerRadius = 14
        messageImageView.clipsToBounds = true
        messageImageView.isHidden = true
        bubbleView.addSubview(messageImageView)


        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        contentView.addSubview(timeLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            
                messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
                messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
                messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
                messageImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 220),
            

            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    func configure(with message: Message, currentUserId: String) {

        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        let isIncoming = message.senderId != currentUserId

        // Alignment & color
        if isIncoming {
            bubbleView.backgroundColor = UIColor(
                red: 218/255,
                green: 245/255,
                blue: 189/255,
                alpha: 1
            )
            bubbleView.layer.borderWidth = 0
            leadingConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = .white
            bubbleView.layer.borderColor = UIColor.systemGray4.cgColor
            bubbleView.layer.borderWidth = 1
            trailingConstraint.isActive = true
        }

        // IMAGE MESSAGE
        if let imageURL = message.imageURL {
            messageLabel.isHidden = true
            messageImageView.isHidden = false
            loadImage(from: imageURL)
        }
        // TEXT MESSAGE
        else {
            messageImageView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message.text
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        timeLabel.text = formatter.string(from: message.timestamp).lowercased()
    }
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self?.messageImageView.image = image
            }
        }.resume()
    }


}
