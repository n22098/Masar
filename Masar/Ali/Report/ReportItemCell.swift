import UIKit

/// ReportItemCell: A custom TableView cell used to display a summary of a user report.
/// OOD Principle: Encapsulation - All UI components (labels, icons, containers) are private.
/// The only way to update the cell is through the 'configure' method.
class ReportItemCell: UITableViewCell {
    
    static let identifier = "ReportItemCell"
    
    // MARK: - UI Elements
    
    /// The main card background that holds all other elements.
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        // Deep shadow for a modern "elevated" look (UX Depth)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// A decorative background for the report icon.
    private let iconContainer: UIView = {
        let view = UIView()
        // Brand color with 10% opacity for a professional pastel look
        view.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.1)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "exclamationmark.bubble.fill")
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let reportIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    /// Visual indicator showing the cell is interactive (tappable).
    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .lightGray.withAlphaComponent(0.6)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    /// OOD Principle: Composition - Combining multiple labels into a single stack
    /// to manage vertical spacing and alignment automatically.
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup UI
    
    /// setupUI: Builds the view hierarchy and applies programmatic Auto Layout.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Build the view hierarchy
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(textStackView)
        containerView.addSubview(chevronImageView)
        
        // Add labels to the vertical stack
        textStackView.addArrangedSubview(reportIdLabel)
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(emailLabel)
        
        // Define mathematical constraints for placement
        NSLayoutConstraint.activate([
            // Card Container Padding (Increased to 10 for better vertical spacing)
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Icon Container placement
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 45),
            iconContainer.heightAnchor.constraint(equalToConstant: 45),
            
            // Icon placement inside its container
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            // Trailing Chevron placement
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12),
            
            // Text Stack placement (Centered vertically between icon and chevron)
            textStackView.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            textStackView.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            textStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    /// configure: Public interface to populate the cell with report data.
    func configure(id: String, name: String, email: String) {
        reportIdLabel.text = "#\(id)"
        nameLabel.text = name
        emailLabel.text = email
    }
    
    // MARK: - Animation
    
    /// OOD Principle: Polymorphism (Method Overriding) - Customizing the cell's highlight state.
    /// UX Polish: Applies a subtle scale animation (96%) when the user touches the cell.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            // Using CGAffineTransform for physical-like feedback
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        }
    }
}
