import UIKit

class BookingProviderDetailsTableViewController: UITableViewController {

    // MARK: - Variables
    var bookingData: DummyBookingModel?
    
    // MARK: - Outlets
    // Connect these from your Storyboard
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // The label that shows "APPOINTMENT COMPLETED!" or "APPOINTMENT CANCELED!"
    // Make sure to set this label as 'Hidden' in the storyboard by default
    @IBOutlet weak var statusInfoLabel: UILabel!
    
    // Action Buttons
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        // MARK: - UI Setup
        func setupUI() {
            guard let data = bookingData else { return }
            
            // Populate Data
            seekerNameLabel.text = data.seekerName
            emailLabel.text = data.email
            phoneLabel.text = data.phoneNumber
            dateLabel.text = data.date
            serviceNameLabel.text = data.serviceName
            priceLabel.text = data.price
            instructionsLabel.text = data.instructions
            
            // Set the initial state
            updateUIBasedOnStatus(status: data.status)
        }
        
        // Logic to show/hide buttons and update text
        func updateUIBasedOnStatus(status: DummyBookingStatus) {
            
            // Save the new status locally so it remembers it
            // (Note: This only saves it for this screen, not the list)
            // bookingData?.status = status
            
            switch status {
            case .upcoming:
                // Buttons are VISIBLE
                completeButton.isHidden = false
                cancelButton.isHidden = false
                
                // Description/Status text is HIDDEN
                statusInfoLabel.isHidden = true
                statusInfoLabel.text = ""
                
            case .completed:
                // Buttons are HIDDEN
                completeButton.isHidden = true
                cancelButton.isHidden = true
                
                // Show Success Message in the Description area
                statusInfoLabel.isHidden = false
                statusInfoLabel.text = "APPOINTMENT COMPLETED SUCCESSFULLY!"
                statusInfoLabel.textColor = .systemGreen
                
            case .cancelled:
                // Buttons are HIDDEN
                completeButton.isHidden = true
                cancelButton.isHidden = true
                
                // Show Cancel Message in the Description area
                statusInfoLabel.isHidden = false
                statusInfoLabel.text = "APPOINTMENT WAS CANCELLED."
                statusInfoLabel.textColor = .systemRed
            }
        }
        
        // MARK: - Actions
        // Make sure these circles are filled in your code!
        
        @IBAction func completeButtonTapped(_ sender: UIButton) {
            let alert = UIAlertController(title: "Complete Job", message: "Confirm completion?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                
                // 👇 THIS IS THE KEY PART
                // Update the UI immediately to hide buttons and show text
                self.updateUIBasedOnStatus(status: .completed)
                
            })
            present(alert, animated: true)
        }
        
        @IBAction func cancelButtonTapped(_ sender: UIButton) {
            let alert = UIAlertController(title: "Cancel Job", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default))
            alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { _ in
                
                // 👇 THIS IS THE KEY PART
                // Update the UI immediately to hide buttons and show text
                self.updateUIBasedOnStatus(status: .cancelled)
                
            })
            present(alert, animated: true)
        }
    }
