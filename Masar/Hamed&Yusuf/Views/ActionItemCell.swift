// ===================================================================================
// ACTION ITEM CELL
// ===================================================================================
// PURPOSE: A custom TableView cell designed to look like a floating card.
//
// KEY FEATURES:
// 1. Programmatic UI: All visual elements (Icon, Label, Arrow) are built in code.
// 2. Card Design: Uses shadows, rounded corners, and borders for a modern look.
// 3. Layout Overrides: Uses 'layoutSubviews' to add spacing between cells.
// ===================================================================================

import UIKit

class ActionItemCell: UITableViewCell {

    // MARK: - Storyboard Outlets
    // We keep this connection to prevent crashes if it's still linked in the Storyboard,
    // but we will hide it programmatically to use our custom design.
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Programmatic UI Components
    
    // 1. Icon Container: A colored square with rounded corners to hold the icon
    private let iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return view
    }()
    
    // 2. The Icon Image
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // 3. Custom Title Label: Styled with a specific font weight
    private let customTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 4. Arrow Indicator: Shows that the row is clickable (Chevron)
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Safety: Hide the default storyboard label to ensure our custom UI takes over
        if titleLabel != nil { titleLabel.isHidden = true }
        
        // Initialize the custom design
        setupModernDesign()
    }

    // MARK: - Layout Overrides
    // This function allows us to create the "Floating Card" effect.
    // By shrinking the contentView frame, we create physical space between cells.
    override func layoutSubviews() {
        super.layoutSubviews()
        // Inset the content view by 8pts vertically and 20pts horizontally
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
    }

    // MARK: - UI Setup Logic
    private func setupModernDesign() {
        backgroundColor = .clear
        selectionStyle = .none // Disable the default gray highlight on tap
        
        // 1. Card Styling (Background, Corners, Shadow)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        
        // Drop Shadow configuration
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        
        // Thin Border
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        
        // 2. Add Views to Hierarchy
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(customTitleLabel)
        contentView.addSubview(arrowImageView)
        
        // 3. Activate Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Icon Container Placement (Left Side)
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon Image Placement (Centered inside Container)
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Placement (Right of Icon)
            customTitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            customTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Arrow Placement (Far Right)
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - Configuration Method
    // Public method to populate the cell with data from the Controller.
    // It dynamically colors the icon container based on the 'brandColor'.
    func configure(title: String, iconName: String, brandColor: UIColor) {
        customTitleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        
        // Apply a light transparent background to the icon container
        iconContainerView.backgroundColor = brandColor.withAlphaComponent(0.1)
        // Apply the solid brand color to the icon itself
        iconImageView.tintColor = brandColor
    }
}
