import UIKit

class BookingCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    
    var onBookingTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
        bookButton.addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
    }
    
    func setupDesign() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        serviceImageView.layer.cornerRadius = 8
        serviceImageView.clipsToBounds = true
        
        bookButton.layer.cornerRadius = 8
        bookButton.layer.borderWidth = 1
        bookButton.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0).cgColor
        bookButton.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0), for: .normal)
    }

    @objc private func bookingButtonTapped() {
        onBookingTapped?()
    }
    
    // 👇 هذه الدالة كانت ناقصة وهي سبب الخطأ
    func configure(name: String, price: String) {
        serviceNameLabel.text = name
        servicePriceLabel.text = price
        // صورة افتراضية
        serviceImageView.image = UIImage(systemName: "doc.text.image")
    }
}
