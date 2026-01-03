import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    // UI Components
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let messageImageView = UIImageView()
    private let timeLabel = UILabel()
    private let statusImageView = UIImageView() // ✅ علامة الصحين

    // Constraints
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    // WhatsApp Colors
    private let outgoingColor = UIColor(red: 0.86, green: 0.97, blue: 0.77, alpha: 1.0) // #DCF8C6
    private let incomingColor = UIColor.white

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // 1. Bubble
        bubbleView.layer.cornerRadius = 12
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.1
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowRadius = 1
        contentView.addSubview(bubbleView)

        // 2. Image View (للصور)
        messageImageView.layer.cornerRadius = 8
        messageImageView.clipsToBounds = true
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.isHidden = true
        bubbleView.addSubview(messageImageView)

        // 3. Message Text
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)

        // 4. Time Label
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(timeLabel)

        // 5. Status Icon (Ticks)
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(statusImageView)

        // --- Constraints ---
        NSLayoutConstraint.activate([
            // Bubble Vertical
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),

            // Image
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5),
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 5),
            messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -5),
            messageImageView.heightAnchor.constraint(equalToConstant: 200), // ارتفاع ثابت للصورة

            // Label (تحت الصورة إن وجدت)
            messageLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 5),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            
            // Time & Status (أسفل يمين الفقاعة)
            statusImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -5),
            statusImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -5),
            statusImageView.widthAnchor.constraint(equalToConstant: 16),
            statusImageView.heightAnchor.constraint(equalToConstant: 16),
            
            timeLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -2),
            
            // ربط أسفل النص بأعلى الوقت لضمان تمدد الفقاعة
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: timeLabel.topAnchor, constant: -2)
        ])

        // Constraints for alignment (Left/Right)
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }

    func configure(with message: Message, currentUserId: String) {
        let isMe = message.senderId == currentUserId

        // إعادة ضبط القيود للصورة والنص
        if let imageURL = message.imageURL, !imageURL.isEmpty {
            messageImageView.isHidden = false
            loadImage(url: imageURL)
            // إذا كانت صورة، نقلل المسافات
        } else {
            messageImageView.isHidden = true
            messageImageView.image = nil
        }

        // إعداد النص
        messageLabel.text = message.text
        // إذا لم يكن هناك نص (فقط صورة)، نخفي الليبل لتقليل المساحة
        messageLabel.isHidden = (message.text == nil || message.text == "")

        // الألوان والمحاذاة
        if isMe {
            bubbleView.backgroundColor = outgoingColor
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            statusImageView.isHidden = false
        } else {
            bubbleView.backgroundColor = incomingColor
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            statusImageView.isHidden = true
        }

        // الوقت
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)

        // حالة القراءة (الصحين)
        let config = UIImage.SymbolConfiguration(weight: .bold)
        if message.isRead {
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config) // أزرق
            statusImageView.tintColor = .systemBlue
        } else {
            statusImageView.image = UIImage(systemName: "checkmark", withConfiguration: config) // رمادي
            statusImageView.tintColor = .gray
        }
    }
    
    private func loadImage(url: String) {
        guard let urlObj = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: urlObj), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.messageImageView.image = image
                }
            }
        }
    }
}
