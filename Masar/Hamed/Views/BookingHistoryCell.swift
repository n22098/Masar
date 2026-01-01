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
        // التحقق من أن العناصر متصلة لتجنب الكراش
        guard serviceNameLabel != nil else { return }

        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        
        dateLabel.text = booking.dateString
        priceLabel.text = booking.priceString

        // ضبط النص
        statusLabel.text = booking.status.rawValue
        
        // ✅ تم التعديل: حذفنا rejected لتتوافق مع المودل الجديد
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
