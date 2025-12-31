import UIKit

class BookingCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var seekerLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton?
    
    // Callback for button tap
    var onBookingTapped: (() -> Void)?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Setup Button Action
        bookButton?.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)
        
        // Card Styling
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.selectionStyle = .none
    }

    // MARK: - Actions
    @objc private func bookTapped() {
        onBookingTapped?()
    }

    // MARK: - Configuration
    func configure(with model: BookingModel) {
        serviceNameLabel.text = model.serviceName
        seekerLabel.text = model.providerName
        
        // Assuming BookingModel has these formatted strings
        dateLabel.text = model.dateString
        priceLabel.text = model.priceString
        
        statusLabel.text = model.status.rawValue
        placeLabel.text = "Bahrain" // Static or from model

        // Status Colors
        switch model.status {
        case .upcoming:
            statusLabel.textColor = .systemBlue
        case .completed:
            statusLabel.textColor = .systemGreen
        case .canceled:
            statusLabel.textColor = .systemRed
        }
    }
}
