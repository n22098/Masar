//
//  showSeekerDetailsCell.swift
//  Masar
//
//  Created by BP-36-201-10 on 20/12/2025.
//
import UIKit

/// showSeekerDetailsCell: A custom TableView cell used in the Seeker Management list.
/// OOD Principle: Encapsulation - The internal UI components (labels, images) are private,
/// forcing the rest of the app to interact only through the 'configure' method.
class showSeekerDetailsCell: UITableViewCell {
    
    // MARK: - Private UI Elements
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Initializers
    
    /// Called when the cell is created programmatically.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    /// Called if the cell is initialized via a Storyboard or Nib.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    /// setupUI: Handles the construction of the "Card" look.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none // Hides the standard gray selection to use our custom animation
        
        // 1. Card Setup: Creating depth with shadows and rounded corners
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // 2. Name Label styling
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Arrow Icon: Provides a visual cue that the item is tappable
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(chevronImageView)
        
        // MARK: - Constraints
        // Programmatic Auto Layout ensures the card is responsive across all iPhone sizes.
        NSLayoutConstraint.activate([
            // Card Padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Name Label position
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // Chevron position
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // MARK: - Configuration
    
    /// configure: Sets the data for the cell.
    /// OOD Note: This is the 'Interface' other classes use to talk to this cell.
    func configure(name: String) {
        nameLabel.text = name
    }
    
    // MARK: - Interactive Polish
    
    /// setHighlighted: Overriding this allows for a custom "press" animation.
    /// UX Tip: Shrinking the card slightly (0.98 scale) gives the user physical-like feedback.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            // Using CGAffineTransform to apply a scale effect
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
