//
//  BookingProviderCell.swift
//  Masar
//

import UIKit

/// BookingProviderCell: A custom table view cell used to display booking summaries.
/// OOD Principle: Single Responsibility - This class is strictly responsible for
/// the layout and visual representation of a BookingModel inside a list.
class BookingProviderCell: UITableViewCell {
    
    // MARK: - UI Elements
    // OOD Note: All UI elements are private (Encapsulation).
    // This prevents outside classes from accidentally changing the cell's internal layout.
    
    /// The main white card background with a shadow effect.
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The circular background for the user's initials.
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seekerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A styled label acting as a "Badge" to show if a booking is Upcoming, Completed, or Cancelled.
    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Visual cue (chevron) indicating the cell is tappable for more details.
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - Initializers
    
    /// OOD Principle: Initialization - Setting up the view hierarchy when the cell is first created.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    /// Required initializer for Storyboard support (even though we code the UI manually).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    /// Programmatically builds the view hierarchy and sets up Auto Layout constraints.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none // Prevents the cell from turning gray when tapped
        
        // Build the view nesting
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        containerView.addSubview(seekerNameLabel)
        containerView.addSubview(serviceNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusBadge)
        containerView.addSubview(arrowImageView)
        
        // Define the mathematical rules for the UI layout (Auto Layout)
        NSLayoutConstraint.activate([
            // Main Container Padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Avatar Circle
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            // Textual Information (Labels)
            seekerNameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            seekerNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            seekerNameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            serviceNameLabel.leadingAnchor.constraint(equalTo: seekerNameLabel.leadingAnchor),
            serviceNameLabel.topAnchor.constraint(equalTo: seekerNameLabel.bottomAnchor, constant: 4),
            serviceNameLabel.trailingAnchor.constraint(equalTo: seekerNameLabel.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: seekerNameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14),
            
            // Pricing and Status on the right side
            priceLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            priceLabel.centerYAnchor.constraint(equalTo: seekerNameLabel.centerYAnchor),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            statusBadge.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            statusBadge.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            
            // Trailing arrow icon
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // MARK: - Configuration
    
    /// Populates the cell with data from a BookingModel object.
    /// OOD Principle: Dependency Injection - We "inject" the model into the cell to configure it.
    func configure(with booking: BookingModel, brandColor: UIColor) {
        
        // Logic: Extract initials from the name for the avatar
        let initials = booking.seekerName.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
        avatarLabel.text = initials.uppercased()
        
        seekerNameLabel.text = booking.seekerName
        serviceNameLabel.text = booking.serviceName
        dateLabel.text = "📅 \(booking.dateString)"
        priceLabel.text = booking.priceString
        priceLabel.textColor = brandColor
        
        // Exhaustive switch to handle UI state based on the booking status
        switch booking.status {
        case .upcoming:
            statusBadge.text = "Upcoming"
            statusBadge.backgroundColor = brandColor.withAlphaComponent(0.15)
            statusBadge.textColor = brandColor
        case .completed:
            statusBadge.text = "Completed"
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGreen
        case .canceled:
            statusBadge.text = "Cancelled"
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusBadge.textColor = .systemRed
        }
    }
}
