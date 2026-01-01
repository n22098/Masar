import UIKit

// MARK: - Sent Message Cell
class SentMessageCell: UICollectionViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleView?.layer.cornerRadius = 16
        bubbleView?.clipsToBounds = true
    }
    
    func configure(with msg: Message) {
        messageLabel?.text = msg.text ?? "📷 Image"
        
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        timeLabel?.text = fmt.string(from: msg.timestamp)
        
        bubbleView?.backgroundColor = .systemBlue
        messageLabel?.textColor = .white
        timeLabel?.textColor = UIColor.white.withAlphaComponent(0.85)
    }
}

// MARK: - Received Message Cell
class ReceivedMessageCell: UICollectionViewCell {
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleView?.layer.cornerRadius = 16
        bubbleView?.clipsToBounds = true
    }
    
    func configure(with msg: Message) {
        messageLabel?.text = msg.text ?? "📷 Image"
        
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        timeLabel?.text = fmt.string(from: msg.timestamp)
        
        bubbleView?.backgroundColor = .systemGray5
        messageLabel?.textColor = .label
        timeLabel?.textColor = .secondaryLabel
    }
}

// MARK: - Image Message Cell (if needed later)
class ImageMessageCell: UICollectionViewCell {
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble?.layer.cornerRadius = 18
        messageBubble?.clipsToBounds = true
        messageImageView?.layer.cornerRadius = 12
        messageImageView?.clipsToBounds = true
        messageImageView?.contentMode = .scaleAspectFill
    }
    
    func configure(with message: Message, isSent: Bool) {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        timeLabel?.text = fmt.string(from: message.timestamp)
        
        if isSent {
            messageBubble?.backgroundColor = .systemBlue
            timeLabel?.textColor = UIColor.white.withAlphaComponent(0.85)
        } else {
            messageBubble?.backgroundColor = .systemGray5
            timeLabel?.textColor = .secondaryLabel
        }
        
        if let imageURLString = message.imageURL {
            messageImageView?.loadImage(from: imageURLString)
        }
    }
}

// MARK: - Helper Extension for Image Loading
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        self.image = UIImage(systemName: "photo")
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }
    }
}
 
