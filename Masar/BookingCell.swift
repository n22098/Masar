import UIKit

class BookingCell: UITableViewCell {
    
    // تأكد من ربط هذه الدوائر في الستوري بورد
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton! // الزر الجانبي (Request)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // تحسين شكل الزر والخلفية
        if let btn = bookButton {
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0).cgColor
        }
    }
}
