//
//  RatingTableViewCell.swift
//  Masar
//
//  Created by Guest User on 23/12/2025.
//

import UIKit

// MARK: - RatingTableViewCell
class RatingTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let starLabel = UILabel()
    private let ratingValueLabel = UILabel()
    private let usernameLabel = UILabel()
    private let bookingLabel = UILabel()
    private let dateLabel = UILabel()
    private let feedbackLabel = UILabel()
    
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
        
        // Container with shadow and rounded corners
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.08
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Star label (single star)
        starLabel.font = .systemFont(ofSize: 24)
        starLabel.text = "★"
        starLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating value label - CHANGED TO BLACK
        ratingValueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        ratingValueLabel.textColor = .black  // Changed from yellow to black
        ratingValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating container
        let ratingStack = UIStackView(arrangedSubviews: [starLabel, ratingValueLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 6
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingStack)
        
        // Username label
        usernameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        usernameLabel.textColor = .label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        // Booking label
        bookingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        bookingLabel.textColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1.0)
        bookingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bookingLabel)
        
        // Date label
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .systemGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        // Feedback label
        feedbackLabel.font = .systemFont(ofSize: 15)
        feedbackLabel.textColor = .darkGray
        feedbackLabel.numberOfLines = 0
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(feedbackLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            ratingStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            ratingStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            usernameLabel.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            bookingLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            bookingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bookingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: bookingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            feedbackLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            feedbackLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            feedbackLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with rating: Rating) {
        // Display single star with rating value
        ratingValueLabel.text = String(format: "%.1f", rating.stars)
        
        // Display username
        usernameLabel.text = rating.username
        
        // Display booking name
        if let bookingName = rating.bookingName {
            bookingLabel.text = "Booking: \(bookingName)"
            bookingLabel.isHidden = false
        } else {
            bookingLabel.isHidden = true
        }
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = formatter.string(from: rating.date)
        
        // Display feedback
        feedbackLabel.text = rating.feedback
    }
}
