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
        guard serviceNameLabel != nil else { return }

        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        
        // ✅ التصحيح: استخدمنا المترجم .dateString
        dateLabel.text = booking.dateString
        
        // ✅ التصحيح: استخدمنا المترجم .priceString
        priceLabel.text = booking.priceString

        // ضبط الحالة
        statusLabel.text = booking.status.rawValue
        
        switch booking.status {
        case .upcoming:
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.textColor = .systemGreen
        case .canceled:
            statusLabel.textColor = .systemRed
        }
    }
}
