import UIKit

class Bookinghistoryapp: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    // ✅ تأكد أن هذا مربوط بالـ Label اليمين (القيمة) وليس العنوان
    @IBOutlet weak var serviceItemLabel: UILabel?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem?

    var bookingData: BookingModel?
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
        // توسيع الخلايا لتناسب النصوص الطويلة
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupData() {
        guard let booking = bookingData else { return }
        
        // تعبئة البيانات الأساسية
        dateLabel?.text = booking.dateString
        priceLabel?.text = booking.priceString
        statusLabel?.text = booking.status.rawValue
        serviceNameLabel?.text = booking.serviceName
        
        // ---------------------------------------------------------
        // 🛑 إصلاح طريقة عرض الوصف والخدمات
        // ---------------------------------------------------------
        
        let rawDescription = booking.descriptionText
        
        // ✅ الإصلاح هنا: نستخدم ( ?? "" ) لتحويل الـ Optional إلى نص فارغ في حال كان nil
        let rawInstructions = booking.instructions ?? ""
        
        // 1. التعامل مع الوصف (Description)
        if rawDescription.contains("Booking via App") || rawDescription.contains("Add-ons:") {
            if rawDescription.contains("Add-ons:") {
                let parts = rawDescription.components(separatedBy: "Add-ons:")
                if let firstPart = parts.first {
                    descriptionLabel?.text = firstPart.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            } else {
                descriptionLabel?.text = "Service details unavailable."
            }
        } else {
            descriptionLabel?.text = rawDescription
        }
        
        // 2. التعامل مع الإضافات (Service Items)
        // الآن rawInstructions أصبح نصاً عادياً (ليس Optional) ويمكن استخدام trimmingCharacters عليه
        let cleanInstructions = rawInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !cleanInstructions.isEmpty &&
           cleanInstructions != "No instructions" &&
           cleanInstructions != "No special instructions" &&
           cleanInstructions != "None" {
            
            serviceItemLabel?.text = cleanInstructions
            serviceItemLabel?.textColor = .black
        } else {
            serviceItemLabel?.text = "None"
            serviceItemLabel?.textColor = .gray
        }
        
        // تحديث حالة الأزرار والألوان
        updateUIState(status: booking.status)
    }
    
    func updateUIState(status: BookingStatus) {
        switch status {
        case .upcoming:
            statusLabel?.textColor = .orange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel?.textColor = .green
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel?.textColor = .red
            cancelButton?.isEnabled = false
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.bookingData, let bookingId = booking.id else { return }
            
            // تحديث الواجهة فوراً
            self.statusLabel?.text = "Canceled"
            self.statusLabel?.textColor = .red
            self.cancelButton?.isEnabled = false
            self.bookingData?.status = .canceled
            
            // تحديث في Firebase
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                DispatchQueue.main.async {
                    if success {
                        self.onStatusChanged?(.canceled)
                    } else {
                        // التراجع عند الفشل
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to cancel booking.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                        
                        self.statusLabel?.text = "Upcoming"
                        self.statusLabel?.textColor = .orange
                        self.cancelButton?.isEnabled = true
                        self.bookingData?.status = .upcoming
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // هذا يضمن أن الخلية تتوسع حسب حجم النص
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
