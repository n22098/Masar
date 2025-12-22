import UIKit

final class BookingProviderDetailsTableViewController: UITableViewController {

    // MARK: - Data
    var bookingData: BookingModel?

    // MARK: - Outlets (Storyboard)
    @IBOutlet weak var seekerNameLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?

    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var serviceNameLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var instructionsLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?

    /// Hidden by default in storyboard
    @IBOutlet weak var statusInfoLabel: UILabel?

    @IBOutlet weak var completeButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 🔎 Debugging: if any of these is nil, it's a storyboard connection/class issue.
        debugCheckOutlets()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // In case bookingData changes before the view appears again
        setupUI()
    }

    // MARK: - Debug Helpers
    private func debugCheckOutlets() {
        #if DEBUG
        if seekerNameLabel == nil { print("❌ seekerNameLabel is NOT connected") }
        if phoneLabel == nil { print("❌ phoneLabel is NOT connected") }
        if emailLabel == nil { print("❌ emailLabel is NOT connected") }

        if dateLabel == nil { print("❌ dateLabel is NOT connected") }
        if serviceNameLabel == nil { print("❌ serviceNameLabel is NOT connected") }
        if priceLabel == nil { print("❌ priceLabel is NOT connected") }
        if instructionsLabel == nil { print("❌ instructionsLabel is NOT connected") }
        if descriptionLabel == nil { print("❌ descriptionLabel is NOT connected") }

        if statusInfoLabel == nil { print("❌ statusInfoLabel is NOT connected") }
        if completeButton == nil { print("❌ completeButton is NOT connected") }
        if cancelButton == nil { print("❌ cancelButton is NOT connected") }
        #endif
    }

    // MARK: - UI Setup
    private func setupUI() {
        guard isViewLoaded else { return }
        guard let data = bookingData else {
            // If bookingData is not passed, keep UI safe
            seekerNameLabel?.text = ""
            emailLabel?.text = ""
            phoneLabel?.text = ""
            dateLabel?.text = ""
            serviceNameLabel?.text = ""
            priceLabel?.text = ""
            instructionsLabel?.text = ""
            descriptionLabel?.text = ""
            updateUIBasedOnStatus(status: .upcoming)
            return
        }

        seekerNameLabel?.text = data.seekerName
        emailLabel?.text = data.email
        phoneLabel?.text = data.phoneNumber

        dateLabel?.text = data.date
        serviceNameLabel?.text = data.serviceName
        priceLabel?.text = data.price
        instructionsLabel?.text = data.instructions
        descriptionLabel?.text = data.descriptionText

        updateUIBasedOnStatus(status: data.status)
    }

    private func updateUIBasedOnStatus(status: BookingStatus) {
        switch status {
        case .upcoming:
            completeButton?.isHidden = false
            cancelButton?.isHidden = false

            statusInfoLabel?.isHidden = true
            statusInfoLabel?.text = ""
            statusInfoLabel?.textColor = .label

        case .completed:
            completeButton?.isHidden = true
            cancelButton?.isHidden = true

            statusInfoLabel?.isHidden = false
            statusInfoLabel?.text = "APPOINTMENT COMPLETED SUCCESSFULLY!"
            statusInfoLabel?.textColor = .systemGreen

        case .canceled:
            completeButton?.isHidden = true
            cancelButton?.isHidden = true

            statusInfoLabel?.isHidden = false
            statusInfoLabel?.text = "APPOINTMENT WAS CANCELED."
            statusInfoLabel?.textColor = .systemRed
        }
    }

    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Cancel Booking",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.bookingData?.status = .canceled
            self.updateUIBasedOnStatus(status: .canceled)
        })

        present(alert, animated: true)
    }

    @IBAction func completeButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Complete Booking",
            message: "Are you sure you want to complete this booking?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self else { return }
            self.bookingData?.status = .completed
            self.updateUIBasedOnStatus(status: .completed)
        })

        present(alert, animated: true)
    }
}
