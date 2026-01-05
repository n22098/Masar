// ===================================================================================
// PROVIDER TABLE VIEW CELL
// ===================================================================================
// PURPOSE: A custom cell used to display a summary of a Service Provider.
//
// KEY FEATURES:
// 1. Circular Avatar: Automatically rounds the profile image.
// 2. Action Callback: Uses a closure to handle button taps inside the list.
// 3. Cell Reuse: Resets data when the cell is recycled to prevent display errors.
// ===================================================================================

import UIKit

class ProviderCell: UITableViewCell {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!

    // MARK: - Callback Closure
    // This function is executed when the "Action" button is tapped.
    // It allows the parent View Controller to handle the logic (e.g., Calling or Messaging).
    var onButtonTapped: (() -> Void)?

    // MARK: - Lifecycle: Initialization
    // Called once when the cell is loaded from the Storyboard.
    override func awakeFromNib() {
        super.awakeFromNib()

        // Make the avatar image circular
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true

        // Style the action button (Rounded borders)
        actionButton.layer.cornerRadius = 18
        actionButton.layer.borderWidth = 1
        // Using the brand color (Purple)
        actionButton.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0).cgColor
        actionButton.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0), for: .normal)

        // Connect the button event
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    // MARK: - Lifecycle: Reuse
    // Called just before the cell is reused for a new row.
    // We reset the state here to ensure data from previous rows doesn't appear ghosted.
    override func prepareForReuse() {
        super.prepareForReuse()
        onButtonTapped = nil
        avatarImageView.image = nil
    }

    // MARK: - Actions
    @objc func buttonAction() {
        // Execute the closure if it exists
        onButtonTapped?()
    }

    // MARK: - Configuration
    // Populates the cell with data from the model
    func configure(with provider: ServiceProviderModel) {
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        // Sets a default system image if the named image is missing
        avatarImageView.image = UIImage(named: provider.imageName) ?? UIImage(systemName: "person.circle.fill")
    }
}
