import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let messageImageView = UIImageView()
    private let timeLabel = UILabel()
    private let contentStack = UIStackView()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var imageAspectConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.masksToBounds = true
        contentView.addSubview(bubbleView)

        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(contentStack)

        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)

        messageImageView.contentMode = .scaleAspectFill
        messageImageView.clipsToBounds = true
        messageImageView.layer.cornerRadius = 14
        messageImageView.isHidden = true

        contentStack.addArrangedSubview(messageImageView)
        contentStack.addArrangedSubview(messageLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        contentView.addSubview(timeLabel)

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            contentStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            contentStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),

            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    func configure(with message: Message, currentUserId: String) {
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        let isIncoming = message.senderId != currentUserId

        if isIncoming {
            bubbleView.backgroundColor = UIColor(red: 218/255, green: 245/255, blue: 189/255, alpha: 1)
            leadingConstraint.isActive = true
        } else {
            bubbleView.backgroundColor = .white
            bubbleView.layer.borderColor = UIColor.systemGray4.cgColor
            bubbleView.layer.borderWidth = 1
            trailingConstraint.isActive = true
        }

        if let imageURL = message.imageURL {
            messageLabel.isHidden = true
            messageImageView.isHidden = false
            loadImage(from: imageURL)
        } else {
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
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.messageImageView.image = image

                self.imageAspectConstraint?.isActive = false
                let ratio = image.size.height / image.size.width
                self.imageAspectConstraint = self.messageImageView.heightAnchor
                    .constraint(equalTo: self.messageImageView.widthAnchor, multiplier: ratio)
                self.imageAspectConstraint?.isActive = true
            }
        }.resume()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset content
        messageLabel.text = nil
        messageImageView.image = nil

        // Reset visibility
        messageLabel.isHidden = false
        messageImageView.isHidden = true

        // Remove previous aspect ratio constraint
        imageAspectConstraint?.isActive = false
        imageAspectConstraint = nil

        // Reset bubble appearance
        bubbleView.backgroundColor = .clear
        bubbleView.layer.borderWidth = 0

        // Reset constraints
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }

}
