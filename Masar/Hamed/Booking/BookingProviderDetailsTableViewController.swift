import UIKit

/// BookingProviderDetailsTableViewController: Manages the detailed view for a Service Provider.
/// OOD Principle: Inheritance - Inherits from UITableViewController to get built-in scrolling
/// and list management capabilities.
class BookingProviderDetailsTableViewController: UITableViewController {

    // MARK: - Outlets
    // These link the UI elements from the Storyboard to the code.
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var serviceItemLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var statusInfoLabel: UILabel!

    // MARK: - Variables
    /// bookingData: The specific data model for the current booking.
    var bookingData: BookingModel?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    /// onStatusChanged: A closure (callback) to update the previous screen when a status changes.
    /// OOD Principle: Communication Pattern - Allows decoupled communication between view controllers.
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Standard setup can go here
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure data is refreshed every time the view is about to be displayed.
        populateData()
    }

    // MARK: - Populate Data
    
    /// Maps the BookingModel properties to the UI and handles the logic for different states.
    /// OOD Principle: Encapsulation - All logic for 'How to show a booking' is kept in this private method.
    private func populateData() {
        guard let data = bookingData else { return }

        // Setting basic text values
        seekerNameLabel?.text = data.seekerName
        emailLabel?.text = data.email
        phoneLabel?.text = data.phoneNumber
        dateLabel?.text = data.dateString
        priceLabel?.text = data.priceString
        serviceNameLabel?.text = data.serviceName
        priceLabel?.textColor = brandColor
        descriptionLabel?.text = data.descriptionText
        
        // Logic for Instructions (Service Item): Handling nil or empty strings safely.
        let instructions = data.instructions ?? ""
        if !instructions.isEmpty && instructions != "None" {
            serviceItemLabel?.text = instructions
            serviceItemLabel?.textColor = .black
        } else {
            serviceItemLabel?.text = "None"
            serviceItemLabel?.textColor = .darkGray
        }
        serviceItemLabel?.numberOfLines = 0 // Allows text to wrap if it's long.
        
        // State Management switch: Changes the UI based on the booking's current status.
        switch data.status {
        case .upcoming:
            // Show action buttons, hide the static info label.
            cancelButton.isHidden = false
            completeButton.isHidden = false
            statusInfoLabel.isHidden = true
            
        case .completed:
            // Hide action buttons, show success info.
            cancelButton.isHidden = true
            completeButton.isHidden = true
            statusInfoLabel.isHidden = false
            statusInfoLabel.text = "APPOINTMENT COMPLETED!"
            statusInfoLabel.textColor = brandColor
            
        case .canceled:
            // Hide action buttons, show cancellation info.
            cancelButton.isHidden = true
            completeButton.isHidden = true
            statusInfoLabel.isHidden = false
            statusInfoLabel.text = "APPOINTMENT CANCELED!"
            statusInfoLabel.textColor = .red
        }
    }

    // MARK: - Actions
    
    /// Triggered when the provider wants to cancel a seeker's booking.
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        guard let bookingId = bookingData?.id else { return }

        let alert = UIAlertController(title: "Cancel Booking",
                                      message: "Are you sure you want to cancel this booking?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            
            // Asynchronous Task: Update Firebase database.
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                // OOD Principle: Thread Safety - UI updates must always happen on the Main Thread.
                DispatchQueue.main.async {
                    if success {
                        // 1. Update local model
                        self?.bookingData?.status = .canceled
                        // 2. Refresh the UI to reflect the change
                        self?.populateData()
                        // 3. Notify the parent list to update its data
                        self?.onStatusChanged?(.canceled)
                        
                        print("✅ Booking cancelled successfully in Firebase")
                    } else {
                        self?.showErrorAlert()
                    }
                }
            }
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Triggered when the provider marks the service as finished.
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        guard let bookingId = bookingData?.id else { return }

        let alert = UIAlertController(title: "Complete Booking",
                                      message: "Are you sure you want to complete this booking?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            
            // Interaction with Shared Service Manager (Singleton).
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .completed) { success in
                DispatchQueue.main.async {
                    if success {
                        // 1. Synchronize local data
                        self?.bookingData?.status = .completed
                        // 2. Refresh UI
                        self?.populateData()
                        // 3. Notify parent view
                        self?.onStatusChanged?(.completed)
                        
                        print("✅ Booking completed successfully in Firebase")
                    } else {
                        self?.showErrorAlert()
                    }
                }
            }
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Helper method to display error messages.
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to update booking status. Please check your connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
