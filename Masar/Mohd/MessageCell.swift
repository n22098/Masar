import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    // UI Components
    private let bubbleView = UIView()
    private let messageImageView = UIImageView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    // Constraints
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private let imageCache = NSCache<NSString, UIImage>()

    // WhatsApp Colors
    private let outgoingColor = UIColor(red: 220/255, green: 248/255, blue: 198/255, alpha: 1) // Green
    private let incomingColor = UIColor.white

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        // --- Bubble Setup ---
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 12
        // Shadow for depth (like WhatsApp)
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.1
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowRadius = 1
        contentView.addSubview(bubbleView)

        // --- Image View Setup ---
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFill // Fill to look nice
        messageImageView.clipsToBounds = true
        messageImageView.layer.cornerRadius = 8
        messageImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        messageImageView.addGestureRecognizer(tap)
        messageImageView.isHidden = true
        
        // --- Message Text Setup ---
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .black

        // --- Time Label Setup ---
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .darkGray
        timeLabel.textAlignment = .right
        
        // --- Stack View ---
        // نضع النص والصورة والوقت داخل Stack لترتيبهم
        let stack = UIStackView(arrangedSubviews: [messageImageView, messageLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        bubbleView.addSubview(stack)

        // --- Layout Constraints ---
        NSLayoutConstraint.activate([
            // Bubble vertically
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            // Max width 75% of screen
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            // Image height limit
            messageImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Stack padding inside bubble
            stack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
        ])

        // Constraints for Left/Right alignment
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageImageView.image = nil
        messageImageView.isHidden = true
        messageLabel.text = nil
        timeLabel.text = nil
    }

    func configure(with message: Message, currentUserId: String) {
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        let isIncoming = message.senderId != currentUserId

        if isIncoming {
            // Incoming (Them): White bubble, aligned Left
            bubbleView.backgroundColor = incomingColor
            leadingConstraint.isActive = true
        } else {
            // Outgoing (Me): Green bubble, aligned Right
            bubbleView.backgroundColor = outgoingColor
            trailingConstraint.isActive = true
        }

        // Set Time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 10:30
        timeLabel.text = formatter.string(from: message.timestamp)

        // Set Content (Image or Text)
        if let imageURL = message.imageURL, !imageURL.isEmpty {
            messageLabel.isHidden = true
            messageImageView.isHidden = false
            loadImage(from: imageURL)
        } else {
            messageImageView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message.text
        }
    }

    private func loadImage(from urlString: String) {
        if let cached = imageCache.object(forKey: urlString as NSString) {
            messageImageView.image = cached
            return
        }

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.imageCache.setObject(image, forKey: urlString as NSString)
                self.messageImageView.image = image
            }
        }.resume()
    }
    
    @objc private func imageTapped() {
        guard let image = messageImageView.image else { return }
        let vc = ImagePreviewViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.image = image
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(vc, animated: true)
        }
    }
}
