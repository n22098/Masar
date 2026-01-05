
////  ServiceItemCell.swift
////  Masar
////
////  Created by Moe Radhi  on 17/12/2025.
////
//
//import UIKit
//
//class ServiceItemCell: UITableViewCell {
//
//    // MARK: - Outlets
//    @IBOutlet weak var serviceNameLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var detailsLabel: UILabel!
//    @IBOutlet weak var bookingButton: UIButton!
//    
//    // MARK: - Actions Closure
//    var onBookingTapped: (() -> Void)?
//
//    // MARK: - Button Action
//    @IBAction func bookingButtonAction(_ sender: Any) {
//        onBookingTapped?()
//    }
//    
//    // MARK: - Configuration
//    func configure(with item: ServiceItem) {
//        serviceNameLabel.text = item.name
//        priceLabel.text = item.price
//        detailsLabel?.text = item.details
//        
//        bookingButton.layer.cornerRadius = 8
//        bookingButton.layer.borderWidth = 1
//        bookingButton.layer.borderColor = UIColor.systemBlue.cgColor
//    }
//}
