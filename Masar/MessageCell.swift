import UIKit

final class MessageCell: UITableViewCell {

    static let reuseIdentifier = "MessageCell"

    private let bubbleView = UIView()
    private let messageImageView = UIImageView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!

    private let imageCache = NSCache<NSString, UIImage>()

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

        // Bubble
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.clipsToBounds = true
        contentView.addSubview(bubbleView)
        messageImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        messageImageView.addGestureRecognizer(tap)


        // Image
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.contentMode = .scaleAspectFit
        messageImageView.clipsToBounds = true
        messageImageView.isHidden = true
        messageImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        // Text
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)

        // Stack
        let stack = UIStackView(arrangedSubviews: [messageImageView, messageLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill

        bubbleView.addSubview(stack)

        // Layout
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            messageImageView.heightAnchor.constraint(equalToConstant: 250),

            stack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
        ])

        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageImageView.image = nil
        messageImageView.isHidden = true
        messageLabel.text = nil
        bubbleView.layer.borderWidth = 0
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

        // Find top-most view controller
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            topVC.present(vc, animated: true)
        }
    }

}
