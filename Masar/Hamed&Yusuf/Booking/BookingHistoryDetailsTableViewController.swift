import UIKit

/// BookingHistoryDetailsViewController: Responsible for displaying the specific details of a single booking.
/// OOD Principle: Single Responsibility - This class only manages the detailed view of a booking,
/// keeping the history list and the details separated.
class BookingHistoryDetailsViewController: UITableViewController {
    
    // MARK: - Outlets
    // These outlets connect the Storyboard/UI elements to our code.
    // OOD Note: Using @IBOutlet is a form of 'Interface' where the UI communicates with the Controller.
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // MARK: - Variables
    /// bookingData: The "Model" object passed from the previous screen.
    /// It is optional because the view might load before the data arrives.
    var bookingData: BookingModel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Clean-up: Removing lines between empty cells
        tableView.separatorStyle = .none
        
        // Populate the UI with the passed data
        fillData()
    }
    
    /// fillData: Maps the properties from the BookingModel to the UI labels.
    /// OOD Principle: Abstraction - We use properties like 'dateString' and 'priceString'
    /// provided by the model instead of formatting the raw data here in the Controller.
    func fillData() {
        guard let data = bookingData else { return }
        
        // Setting text labels from the model
        serviceNameLabel.text = data.serviceName
        providerLabel.text = data.providerName
        
        // Final Solution: Utilizing formatted strings directly from the Model
        priceLabel.text = data.priceString
        dateLabel.text = data.dateString
        
        descriptionLabel.text = data.descriptionText
        
        // Status Logic: Dynamically styling the status label
        setupStatusLabel(status: data.status)
        
        // State Management: Disable the cancel button if the service is already finalized
        if data.status == .canceled || data.status == .completed {
            cancelButton.isEnabled = false
        } else {
            cancelButton.isEnabled = true
        }
    }
    
    /// setupStatusLabel: Enhances UI by applying different colors based on the booking status.
    /// OOD Principle: Encapsulation - The logic for how a status "looks" is encapsulated in this helper method.
    func setupStatusLabel(status: BookingStatus) {
        let fullText = "Status | \(status.rawValue)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Styling the prefix "Status | " in gray
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: (fullText as NSString).range(of: "Status | "))
        
        // OOD Principle: Polymorphism/Conditional Logic - Determining color based on the enum state
        let statusColor: UIColor
        switch status {
        case .upcoming: statusColor = .orange
        case .completed: statusColor = .green
        case .canceled: statusColor = .red
        }
        
        // Apply the dynamic color to the specific status text
        attributedString.addAttribute(.foregroundColor, value: statusColor, range: (fullText as NSString).range(of: status.rawValue))
        
        statusLabel.attributedText = attributedString
    }
    
    // MARK: - Actions
    
    /// Triggered when the user wants to cancel their booking.
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        // Confirmation Alert: Essential for good UX to prevent accidental actions
        let alert = UIAlertController(title: "Cancel Booking", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
            // Use [weak self] to prevent memory leaks during the closure execution
            self?.updateUIForCancellation()
        }))
        
        present(alert, animated: true)
    }
    
    /// Updates the screen state immediately after a successful cancellation.
    func updateUIForCancellation() {
        // Immediate Feedback: Informing the user the action was successful
        statusLabel.text = "Status | Canceled"
        statusLabel.textColor = .red
        cancelButton.isEnabled = false
    }

} // End of Class
