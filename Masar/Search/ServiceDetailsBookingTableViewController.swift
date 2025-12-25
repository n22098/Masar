import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {

    // MARK: - Outlets
    // ⚠️ تنبيه: تأكد من إعادة ربط هذا العنصر في الـ Storyboard
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! // 👈 هذا هو العنصر المسؤول عن الوصف
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var providerData: ServiceProviderModel?
    
    // Brand Color
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        // استدعاء تعبئة البيانات
        fillData()
    }

    // MARK: - Setup UI
    func setupUI() {
        // 1. تنسيق الزر السفلي
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
        
        // 2. تنسيق اختيار التاريخ
        if let picker = datePicker {
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .leading
        }
        
        // 3. تنسيق الجدول
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        self.title = "Booking"
        let bookButton = UIBarButtonItem(title: "Book", style: .done, target: self, action: #selector(topBookTapped))
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func topBookTapped() {
        showBookingConfirmation()
    }
    
    // MARK: - Fill Data (تعبئة البيانات)
    func fillData() {
        // 1. الاسم
        serviceNameLabel?.text = receivedServiceName ?? "Unknown Service"
        
        // 2. السعر
        if let price = receivedServicePrice {
            let cleanPrice = price.replacingOccurrences(of: "BHD ", with: "")
            priceLabel?.text = cleanPrice
        } else {
            priceLabel?.text = "0"
        }
        
        // 3. الوصف (تم التعديل لضمان عدم ظهور النص الثابت)
        // نقوم بإجبار الـ Label على التحديث
        if let details = receivedServiceDetails, !details.isEmpty {
            descriptionLabel?.text = details
            descriptionLabel?.textColor = .black // التأكد من لون الخط
        } else {
            descriptionLabel?.text = "No description details available."
            descriptionLabel?.textColor = .darkGray
        }
        
        // السماح بتعدد الأسطر
        descriptionLabel?.numberOfLines = 0
        descriptionLabel?.lineBreakMode = .byWordWrapping
        
        // ⚠️ طباعة للتأكد من وصول البيانات (ستظهر في الـ Console بالأسفل)
        print("DEBUG: Description passed is: \(String(describing: receivedServiceDetails))")
    }

    // MARK: - Actions
    @IBAction func bookButtonPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        showBookingConfirmation()
    }
    
    // MARK: - Confirmation & Save
    func showBookingConfirmation() {
        let confirmAlert = UIAlertController(
            title: "Confirm Booking",
            message: "Are you sure you want to proceed?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let bookAction = UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            self?.saveBookingToFirebase()
        }
        confirmAlert.addAction(bookAction)
        confirmAlert.preferredAction = bookAction
        
        present(confirmAlert, animated: true)
    }
    
    func saveBookingToFirebase() {
        let serviceName = receivedServiceName ?? "Unknown Service"
        let priceString = receivedServicePrice?.replacingOccurrences(of: "BHD ", with: "") ?? "0"
        let price = Double(priceString) ?? 0.0
        let date = datePicker.date
        let providerName = providerData?.name ?? "Unknown Provider"
        
        let currentUser = UserManager.shared.currentUser
        let seekerName = currentUser?.name ?? "Guest User"
        let seekerEmail = currentUser?.email ?? "no-email@example.com"
        let seekerPhone = currentUser?.phone ?? "No Phone"
        
        let newBooking = BookingModel(
            seekerName: seekerName,
            serviceName: serviceName,
            date: date,
            status: .upcoming,
            providerName: providerName,
            email: seekerEmail,
            phoneNumber: seekerPhone,
            price: price,
            instructions: "No instructions",
            descriptionText: "Booking made via App"
        )
        
        ServiceManager.shared.saveBooking(booking: newBooking) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showSuccessAlert(booking: newBooking)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Failed to save booking.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    func showSuccessAlert(booking: BookingModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedDate = dateFormatter.string(from: booking.date)
        
        let message = """
        Successfully booked!
        
        Service: \(booking.serviceName)
        Date: \(formattedDate)
        Price: \(booking.priceString)
        """
        
        let successAlert = UIAlertController(
            title: "Booking Confirmed ✓",
            message: message,
            preferredStyle: .alert
        )

        successAlert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })

        present(successAlert, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .secondarySystemGroupedBackground
    }
}
