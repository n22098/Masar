import UIKit

class BookingProviderDetailsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Variables
    var bookingData: BookingModel?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populateData()
    }

    // MARK: - Populate Data
    private func populateData() {
        guard let data = bookingData else { return }

        seekerNameLabel?.text = data.seekerName
        emailLabel?.text = data.email
        phoneLabel?.text = data.phoneNumber
        
        // ✅ التصحيح: استخدام المترجمات لحل مشكلة التاريخ والسعر
        dateLabel?.text = data.dateString   // بدلاً من data.date
        priceLabel?.text = data.priceString // بدلاً من data.price
        
        serviceNameLabel?.text = data.serviceName
        priceLabel?.textColor = brandColor
        instructionsLabel?.text = data.instructions
        descriptionLabel?.text = data.descriptionText
        
        // تحديث حالة الواجهة (اختياري)
        updateUIBasedOnStatus(status: data.status)
    }
    
    func updateUIBasedOnStatus(status: BookingStatus) {
        // يمكنك إضافة كود لتغيير الأزرار بناء على الحالة هنا
    }
}
