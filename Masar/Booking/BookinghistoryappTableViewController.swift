import UIKit

class Bookinghistoryapp: UITableViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var itemIncludesLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    var bookingData: BookingModel?
    var onStatusChanged: ((BookingStatus) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
    }
    
    func setupData() {
        if let booking = bookingData {
            dateLabel.text = booking.dateString
            priceLabel.text = booking.priceString
            
            statusLabel.text = booking.status.rawValue
            serviceNameLabel.text = booking.serviceName
            skillsLabel.text = booking.instructions
            descriptionLabel.text = booking.descriptionText
            itemIncludesLabel.text = "Source File, High Res, 3 Revisions"
            
            updateUIState(status: booking.status)
            
        } else {
            // Dummy Data
            dateLabel.text = "23 Dec 2025"
            statusLabel.text = "Upcoming"
            serviceNameLabel.text = "Website Starter"
            priceLabel.text = "85.000 BHD"
            skillsLabel.text = "Swift, UI/UX"
            descriptionLabel.text = "Full app development."
            itemIncludesLabel.text = "Source Code, Design System"
            cancelButton?.isEnabled = true
        }
    }
    
    func updateUIState(status: BookingStatus) {
        switch status {
        case .upcoming:
            statusLabel.textColor = .orange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel.textColor = .green
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel.textColor = .red
            cancelButton?.isEnabled = false
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.bookingData, let bookingId = booking.id else { return }
            
            // Update UI immediately
            self.statusLabel.text = "Canceled"
            self.statusLabel.textColor = .red
            self.cancelButton.isEnabled = false
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
                        self.statusLabel.text = "Upcoming"
                        self.statusLabel.textColor = .orange
                        self.cancelButton.isEnabled = true
                        self.bookingData?.status = .upcoming
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}
