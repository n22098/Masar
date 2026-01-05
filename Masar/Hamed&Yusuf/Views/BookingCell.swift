// ===================================================================================
// BOOKING CELL (TABLE VIEW CELL)
// ===================================================================================
// PURPOSE: A custom cell design used to display individual booking details
// within the bookings list.
//
// KEY FEATURES:
// 1. Data Binding: Takes a 'BookingModel' and populates the UI labels.
// 2. Dynamic Styling: Changes the status text color (Blue/Green/Red) based on the booking state.
// 3. Action Handling: Uses a closure (Callback) to handle button taps inside the cell.
// ===================================================================================

import UIKit

class BookingCell: UITableViewCell {

    // MARK: - Storyboard Outlets
    // These connect the code to the visual elements in the Interface Builder.
    @IBOutlet weak var seekerLabel: UILabel!       // Displays the Provider/Seeker Name
    @IBOutlet weak var serviceNameLabel: UILabel!  // Displays the Service Title
    @IBOutlet weak var dateLabel: UILabel!         // Displays Date & Time
    @IBOutlet weak var statusLabel: UILabel!       // Displays Status (Upcoming, Completed, etc.)
    @IBOutlet weak var priceLabel: UILabel!        // Displays Price
    @IBOutlet weak var placeLabel: UILabel!        // Displays Location
    @IBOutlet weak var bookButton: UIButton?       // Optional Action Button (e.g., "Rebook" or "Cancel")
    
    // MARK: - Callback Closure
    // This variable holds a function that will be executed when the button is tapped.
    // We use this to tell the TableViewController that a specific row's button was pressed.
    var onBookingTapped: (() -> Void)?

    // MARK: - Lifecycle
    // awakeFromNib is called once when the cell is loaded from the Storyboard.
    // It is the perfect place for one-time setup like corner radius or shadow.
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Connect the button tap event to our code
        bookButton?.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)
        
        // Apply "Card" styling to the cell
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.selectionStyle = .none // Prevents the cell from turning gray when clicked
    }

    // MARK: - Actions
    // Triggered when the user taps the button inside the cell
    @objc private func bookTapped() {
        // Execute the closure provided by the Controller
        onBookingTapped?()
    }

    // MARK: - Configuration Method
    // This method is called by `cellForRowAt` in the TableViewController.
    // It maps the data from the 'BookingModel' to the UI elements.
    func configure(with model: BookingModel) {
        serviceNameLabel.text = model.serviceName
        seekerLabel.text = model.providerName
        
        // Mapping formatted strings from the model
        dateLabel.text = model.dateString
        priceLabel.text = model.priceString
        
        // Set basic status text
        statusLabel.text = model.status.rawValue
        placeLabel.text = "Bahrain" // Static location for now
        
        // Dynamic Status Coloring
        // Changes the text color to give visual feedback on the booking state.
        switch model.status {
        case .upcoming:
            statusLabel.textColor = .systemBlue  // Blue for future events
        case .completed:
            statusLabel.textColor = .systemGreen // Green for successful completion
        case .canceled:
            statusLabel.textColor = .systemRed   // Red for cancellations
        }
    }
}
