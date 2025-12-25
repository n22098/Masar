import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
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
        fillData()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // 1) نفس خلفية Add Service
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 12
        }
        
        // 2) تنسيق الزر السفلي (نفس ما عندك)
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
        
        // 3) تنسيق اختيار التاريخ (نفس ما عندك)
        if let picker = datePicker {
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .leading
        }
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
        
        // 3. الوصف
        if let details = receivedServiceDetails, !details.isEmpty {
            descriptionLabel?.text = details
            descriptionLabel?.textColor = .black
        } else {
            descriptionLabel?.text = "No description details available."
            descriptionLabel?.textColor = .darkGray
        }
        
        descriptionLabel?.numberOfLines = 0
        descriptionLabel?.lineBreakMode = .byWordWrapping
        
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
    
    // MARK: - Table View Styling (Card Style مثل Add Service)
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        let topBottom: CGFloat = 6
        let side: CGFloat = 16
        let corner: CGFloat = 14
        
        if #available(iOS 14.0, *) {
            var bg = UIBackgroundConfiguration.clear()
            bg.backgroundColor = .white
            bg.cornerRadius = corner
            
            // ✅ هذا اللي يسوي “مسافة” بين الصفوف
            bg.backgroundInsets = NSDirectionalEdgeInsets(top: topBottom,
                                                          leading: side,
                                                          bottom: topBottom,
                                                          trailing: side)
            
            cell.backgroundConfiguration = bg
        }
        
        // ✅ ظل خفيف لكل كرت
        let shadowRect = cell.bounds.insetBy(dx: side, dy: topBottom)
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.05
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 8
        cell.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: corner).cgPath
    }
}
