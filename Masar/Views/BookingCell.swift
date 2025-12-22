import UIKit

class BookingCell: UITableViewCell {

    // MARK: - Outlets
    // هذه العناصر موجودة في كودك السابق
    @IBOutlet weak var seekerLabel: UILabel!      // سنستخدمه لعرض اسم الـ Provider أو Seeker
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // ✅ إضافات جديدة مطلوبة لتصميمك (تأكد من ربطها في Storyboard)
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!       // لعرض المكان

    // الزر الموجود مسبقاً
    @IBOutlet weak var bookButton: UIButton?
    var onBookingTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // إعداد شكل الزر إذا وجد
        bookButton?.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)
        
        // تحسينات جمالية للحواف (اختياري)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    @objc private func bookTapped() {
        onBookingTapped?()
    }

    // ✅ الدالة الجديدة: تستقبل BookingModel بالكامل
    func configure(with model: BookingModel) {
        serviceNameLabel.text = model.serviceName
        dateLabel.text = model.date
        priceLabel.text = model.price
        statusLabel.text = model.status.rawValue // سيظهر النص "Upcoming" أو "Completed"
        
        // هنا نختار ماذا نعرض في خانة الاسم (اسم مقدم الخدمة مثلاً)
        seekerLabel.text = model.providerName
        
        // بما أن الموديل لا يحتوي على "Place"، سنستخدم الـ instructions مؤقتاً أو يمكنك إضافة place للموديل
        placeLabel.text = "Bahrain" // أو model.instructions

        // تغيير لون الحالة بناءً على الـ Enum
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
