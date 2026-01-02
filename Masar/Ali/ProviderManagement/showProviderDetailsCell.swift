//
//  showProviderDetailsCell.swift
//  Masar
//
//  Created by BP-36-201-10 on 20/12/2025.
//
import UIKit

class showProviderDetailsCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel() // Added this because Providers need categories
    private let chevronImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Card Setup
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // Name Label
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Category Label (Subtitle)
        categoryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Arrow Icon
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(chevronImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70), // Slightly taller for subtitle
            
            // Name at top
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // Category below name
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(name: String, category: String) {
        nameLabel.text = name
        categoryLabel.text = category
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
