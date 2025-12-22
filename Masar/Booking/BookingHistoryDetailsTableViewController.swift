import UIKit

class BookingHistoryDetailsViewController: UITableViewController {
    
    // MARK: - Outlets
    // اربط هذه العناصر في الستوري بورد
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    // MARK: - Variables
    var bookingData: BookingModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        fillData()
    }
    
    func fillData() {
        guard let data = bookingData else { return }
        
        serviceNameLabel.text = data.serviceName
        providerLabel.text = data.providerName
        priceLabel.text = data.price
        dateLabel.text = data.date
        descriptionLabel.text = data.descriptionText
        
        // تلوين الحالة
        let fullText = "status | \(data.status.rawValue)"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: (fullText as NSString).range(of: "status | "))
        
        let statusColor: UIColor
        switch data.status {
        case .upcoming: statusColor = .orange
        case .completed: statusColor = .green
        case .canceled: statusColor = .red
        }
        
        attributedString.addAttribute(.foregroundColor, value: statusColor, range: (fullText as NSString).range(of: data.status.rawValue))
        statusLabel.attributedText = attributedString
        
        // إخفاء زر الإلغاء إذا لم يكن قادماً
        if data.status != .upcoming {
            cancelButton.isEnabled = false
        }
    }
    
    // أكشن زر الكنسل
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Booking", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            // تحديث الحالة
            self.updateUIForCancellation()
        }))
        present(alert, animated: true)
    }
    
    func updateUIForCancellation() {
        // تحديث الواجهة فورياً
        statusLabel.text = "status | Canceled"
        statusLabel.textColor = .red
        cancelButton.isEnabled = false
    }
}
