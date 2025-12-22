import UIKit

class BookingHistoryDetailsViewController: UITableViewController {

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
            // Only show cancel button if the booking is upcoming
            if bookingData?.status == .upcoming {
                navigationItem.rightBarButtonItem = cancelButton
                navigationItem.rightBarButtonItem?.tintColor = .systemRed
            }
            
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        }
        
        func populateData() {
            guard let booking = bookingData else { return }
            
            dateLabel?.text = booking.date
            statusLabel?.text = booking.status.rawValue
            nameLabel?.text = booking.providerName
            priceLabel?.text = booking.price
            skillsLabel?.text = booking.serviceName
            locationLabel?.text = "Online"
            
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
            let alert = UIAlertController(
                title: "Confirm Cancellation",
                message: "Do you want to confirm cancelling this booking?",
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.confirmCancellation()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
            present(alert, animated: true, completion: nil)
        }
        
        func confirmCancellation() {
            // ✅ This works now because 'status' is a 'var' in a Class
            bookingData?.status = .canceled
            
            // Update UI
            populateData()
            
            // Remove the Cancel button since it's now canceled
            navigationItem.rightBarButtonItem = nil
            
            let successAlert = UIAlertController(
                title: "Booking Cancelled",
                message: "Your booking has been cancelled successfully",
                preferredStyle: .alert
            )
            
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            present(successAlert, animated: true, completion: nil)
        }
    }
