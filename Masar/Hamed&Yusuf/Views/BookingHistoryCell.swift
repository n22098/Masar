// ===================================================================================
// BOOKING HISTORY CELL
// ===================================================================================
// PURPOSE: A custom cell used to display past bookings in the history list.
//
// KEY FEATURES:
// 1. Data Binding: Maps the BookingModel properties directly to UI labels.
// 2. Visual Feedback: Uses color coding (Green/Red/Orange) to indicate status.
// 3. Safety: Includes checks to ensure UI elements exist before accessing them.
// ===================================================================================

import UIKit

class BookingHistoryCell: UITableViewCell {

    // MARK: - Storyboard Outlets
    // Connections to the labels in the Interface Builder
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Lifecycle
    // Called when the cell is initialized from the Storyboard.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Disable the gray background highlight when a user taps the cell
        selectionStyle = .none
    }

    // MARK: - Configuration
    // Populates the cell with data from a specific booking object.
    func configure(with booking: BookingModel) {
        
        // Safety Check: Ensure the outlet is connected to avoid crashes
        guard serviceNameLabel != nil else { return }

        // Bind text data to labels
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        
        // Uses the formatted string properties from the model
        dateLabel.text = booking.dateString
        priceLabel.text = booking.priceString

        // Set the status text (e.g., "Completed", "Canceled")
        statusLabel.text = booking.status.rawValue
        
        // Dynamic Status Styling
        // Changes the text color based on the booking status for better UX.
        switch booking.status {
        case .upcoming:
            statusLabel.textColor = .systemOrange // Orange indicates pending/future
        case .completed:
            statusLabel.textColor = .systemGreen  // Green indicates success
        case .canceled:
            statusLabel.textColor = .systemRed    // Red indicates cancellation
        }
    }
}
