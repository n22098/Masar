import UIKit

class BookingCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    
    // 👇 العناصر الجديدة المطلوبة (لازم تربطها في الستوري بورد)
        @IBOutlet weak var seekerLabel: UILabel!
        @IBOutlet weak var dateLabel: UILabel!
        
        var onBookingTapped: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupDesign()
            // تأكد ان الزر موجود قبل إضافة التارقت لتجنب الكراش إذا لم يتم ربطه
            if bookButton != nil {
                bookButton.addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
            }
        }
        
        func setupDesign() {
            backgroundColor = .clear
            selectionStyle = .none
            
            // التحقق من وجود العناصر قبل تعديل تصميمها (لتجنب الكراش إذا لم تُربط)
            if let container = containerView {
                container.layer.cornerRadius = 12
                container.layer.shadowColor = UIColor.black.cgColor
                container.layer.shadowOpacity = 0.08
                container.layer.shadowOffset = CGSize(width: 0, height: 2)
            }
            
            if let imgView = serviceImageView {
                imgView.layer.cornerRadius = 8
                imgView.clipsToBounds = true
            }
            
            if let btn = bookButton {
                btn.layer.cornerRadius = 8
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0).cgColor
                btn.setTitleColor(UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0), for: .normal)
            }
        }

        @objc private func bookingButtonTapped() {
            onBookingTapped?()
        }
        
        func configure(name: String, price: String) {
            serviceNameLabel.text = name
            servicePriceLabel?.text = price // علامة استفهام لتجنب الكراش
            serviceImageView?.image = UIImage(systemName: "doc.text.image")
        }
    }
