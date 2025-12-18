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

        // ✅ إذا أي outlet مو مربوط، لا تسوي crash — اطبع تحذير
        guard serviceNameLabel != nil,
              providerNameLabel != nil,
              dateLabel != nil,
              priceLabel != nil,
              statusLabel != nil else {
            print("❌ BookingHistoryCell outlets are not connected. Check storyboard wiring.")
            return
        }

        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = booking.date
        priceLabel.text = booking.price

        switch booking.status {
        case .upcoming:
            statusLabel.text = "Upcoming"
        case .completed:
            statusLabel.text = "Completed"
        case .canceled:
            statusLabel.text = "Canceled"
        }
    }
}
