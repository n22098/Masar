//
//  DashboardHeaderCell.swift
//  Masar
//
//  Created by Moe Radhi  on 20/12/2025.
//

import UIKit

class DashboardHeaderCell: UITableViewCell {
    
    private let containerView = UIView()
    private let avatarView = UIView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let companyLabel = UILabel()
    private let statsStackView = UIStackView()
    
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
        
        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Avatar
        avatarView.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.2)
        avatarView.layer.cornerRadius = 35
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let avatarIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        avatarIcon.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarIcon)
        
        // Labels
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        roleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        roleLabel.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        companyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        companyLabel.textColor = .gray
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stats Stack
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 8
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(roleLabel)
        containerView.addSubview(companyLabel)
        containerView.addSubview(statsStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 70),
            avatarView.heightAnchor.constraint(equalToConstant: 70),
            
            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 35),
            avatarIcon.heightAnchor.constraint(equalToConstant: 35),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            companyLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2),
            companyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(name: String, role: String, company: String, rating: Double, totalBookings: Int) {
        nameLabel.text = name
        roleLabel.text = role
        companyLabel.text = company
        
        // Clear existing stats
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add stats
        statsStackView.addArrangedSubview(createStatView(value: String(format: "%.1f", rating), label: "Rating", icon: "star.fill"))
        statsStackView.addArrangedSubview(createStatView(value: "\(totalBookings)", label: "Bookings", icon: "calendar"))
    }
    
    private func createStatView(value: String, label: String, icon: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        container.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = .black
        
        let labelText = UILabel()
        labelText.text = label
        labelText.font = .systemFont(ofSize: 11, weight: .regular)
        labelText.textColor = .gray
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(labelText)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return container
    }
}
