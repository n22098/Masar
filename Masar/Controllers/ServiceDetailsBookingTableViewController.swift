import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {

    // MARK: - Variables (استقبال البيانات)
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedLocation: String? // متغير جديد لاستقبال الموقع
    
    // MARK: - Outlets
    // 1. التاريخ (الوحيد القابل للتعديل)
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // 2. باقي الحقول (Labels للعرض فقط - ممنوع الكتابة)
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    // MARK: - Setup
    func setupUI() {
        title = "Check Out" // تغيير العنوان ليكون مناسباً
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // تجميل الزر
        if let btn = confirmButton {
            btn.layer.cornerRadius = 8
            btn.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        }
    }
    
    func populateData() {
        // عرض البيانات المستلمة في النصوص الثابتة
        serviceNameLabel?.text = receivedServiceName
        priceLabel?.text = receivedServicePrice
        locationLabel?.text = receivedLocation ?? "Online" // لو ما وصلنا موقع، نكتب Online
    }
    
    // MARK: - Actions
    @IBAction func confirmBookingTapped(_ sender: UIButton) {
        // لا نحتاج للتحقق من الكتابة لأن البيانات ثابتة
        
        // رسالة النجاح مباشرة
        let dateString = datePicker.date.formatted(date: .long, time: .shortened)
        
        let successAlert = UIAlertController(title: "Booking Confirmed! 🎉",
                                           message: "Service: \(receivedServiceName ?? "")\nDate: \(dateString)",
                                           preferredStyle: .alert)
        
        successAlert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(successAlert, animated: true)
    }
}
