import UIKit

final class ConversationCell: UITableViewCell {

    static let reuseIdentifier = "ConversationCell"

    // MARK: - UI Components (Programmatic)
    private let customProfileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - UI Components (Storyboard Outlets)
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // إعداد الصورة في الـ Storyboard لتكون دائرية
        profileImageView?.layer.cornerRadius = 25
        profileImageView?.clipsToBounds = true
        profileImageView?.contentMode = .scaleAspectFill
    }

    private func setupProgrammaticViews() {
        selectionStyle = .none
        
        customProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        customProfileImageView.layer.cornerRadius = 25
        customProfileImageView.clipsToBounds = true
        customProfileImageView.contentMode = .scaleAspectFill
        customProfileImageView.backgroundColor = .systemGray6
        customProfileImageView.image = UIImage(systemName: "person.circle.fill")
        customProfileImageView.tintColor = .lightGray
        contentView.addSubview(customProfileImageView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(nameLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        contentView.addSubview(subtitleLabel)

        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray4
        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            customProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customProfileImageView.widthAnchor.constraint(equalToConstant: 50),
            customProfileImageView.heightAnchor.constraint(equalToConstant: 50),

            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: customProfileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -2),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),
            subtitleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 2)
        ])
    }

    func setProfileImage(_ image: UIImage) {
        if let iv = profileImageView {
            iv.image = image
        } else {
            customProfileImageView.image = image
        }
    }
    
    func configure(with conversation: MessageConversation) {
        if let nameLbl = nameLabelOutlet, let lastMsgLbl = lastMessageLabel {
            nameLbl.text = conversation.otherUserName
            lastMsgLbl.text = conversation.lastMessage
            profileImageView?.image = UIImage(systemName: "person.circle.fill")
            profileImageView?.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        } else {
            nameLabel.text = conversation.otherUserName
            subtitleLabel.text = conversation.lastMessage
            customProfileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
