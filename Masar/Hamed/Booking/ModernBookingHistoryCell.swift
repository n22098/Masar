import UIKit
import FirebaseFirestore

// MARK: - ModernBookingHistoryCell
/// ModernBookingHistoryCell: Custom UI for the customer's booking history list.
/// OOD Principle: Encapsulation - This class hides the complex Auto Layout constraints
/// and UI styling from the Rest of the app.
class ModernBookingHistoryCell: UITableViewCell {
    
    /// didTapRateButton: A callback closure (Communication Pattern).
    /// OOD Note: This allows the Cell to notify the Controller that a button was pressed
    /// without the Cell needing to know anything about the Controller's logic.
    var didTapRateButton: (() -> Void)?
    
    // MARK: - UI Components
    
    /// The card-like background with rounded corners and soft shadows.
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        label.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// rateButton: A dynamic button that only appears for completed services.
    /// OOD Principle: Lazy Loading - The button is only initialized when needed.
    lazy var rateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Rate", for: .normal)
        btn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        btn.tintColor = .systemBlue
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        // Target-Action Pattern: Linking the button click to a function
        btn.addTarget(self, action: #selector(rateButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - UI Setup
    
    /// Builds the visual structure of the cell using programmatic Auto Layout.
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(serviceNameLabel)
        containerView.addSubview(providerNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(rateButton)
        
        // Defining constraints to position elements within the card
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            serviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Status Label Constraints (Top-Right)
            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Rate Button Constraints (Positioned strategically below the Status)
            rateButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            rateButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            rateButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Price Label Constraints (Bottom-Right)
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Configuration
    
    /// configure: Populates the UI elements with data from the Model.
    /// OOD Principle: Model-View separation - The cell doesn't fetch data; it simply displays what it's given.
    func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = "📅 \(booking.dateString)"
        priceLabel.text = booking.priceString
        statusLabel.text = "  \(booking.status.rawValue)  "
        
        // Business Logic: Only show the "Rate" button if the service is marked as completed.
        if booking.status == .completed {
            rateButton.isHidden = false
        } else {
            rateButton.isHidden = true
        }
        
        // UI Logic: Applying semantic colors based on the booking's state.
        switch booking.status {
        case .upcoming:
            statusLabel.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.1)
        case .completed:
            statusLabel.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.1)
        case .canceled:
            statusLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.1)
        }
    }
    
    // MARK: - Actions
    
    /// rateButtonTapped: Executes the closure to inform the controller.
    @objc func rateButtonTapped() {
        didTapRateButton?()
    }
}
