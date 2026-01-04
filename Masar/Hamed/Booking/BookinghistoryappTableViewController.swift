import UIKit

/// Bookinghistoryapp: A secondary detail view controller that handles specific booking actions.
/// OOD Principle: Delegation via Closures - This class uses a callback to notify the parent
/// controller when data has changed, ensuring data consistency across the app.
class Bookinghistoryapp: UITableViewController {

    // MARK: - Outlets
    // UI components are defined as optionals (?) to safely handle cases where the view might not be fully loaded.
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var serviceItemLabel: UILabel?
    @IBOutlet weak var cancelButton: UIBarButtonItem?

    // MARK: - Properties
    
    /// The specific data model for the booking being viewed.
    var bookingData: BookingModel?
    
    /// onStatusChanged: A closure (callback function).
    /// This allows this controller to "talk back" to the previous screen without knowing its exact type.
    /// OOD Principle: Loose Coupling - This screen doesn't need to know which screen opened it.
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        
        // Dynamic Cell Sizing: Allows the table cells to expand if the description text is long.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Setup Data
    
    /// Transfers values from the data model to the UI elements.
    func setupData() {
        // Safety Check: Exit early if no data was passed to this controller.
        guard let booking = bookingData else { return }
        
        // 1. Populating basic fields
        dateLabel?.text = booking.dateString
        priceLabel?.text = booking.priceString
        statusLabel?.text = booking.status.rawValue
        serviceNameLabel?.text = booking.serviceName
        
        // 2. Handling Optionals: Using Nil-Coalescing (??) to provide default text if data is missing.
        // This prevents the UI from showing "nil" or empty gaps.
        let description = booking.descriptionText ?? "No details available"
        let instructions = booking.instructions ?? "None"
        
        descriptionLabel?.text = description
        serviceItemLabel?.text = instructions.isEmpty ? "None" : instructions
        
        // 3. Update the UI colors and button states based on the current status.
        updateUIState(status: booking.status)
    }
    
    /// Logic to style the view based on whether the booking is Upcoming, Completed, or Canceled.
    func updateUIState(status: BookingStatus) {
        // OOD Principle: Type Safety - Using a Switch over an Enum ensures all possible cases are handled.
        switch status {
        case .upcoming:
            statusLabel?.textColor = .systemOrange
            cancelButton?.isEnabled = true
        case .completed:
            statusLabel?.textColor = .systemGreen
            cancelButton?.isEnabled = false
        case .canceled:
            statusLabel?.textColor = .systemRed
            cancelButton?.isEnabled = false
        }
    }
    
    // MARK: - Actions
    
    /// Logic for the Cancel button action.
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Do you want to confirm cancelling this booking?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // Use [weak self] to avoid memory retention cycles.
            guard let self = self, let booking = self.bookingData, let bookingId = booking.id else { return }
            
            // 1. Reactive UI: Update the interface immediately so the user feels the app is fast.
            self.statusLabel?.text = "Canceled"
            self.statusLabel?.textColor = .red
            self.cancelButton?.isEnabled = false
            self.bookingData?.status = .canceled
            
            // 2. Data Synchronization: Execute the callback to update the 'History' list on the previous screen.
            self.onStatusChanged?(.canceled)
            
            // 3. Persistence: Update the status in the backend (Firebase).
            // OOD Principle: Abstraction - Calling ServiceManager hides the networking complexity.
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                if !success {
                    // Optional: Error handling if the internet connection fails.
                    print("⚠️ Failed to update status in Firebase")
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // TableView delegate method to ensure rows resize properly for long text.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
