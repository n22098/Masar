import UIKit

// MARK: - RatingTableViewCell
/// RatingTableViewCell: A custom cell designed to display individual user reviews.
/// OOD Principle: Encapsulation - All the visual styling (shadows, fonts, colors) is
/// contained within this class, keeping the rest of the app's code clean.
class RatingTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    // OOD Note: These are private properties (Encapsulation).
    // They cannot be modified from outside this class.
    private let containerView = UIView()
    private let starLabel = UILabel()
    private let ratingValueLabel = UILabel()
    private let usernameLabel = UILabel()
    private let bookingLabel = UILabel()
    private let dateLabel = UILabel()
    private let feedbackLabel = UILabel()
    
    // MARK: - Initialization
    
    /// Standard initializer for creating the cell programmatically.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    /// Initializer used if the cell is loaded from a Storyboard or XIB.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    /// Builds the visual hierarchy and applies Auto Layout constraints.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none // Keeps the cell from highlighting when tapped
        
        // Container: Creates the "Card" effect with shadow and rounded corners
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.08
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Star Icon: Visual representation of the rating
        starLabel.font = .systemFont(ofSize: 24)
        starLabel.text = "★"
        starLabel.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Numeric Rating Value (e.g., "5.0")
        ratingValueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        ratingValueLabel.textColor = .black
        ratingValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // UIStackView: OOD Principle (Composition) - Grouping related views
        // together for easier management.
        let ratingStack = UIStackView(arrangedSubviews: [starLabel, ratingValueLabel])
        ratingStack.axis = .horizontal
        ratingStack.spacing = 6
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingStack)
        
        // Header Text: The user who wrote the review
        usernameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        usernameLabel.textColor = .label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        // Context Label: Shows which specific service was booked
        bookingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        bookingLabel.textColor = UIColor(red: 0.4, green: 0.5, blue: 0.9, alpha: 1.0)
        bookingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bookingLabel)
        
        // Timestamp Label: When the review was written
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .systemGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)
        
        // Main Content: The actual text feedback from the user
        feedbackLabel.font = .systemFont(ofSize: 15)
        feedbackLabel.textColor = .darkGray
        feedbackLabel.numberOfLines = 0 // Allows the text to wrap to multiple lines
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(feedbackLabel)
        
        // MARK: - Constraints
        // Defining the exact position and spacing for all elements inside the cell.
        NSLayoutConstraint.activate([
            // Card Container padding from the edges of the cell
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Positioning the star and rating value at the top
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
            
            // Ensuring the feedback text pushes the bottom of the card out (Dynamic Height)
            feedbackLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            feedbackLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            feedbackLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    
    /// OOD Principle: Dependency Injection - The model is injected into the view
    /// to tell it what to display.
    func configure(with rating: Rating) {
        // Numeric star value
        ratingValueLabel.text = String(format: "%.1f", rating.stars)
        
        usernameLabel.text = rating.username
        
        // Optional Handling: Only show the booking name if it exists
        if let bookingName = rating.bookingName {
            bookingLabel.text = "Booking: \(bookingName)"
            bookingLabel.isHidden = false
        } else {
            bookingLabel.isHidden = true
        }
        
        // Date Formatting: Transforming a Date object into a readable String
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = formatter.string(from: rating.date)
        
        feedbackLabel.text = rating.feedback
    }
}
