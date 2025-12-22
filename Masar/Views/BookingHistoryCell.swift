import UIKit

class BookingHistoryCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(with booking: BookingModel) {
        // Safety Check
        guard serviceNameLabel != nil else { return }

        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = booking.date
        priceLabel.text = booking.price

        // ✅ FIXED: Switch must be exhaustive
        switch booking.status {
        case .upcoming:
            statusLabel.text = "Upcoming"
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.text = "Completed"
            statusLabel.textColor = .systemGreen
        case .canceled, .canceled: // Handles both spellings
            statusLabel.text = "Canceled"
            statusLabel.textColor = .systemRed
        }
    }
}
