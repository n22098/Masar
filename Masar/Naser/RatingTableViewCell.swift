import UIKit

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
        selectionStyle = .none
        
        // Container Design
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.08
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Configure Labels
        starLabel.text = "★"
        starLabel.textColor = .systemYellow
        starLabel.font = .systemFont(ofSize: 20)
        
        ratingValueLabel.font = .boldSystemFont(ofSize: 18)
        ratingValueLabel.textColor = .black
        
        let ratingStack = UIStackView(arrangedSubviews: [starLabel, ratingValueLabel])
        ratingStack.spacing = 4
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingStack)
        
        usernameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        bookingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        bookingLabel.textColor = .systemBlue
        bookingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bookingLabel)
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        feedbackLabel.font = .systemFont(ofSize: 15)
        feedbackLabel.textColor = .darkGray
        feedbackLabel.numberOfLines = 0
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(feedbackLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            ratingStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            ratingStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            usernameLabel.centerYAnchor.constraint(equalTo: ratingStack.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: ratingStack.trailingAnchor, constant: 12),
            
            bookingLabel.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 8),
            bookingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dateLabel.centerYAnchor.constraint(equalTo: bookingLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            feedbackLabel.topAnchor.constraint(equalTo: bookingLabel.bottomAnchor, constant: 12),
            feedbackLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            feedbackLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with rating: Rating) {
        ratingValueLabel.text = String(format: "%.1f", rating.stars)
        usernameLabel.text = rating.username
        bookingLabel.text = rating.bookingName ?? "Service"
        feedbackLabel.text = rating.feedback
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = formatter.string(from: rating.date)
    }
}
