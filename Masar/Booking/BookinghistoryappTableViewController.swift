import UIKit

class Bookinghistoryapp: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var serviceItemLabel: UILabel?
    @IBOutlet weak var cancelButton: UIBarButtonItem?

    var bookingData: BookingModel?
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
        // Ensure rows expand to fit the text
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func setupData() {
            if let booking = bookingData {
                dateLabel?.text = booking.dateString
                priceLabel?.text = booking.priceString
                statusLabel?.text = booking.status.rawValue
                serviceNameLabel?.text = booking.serviceName
                
                // Get raw data
                let rawDescription = booking.descriptionText
                // ✅ FIX: 'instructions' is a String, so we don't use 'if let'
                let rawInstructions = booking.instructions
                
                // 🛑 LOGIC TO HANDLE OLD vs NEW BOOKINGS 🛑
                
                // Case 1: OLD BOOKINGS (Description contains "Add-ons:")
                if rawDescription.contains("Add-ons:") {
                    let parts = rawDescription.components(separatedBy: "Add-ons:")
                    
                    // Part 0 is the Description (e.g. "Booking via App")
                    if parts.count > 0 {
                        descriptionLabel?.text = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    // Part 1 is the Items
                    if parts.count > 1 {
                        let extractedItems = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        serviceItemLabel?.text = extractedItems.isEmpty ? "None" : extractedItems
                    } else {
                        serviceItemLabel?.text = "None"
                    }
                    
                }
                // Case 2: NEW BOOKINGS (Clean description, items in instructions)
                else {
                    descriptionLabel?.text = rawDescription
                    
                    // ✅ FIX: Check the string directly
                    if rawInstructions != "No instructions" && !rawInstructions.isEmpty {
                        serviceItemLabel?.text = rawInstructions
                    } else {
                        serviceItemLabel?.text = "None"
                    }
                }
                
                updateUIState(status: booking.status)
                
            } else {
                // Dummy Data (For testing in Storyboard)
                dateLabel?.text = "27 Dec 2025"
                statusLabel?.text = "Upcoming"
                serviceNameLabel?.text = "Test Service"
                priceLabel?.text = "10.000 BHD"
                descriptionLabel?.text = "Test Description"
                serviceItemLabel?.text = "None"
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
                        self.onStatusChanged?(.canceled)
                    } else {
                        print("❌ Failed to cancel booking")
                        // Revert UI if failed
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to cancel booking.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                        
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
