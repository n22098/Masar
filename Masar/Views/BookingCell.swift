import UIKit

class BookingCell: UITableViewCell {

    @IBOutlet weak var seekerLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    // ✅ callback when user taps "Request/Book" (if you have a button)
    var onBookingTapped: (() -> Void)?

    // لو عندك زر في الستوريبورد اربطه هنا
    @IBOutlet weak var bookButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        bookButton?.addTarget(self, action: #selector(bookTapped), for: .touchUpInside)
    }

    @objc private func bookTapped() {
        onBookingTapped?()
    }

    // ✅ for ServiceItemTableViewController (name + price)
    func configure(name: String, price: String) {
        serviceNameLabel.text = name
        dateLabel.text = price
        seekerLabel.text = "" // مو لازم هنا
    }
}
