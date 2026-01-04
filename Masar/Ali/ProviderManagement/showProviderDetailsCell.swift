//
//  showProviderDetailsCell.swift
//  Masar
//
//  Created by BP-36-201-10 on 20/12/2025.
//
import UIKit

/// showProviderDetailsCell: A specialized custom cell for displaying Service Providers in the Admin list.
/// OOD Principle: Encapsulation - The internal UI components (labels, icons) are hidden from other
/// classes, ensuring the cell's internal state is only modified through designated methods.
class showProviderDetailsCell: UITableViewCell {
    
    // MARK: - Private UI Elements
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel() // OOD Note: Added to support Provider-specific metadata
    private let chevronImageView = UIImageView()
    
    // MARK: - Initializers
    
    /// Called when the cell is initialized programmatically from a controller.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    /// Required initializer for loading the cell via a Nib or Storyboard.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    /// setupUI: Programmatically builds the "Card" design with modern shadow effects.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none // Disables standard selection to use our custom scale animation
        
        // 1. Container View (The Card)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        // Applying CALayer properties for a soft, professional depth (UX Depth)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // 2. Name Label Configuration
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Category Label (Subtitle) Configuration
        categoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. Chevron (Arrow) icon to indicate navigability
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding elements to the container view
        containerView.addSubview(nameLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(chevronImageView)
        
        // MARK: - Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Outer card padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70), // Taller to fit two rows of text
            
            // Name label at the top-left
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // Category label anchored below the name
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // Chevron centered vertically relative to the card
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    // MARK: - Configuration
    
    /// configure: Public method to inject data into the cell's views.
    /// OOD Principle: Abstraction - The controller just passes data; it doesn't need
    /// to know how the cell arranges it.
    func configure(name: String, category: String) {
        nameLabel.text = name
        categoryLabel.text = category
    }
    
    // MARK: - Animation Logic
    
    /// setHighlighted: Overriding to provide active feedback to the user.
    /// Uses CGAffineTransform to shrink the card slightly (0.98) when touched.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
