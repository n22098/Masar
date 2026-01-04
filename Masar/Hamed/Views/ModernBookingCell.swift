// ===================================================================================
// MODERN BOOKING CELL
// ===================================================================================
// PURPOSE: A stylish, card-based table view cell used to display service options.
//
// KEY FEATURES:
// 1. Programmatic Layout: All UI elements are created and positioned via code.
// 2. Card Styling: Uses shadows, rounded corners, and padding to create depth.
// 3. Callback Action: Uses a closure to handle button taps within the cell.
// ===================================================================================

import UIKit

// MARK: - ModernBookingCell
class ModernBookingCell: UITableViewCell {
    
    // Callback closure: Triggered when the "Request" button is tapped.
    var onBookingTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    // The white card container
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        // Shadow configuration for depth effect
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Service Icon
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        // Sets the icon color to the brand purple
        iv.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Service Name Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Price Label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Description Label (Limited to 2 lines)
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Request Button
    private let bookingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Request", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1), for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Layout Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none // Prevents cell highlighting on selection
        
        // Add Subviews
        contentView.addSubview(containerView)
        [iconView, titleLabel, priceLabel, descriptionLabel, bookingButton].forEach { containerView.addSubview($0) }
        
        // Activate Constraints
        NSLayoutConstraint.activate([
            // Container Layout (with margins)
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Icon Layout
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),
            
            // Title Layout
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bookingButton.leadingAnchor, constant: -8),
            
            // Price Layout
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // Description Layout
            descriptionLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: bookingButton.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            // Button Layout
            bookingButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bookingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            bookingButton.widthAnchor.constraint(equalToConstant: 80),
            bookingButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        bookingButton.addTarget(self, action: #selector(bookingTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func bookingTapped() {
        onBookingTapped?() // Execute the callback
    }
    
    // MARK: - Configuration
    func configure(title: String, price: Double, description: String, icon: String) {
        titleLabel.text = title
        priceLabel.text = String(format: "BHD %.3f", price)
        descriptionLabel.text = description
        iconView.image = UIImage(systemName: icon)
    }
}
