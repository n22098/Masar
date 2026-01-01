import UIKit

class Bookinghistoryapp: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var serviceItemLabel: UILabel?
    @IBOutlet weak var cancelButton: UIBarButtonItem?

    // MARK: - Properties
    var bookingData: BookingModel?
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
        // إعداد الجدول ليتمدد حسب المحتوى
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Setup Data
    func setupData() {
        guard let booking = bookingData else { return }
        
        // 1. تعبئة البيانات الأساسية
        dateLabel?.text = booking.dateString
        priceLabel?.text = booking.priceString
        statusLabel?.text = booking.status.rawValue
        serviceNameLabel?.text = booking.serviceName
        
        // 2. معالجة النصوص الاختيارية (Optionals) لتجنب الكراش
        let description = booking.descriptionText ?? "No details available"
        let instructions = booking.instructions ?? "None"
        
        descriptionLabel?.text = description
        serviceItemLabel?.text = instructions.isEmpty ? "None" : instructions
        
        // 3. تحديث واجهة الحالة
        updateUIState(status: booking.status)
    }
    
    func updateUIState(status: BookingStatus) {
        // ✅ السويتش الآن متوافق تماماً مع المودل الجديد (3 حالات فقط)
        switch status {
        case .upcoming:
            statusLabel?.textColor = .systemOrange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel?.textColor = .systemGreen
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel?.textColor = .systemRed
            cancelButton?.isEnabled = false
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.bookingData, let bookingId = booking.id else { return }
            
            // 1. تحديث الواجهة فوراً للاستجابة السريعة
            self.statusLabel?.text = "Canceled"
            self.statusLabel?.textColor = .red
            self.cancelButton?.isEnabled = false
            self.bookingData?.status = .canceled
            
            // 2. إبلاغ القائمة السابقة بالتحديث
            self.onStatusChanged?(.canceled)
            
            // 3. التحديث في الفايربيس
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                if !success {
                    // في حال الفشل، نعيد الحالة (اختياري)
                    print("⚠️ Failed to update status in Firebase")
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // ضمان تمدد الخلايا
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
