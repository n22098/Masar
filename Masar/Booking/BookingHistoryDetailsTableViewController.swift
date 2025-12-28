import UIKit

class BookingHistoryDetailsViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // MARK: - Variables
    var bookingData: BookingModel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        fillData()
    }
    
    // دالة تعبئة البيانات
    func fillData() {
        guard let data = bookingData else { return }
        
        serviceNameLabel.text = data.serviceName
        providerLabel.text = data.providerName
        
        // ✅ الحل النهائي: نستخدم dateString و priceString من الموديل
        priceLabel.text = data.priceString
        dateLabel.text = data.dateString
        
        descriptionLabel.text = data.descriptionText
        
        // تلوين وعرض الحالة
        setupStatusLabel(status: data.status)
        
        // تحديث زر الإلغاء
        if data.status == .canceled || data.status == .completed {
            cancelButton.isEnabled = false
        } else {
            cancelButton.isEnabled = true
        }
    }
    
    // دالة مساعدة لتلوين النص
    func setupStatusLabel(status: BookingStatus) {
        let fullText = "Status | \(status.rawValue)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // لون كلمة Status رمادي
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: (fullText as NSString).range(of: "Status | "))
        
        // تحديد لون الحالة
        let statusColor: UIColor
        switch status {
        case .upcoming: statusColor = .orange
        case .completed: statusColor = .green
        case .canceled: statusColor = .red
        }
        
        // تلوين الحالة
        attributedString.addAttribute(.foregroundColor, value: statusColor, range: (fullText as NSString).range(of: status.rawValue))
        
        statusLabel.attributedText = attributedString
    }
    
    // MARK: - Actions
    // زر الإلغاء
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            self?.updateUIForCancellation()
        }))
        
        present(alert, animated: true)
    }
    
    func updateUIForCancellation() {
        // تحديث الواجهة فورياً
        statusLabel.text = "Status | Canceled"
        statusLabel.textColor = .red
        cancelButton.isEnabled = false
    }

} // نهاية الكلاس (تأكد أن هذا القوس هو آخر شيء في الملف)
