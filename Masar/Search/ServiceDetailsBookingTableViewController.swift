import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var providerData: ServiceProviderModel?
    var receivedServiceDetails: String?
    
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
        // 1. Setup Bottom Button
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
        
        // 2. Setup Date Picker (Align Left)
        if let picker = datePicker {
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .leading
        }
        
        // 3. Table Style
        tableView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    }
    
    // ✅ MARK: - Navigation Bar Setup - Changed Cancel to Book
    func setupNavigationBar() {
        // Create Book button on the right
        let bookButton = UIBarButtonItem(title: "Book", style: .plain, target: self, action: #selector(topBookTapped))
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
    }
    
    // ✅ Top Book button action - shows confirmation dialog
    @objc func topBookTapped() {
        showBookingConfirmation()
    }
    
    func fillData() {
        serviceNameLabel?.text = receivedServiceName ?? "Unknown Service"
        
        // Setup Price
        if let price = receivedServicePrice {
            let cleanPrice = price.replacingOccurrences(of: "BHD ", with: "")
            priceLabel?.text = cleanPrice
        } else {
            priceLabel?.text = "0"
        }
    }

    // MARK: - Book Action (Connected to Bottom Button)
    @IBAction func bookButtonPressed(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        showBookingConfirmation()
    }
    
    // ✅ Show Confirmation Dialog (same for both buttons)
    func showBookingConfirmation() {
        let confirmAlert = UIAlertController(
            title: "Confirm Booking",
            message: "Are you sure you want to proceed with the booking?",
            preferredStyle: .alert
        )

        // Cancel button
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Book button (bold)
        let bookAction = UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            self?.saveBookingToFirebase()
        }
        confirmAlert.addAction(bookAction)
        
        // Make "Book" button bold
        confirmAlert.preferredAction = bookAction
        
        present(confirmAlert, animated: true)
    }
    
    // MARK: - Firebase Logic
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
        
        // Create Booking Object
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
        
        // Save
        ServiceManager.shared.saveBooking(booking: newBooking) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showSuccessAlert(booking: newBooking)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Failed to save.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    // ✅ MARK: - Success Alert with Date and Details
    func showSuccessAlert(booking: BookingModel) {
        // Format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formattedDate = dateFormatter.string(from: booking.date)
        
        // Create detailed message
        let message = """
        Successfully booked!
        
        Service: \(booking.serviceName)
        Date: \(formattedDate)
        Price: \(booking.priceString)
        
        Your booking has been confirmed.
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
}
