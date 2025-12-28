import UIKit

class BookingCell: UITableViewCell {

    @IBOutlet weak var seekerLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton?
    
    var onBookingTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        bookButton?.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    @objc private func bookTapped() {
        onBookingTapped?()
    }

    func configure(with model: BookingModel) {
        serviceNameLabel.text = model.serviceName
        seekerLabel.text = model.providerName
        
        // ✅ التصحيح: استخدمنا .dateString
        dateLabel.text = model.dateString
        
        // ✅ التصحيح: استخدمنا .priceString
        priceLabel.text = model.priceString
        
        statusLabel.text = model.status.rawValue
        placeLabel.text = "Bahrain"

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
