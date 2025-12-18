import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!

    // MARK: - Data
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedLocation: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fillData()
    }

    // MARK: - UI Setup
    func setupUI() {
        title = "Check Out"
        confirmButton.layer.cornerRadius = 8
    }

    func fillData() {
        serviceNameLabel.text = receivedServiceName ?? ""
        priceLabel.text = receivedServicePrice ?? ""
        locationLabel.text = receivedLocation ?? "Online"
    }

    // MARK: - Book Button
    @IBAction func bookButtonPressed(_ sender: Any) {

        let confirmAlert = UIAlertController(
            title: "Confirm Booking",
            message: "Are you sure you want to proceed?",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.showSuccessAlert()
        })

        present(confirmAlert, animated: true)
    }

    // MARK: - Success Alert
    func showSuccessAlert() {

        let dateString = datePicker.date.formatted(
            date: .long,
            time: .shortened
        )

        let successAlert = UIAlertController(
            title: "Success! 🎉",
            message: "Booking confirmed for \(receivedServiceName ?? "")\nDate: \(dateString)",
            preferredStyle: .alert
        )

        successAlert.addAction(
            UIAlertAction(title: "Done", style: .default) { _ in

                // 🔁 رجوع لصفحة البداية
                self.navigationController?.popToRootViewController(animated: false)

                // 🏠 اختيار أول Tab (Search)
                if let tabBar = self.tabBarController {
                    tabBar.selectedIndex = 0
                }
            }
        )

        present(successAlert, animated: true)
    }
}
