import UIKit

class Bookinghistoryapp: UITableViewController {

    // ✅ Changed from ! to ? to prevent crashes
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var cancelButton: UIBarButtonItem?

    var bookingData: BookingModel?
    var onStatusChanged: ((BookingStatus) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    func setupData() {
        if let booking = bookingData {
            dateLabel?.text = booking.dateString
            priceLabel?.text = booking.priceString
            
            statusLabel?.text = booking.status.rawValue
            serviceNameLabel?.text = booking.serviceName
            descriptionLabel?.text = booking.descriptionText
            updateUIState(status: booking.status)
            
        } else {
            // Dummy Data
            dateLabel?.text = "23 Dec 2025"
            statusLabel?.text = "Upcoming"
            serviceNameLabel?.text = "Website Starter"
            priceLabel?.text = "85.000 BHD"
            descriptionLabel?.text = "Full app development."
            cancelButton?.isEnabled = true
        }
    }
    
    func updateUIState(status: BookingStatus) {
        switch status {
        case .upcoming:
            statusLabel?.textColor = .orange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel?.textColor = .green
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel?.textColor = .red
            cancelButton?.isEnabled = false
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.bookingData, let bookingId = booking.id else { return }
            
            // Update UI immediately
            self.statusLabel?.text = "Canceled"
            self.statusLabel?.textColor = .red
            self.cancelButton?.isEnabled = false
            self.bookingData?.status = .canceled
            
            // Update Firebase
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Booking canceled successfully")
                        // Notify the list view about the status change
                        self.onStatusChanged?(.canceled)
                    } else {
                        print("❌ Failed to cancel booking")
                        // Show error alert
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to cancel booking. Please try again.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                        
                        // Revert UI changes
                        self.statusLabel?.text = "Upcoming"
                        self.statusLabel?.textColor = .orange
                        self.cancelButton?.isEnabled = true
                        self.bookingData?.status = .upcoming
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}
