import UIKit

class BookingHistoryCell: UITableViewCell {
    
    // اربط هذه العناصر في الستوري بورد
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceNameLabel: UILabel!   // الليبل الأول يسار
    @IBOutlet weak var providerNameLabel: UILabel!  // الليبل الثاني يسار
    @IBOutlet weak var dateLabel: UILabel!          // الليبل الثالث يسار
    @IBOutlet weak var statusLabel: UILabel!        // الليبل اللي على اليمين
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
    }

    func setupDesign() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // تصميم الكارت الأبيض
        if let container = containerView {
            container.backgroundColor = .white
            container.layer.cornerRadius = 12
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOpacity = 0.05
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowRadius = 4
        }
        
        // تجميل ليبل الحالة
        statusLabel?.layer.masksToBounds = true
        statusLabel?.layer.cornerRadius = 6
    }
    
    func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = "by \(booking.providerName)"
        dateLabel.text = booking.date
        statusLabel.text = booking.status.rawValue
        
        // تغيير لون الحالة
        switch booking.status {
        case .upcoming:
            statusLabel.textColor = .systemBlue
        case .completed:
            statusLabel.textColor = .systemGreen
        case .canceled:
            statusLabel.textColor = .systemRed
        }
    }
}
