import UIKit

class ProviderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!

    var onButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true

        actionButton.layer.cornerRadius = 18
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0).cgColor
        actionButton.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0), for: .normal)

        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onButtonTapped = nil
        avatarImageView.image = nil
    }

    @objc func buttonAction() {
        onButtonTapped?()
    }

    func configure(with provider: ServiceProvider) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        avatarImageView.image = UIImage(named: provider.imageName) ?? UIImage(systemName: "person.circle.fill")
    }
}
