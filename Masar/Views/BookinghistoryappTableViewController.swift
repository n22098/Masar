import UIKit

// ⚠️ تأكد أن اسم الكلاس هو هذا بالضبط
class Bookinghistoryapp: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var itemIncludesLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // ✅ (1) هذا كان ناقصاً: تعريف الزر للتحكم فيه
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // متغير لتخزين البيانات
    var bookingData: BookingModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    func setupData() {
        if let booking = bookingData {
            // تعبئة البيانات
            dateLabel.text = booking.date
            // استخدام rawValue لعرض النص (Upcoming, Cancelled...)
            statusLabel.text = booking.status.rawValue
            serviceNameLabel.text = booking.serviceName
            priceLabel.text = booking.price
            skillsLabel.text = booking.instructions
            descriptionLabel.text = booking.descriptionText
            itemIncludesLabel.text = "Source File, High Res, 3 Revisions"
            
            // ✅ (2) تحديث حالة الزر ولون النص بناءً على الحالة
            updateUIState(status: booking.status)
            
        } else {
            // بيانات تجريبية (Dummy)
            dateLabel.text = "23 Dec 2025"
            statusLabel.text = "Upcoming"
            serviceNameLabel.text = "Website Starter"
            priceLabel.text = "85.000 BHD"
            skillsLabel.text = "Swift, UI/UX"
            descriptionLabel.text = "Full app development."
            itemIncludesLabel.text = "Source Code, Design System"
            
            // افتراضياً في التجربة الزر مفعل
            cancelButton?.isEnabled = true
        }
    }
    
    func updateUIState(status: BookingStatus) {
        // تغيير لون الحالة
        switch status {
        case .upcoming:
            statusLabel.textColor = .orange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel.textColor = .green
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel.textColor = .red
            cancelButton?.isEnabled = false
        }
    }
    
    // ✅ (3) هذا هو الأكشن الناقص الذي كنت تحاول ربطه!
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // عند الموافقة:
            self?.statusLabel.text = "Canceled"
            self?.statusLabel.textColor = .red
            self?.cancelButton.isEnabled = false
            
            // تحديث المودل (اختياري ليحفظ الحالة مؤقتاً)
            self?.bookingData?.status = .canceled
        })
        
        present(alert, animated: true)
    }
}
