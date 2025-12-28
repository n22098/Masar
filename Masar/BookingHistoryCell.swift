//
//  BookingHistoryCell.swift
//  Masar
//
//  Created by BP-36-212-14 on 22/12/2025.
//

import UIKit

class BookingHistoryCell: UITableViewCell {

    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    class BookingHistoryCell: UITableViewCell {
        @IBOutlet weak var ratingButton: UIButton!
        
        // Closure to handle the tap in the ViewController
        var onRatingTapped: (() -> Void)?

        @IBAction func ratingButtonAction(_ sender: UIButton) {
            onRatingTapped?()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(with booking: BookingModel) {

        // ✅ إذا أي outlet مو مربوط، لا تسوي crash — اطبع تحذير
        guard serviceNameLabel != nil,
              providerNameLabel != nil,
              dateLabel != nil,
              priceLabel != nil,
              statusLabel != nil else {
            print("❌ BookingHistoryCell outlets are not connected. Check storyboard wiring.")
            return
        }

        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = booking.date
        priceLabel.text = booking.price

        switch booking.status {
        case .upcoming:
            statusLabel.text = "Upcoming"
        case .completed:
            statusLabel.text = "Completed"
        case .canceled:
            statusLabel.text = "Canceled"
        }
    }
}

