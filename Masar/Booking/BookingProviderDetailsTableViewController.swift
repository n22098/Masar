import UIKit

class BookingProviderDetailsTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var statusInfoLabel: UILabel!

    // MARK: - Variables
    var bookingData: BookingModel?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    var onStatusChanged: ((BookingStatus) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateData()
    }

    // MARK: - Populate Data
    private func populateData() {
        guard let data = bookingData else { return }

        seekerNameLabel?.text = data.seekerName
        emailLabel?.text = data.email
        phoneLabel?.text = data.phoneNumber
        dateLabel?.text = data.dateString
        priceLabel?.text = data.priceString
        serviceNameLabel?.text = data.serviceName
        priceLabel?.textColor = brandColor
        instructionsLabel?.text = data.instructions
        descriptionLabel?.text = data.descriptionText
        
        switch data.status {
        case .upcoming:
            cancelButton.isHidden = false
            completeButton.isHidden = false
            statusInfoLabel.isHidden = true
            
        case .completed:
            cancelButton.isHidden = true
            completeButton.isHidden = true
            statusInfoLabel.isHidden = false
            statusInfoLabel.text = "APPOINTMENT COMPLETED!"
            statusInfoLabel.textColor = brandColor
            
        case .canceled:
            cancelButton.isHidden = true
            completeButton.isHidden = true
            statusInfoLabel.isHidden = false
            statusInfoLabel.text = "APPOINTMENT CANCELED!"
            statusInfoLabel.textColor = .red
        }
    }

    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        guard let bookingId = bookingData?.id else { return }

        let alert = UIAlertController(title: "Cancel Booking",
                                      message: "Are you sure you want to cancel this booking?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            
            // 🔥 Firebase Update: Cancelled
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .canceled) { success in
                DispatchQueue.main.async {
                    if success {
                        // 1. تحديث البيانات محلياً
                        self?.bookingData?.status = .canceled
                        self?.populateData()
                        
                        // 2. إبلاغ الصفحة السابقة
                        self?.onStatusChanged?(.canceled)
                        
                        // 3. رسالة نجاح صغيرة (اختياري)
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
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        guard let bookingId = bookingData?.id else { return }

        let alert = UIAlertController(title: "Complete Booking",
                                      message: "Are you sure you want to complete this booking?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            
            // 🔥 Firebase Update: Completed
            ServiceManager.shared.updateBookingStatus(bookingId: bookingId, newStatus: .completed) { success in
                DispatchQueue.main.async {
                    if success {
                        // 1. تحديث البيانات محلياً
                        self?.bookingData?.status = .completed
                        self?.populateData()
                        
                        // 2. إبلاغ الصفحة السابقة
                        self?.onStatusChanged?(.completed)
                        
                        // 3. رسالة نجاح
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
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to update booking status. Please check your connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
