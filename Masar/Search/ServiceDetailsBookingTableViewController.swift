import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var serviceItemLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String? // الوصف الحقيقي
    var receivedServiceItems: String?   // الإضافات (Service Items)
    
    var providerData: ServiceProviderModel?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fillData()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 12 }
        
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
        }
        
        if let picker = datePicker {
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .trailing
        }
    }
    
    func setupNavigationBar() {
        self.title = "Booking"
        let bookButton = UIBarButtonItem(title: "Book", style: .done, target: self, action: #selector(topBookTapped))
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
    }
    
    @objc func topBookTapped() { showBookingConfirmation() }
    
    func fillData() {
        serviceNameLabel?.text = receivedServiceName ?? "Unknown"
        
        if let price = receivedServicePrice {
            priceLabel?.text = price.replacingOccurrences(of: "BHD ", with: "")
        } else {
            priceLabel?.text = "0"
        }
        
        // عرض الوصف الحقيقي
        descriptionLabel?.text = receivedServiceDetails ?? "No description"
        descriptionLabel?.numberOfLines = 0
        
        // عرض الإضافات
        if let items = receivedServiceItems, !items.isEmpty, items != "None" {
            serviceItemLabel?.text = items
            serviceItemLabel?.textColor = .black
        } else {
            serviceItemLabel?.text = "None"
            serviceItemLabel?.textColor = .darkGray
        }
        serviceItemLabel?.numberOfLines = 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 { return 90 }
        return UITableView.automaticDimension
    }
    
    @IBAction func bookButtonPressed(_ sender: Any) { showBookingConfirmation() }
    
    func showBookingConfirmation() {
        let alert = UIAlertController(title: "Confirm Booking", message: "Proceed with booking?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            self?.saveBookingToFirebase()
        })
        present(alert, animated: true)
    }
    
    // 🛑 دالة الحفظ (المهمة جداً)
    func saveBookingToFirebase() {
        let serviceName = receivedServiceName ?? "Unknown"
        let priceString = receivedServicePrice?.replacingOccurrences(of: "BHD ", with: "") ?? "0"
        let price = Double(priceString) ?? 0.0
        let date = datePicker.date
        let providerName = providerData?.name ?? "Unknown"
        
        let currentUser = UserManager.shared.currentUser
        let seekerName = currentUser?.name ?? "Guest"
        let seekerEmail = currentUser?.email ?? "no-email"
        let seekerPhone = currentUser?.phone ?? "No Phone"
        
        // ✅ استخدام البيانات الحقيقية فقط
        let realDescription = receivedServiceDetails ?? "No details provided"
        
        // ✅ التأكد من أن الإضافات ليست فارغة
        var itemsText = receivedServiceItems ?? "None"
        if itemsText.isEmpty { itemsText = "None" }
        
        let newBooking = BookingModel(
            seekerName: seekerName,
            serviceName: serviceName,
            date: date,
            status: .upcoming,
            providerName: providerName,
            email: seekerEmail,
            phoneNumber: seekerPhone,
            price: price,
            instructions: itemsText,            // حفظ الإضافات هنا
            descriptionText: realDescription    // حفظ الوصف الحقيقي هنا
        )
        
        ServiceManager.shared.saveBooking(booking: newBooking) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showSuccessAlert(booking: newBooking)
                } else {
                    // Error handling
                }
            }
        }
    }
    
    func showSuccessAlert(booking: BookingModel) {
        let alert = UIAlertController(title: "Success", message: "Booking Confirmed!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        if #available(iOS 14.0, *) {
            var bg = UIBackgroundConfiguration.clear()
            bg.backgroundColor = .white
            bg.cornerRadius = 16
            bg.backgroundInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            cell.backgroundConfiguration = bg
        }
    }
}
