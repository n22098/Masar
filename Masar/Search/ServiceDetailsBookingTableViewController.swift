import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedLocation: String?
    
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fillData()
    }

    // MARK: - Setup UI
    func setupUI() {
        // تصميم الزر
        confirmButton?.layer.cornerRadius = 12
        confirmButton?.backgroundColor = brandColor
        confirmButton?.setTitleColor(.white, for: .normal)
        confirmButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // إعدادات الجدول
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // Date picker styling
        datePicker?.preferredDatePickerStyle = .compact
        datePicker?.minimumDate = Date()
        datePicker?.tintColor = brandColor
    }
    
    func setupNavigationBar() {
        title = "Booking"
        
        // إجبار العنوان أن يكون صغيراً
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Add Book button on right
        let bookButton = UIBarButtonItem(
            title: "Book",
            style: .done,
            target: self,
            action: #selector(bookButtonPressed)
        )
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
    }

    func fillData() {
        serviceNameLabel?.text = receivedServiceName ?? "Unknown Service"
        priceLabel?.text = receivedServicePrice ?? "BHD 0.000"
        locationLabel?.text = receivedLocation ?? "Online"
    }

    // MARK: - Book Action
    @IBAction func bookButtonPressed(_ sender: Any) {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let confirmAlert = UIAlertController(
            title: "Confirm Booking",
            message: "Are you sure you want to proceed with this booking?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        confirmAlert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.showSuccessAlert()
        })

        present(confirmAlert, animated: true)
    }

    // MARK: - Success Logic
    func showSuccessAlert() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: datePicker?.date ?? Date())

        let successAlert = UIAlertController(
            title: "🎉 Booking Confirmed!",
            message: "Your booking for '\(receivedServiceName ?? "Service")' has been confirmed.\n\nDate: \(dateString)\nLocation: \(receivedLocation ?? "TBD")",
            preferredStyle: .alert
        )

        successAlert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            // Add success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Navigate back to root
            self?.navigationController?.popToRootViewController(animated: true)
        })

        present(successAlert, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}
