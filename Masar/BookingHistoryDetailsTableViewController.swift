import UIKit

class BookingHistoryDetailsTableViewController: UITableViewController {

    // MARK: - Data Variable (المتغير لاستقبال البيانات)
    var bookingData: BookingModel?

    // MARK: - Outlets (اربط هذه العناصر في الستوري بورد)
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!  // اسم الموظف
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel! // اسم الخدمة أو المهارات

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    func setupUI() {
        title = "Booking Details"
        
        // Add Cancel button in navigation bar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = cancelButton
        
        // إخفاء الخطوط الزائدة في الجدول
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }

    func populateData() {
        guard let booking = bookingData else { return }

        // تعبئة البيانات
        dateLabel?.text = booking.date
        statusLabel?.text = booking.status.rawValue
        nameLabel?.text = booking.providerName
        priceLabel?.text = booking.price
        skillsLabel?.text = booking.serviceName // سنعرض اسم الخدمة هنا
        locationLabel?.text = "Online" // قيمة افتراضية حالياً

        // تلوين الحالة
        switch booking.status {
        case .upcoming:
            statusLabel?.textColor = .systemBlue
        case .completed:
            statusLabel?.textColor = .systemGreen
        case .canceled:
            statusLabel?.textColor = .systemRed
        }
    }
    
    // MARK: - Cancel Booking Action
    @objc func cancelButtonTapped() {
        // Show confirmation alert like in image 2
        let alert = UIAlertController(
            title: "Confirm Cancellation",
            message: "Do you want to confirm cancelling this booking",
            preferredStyle: .alert
        )
        
        // Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Yes button
        let yesAction = UIAlertAction(title: "yes", style: .default) { [weak self] _ in
            self?.confirmCancellation()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func confirmCancellation() {
        // Update booking status to canceled
        bookingData?.status = .canceled
        
        // Update UI
        statusLabel?.text = "Canceled"
        statusLabel?.textColor = .systemRed
        
        // Show success message
        let successAlert = UIAlertController(
            title: "Booking Cancelled",
            message: "Your booking has been cancelled successfully",
            preferredStyle: .alert
        )
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Go back to previous screen
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(successAlert, animated: true, completion: nil)
        
        // Here you should also make an API call to cancel the booking on the server
        // cancelBookingOnServer(bookingId: bookingData?.id)
    }
}
