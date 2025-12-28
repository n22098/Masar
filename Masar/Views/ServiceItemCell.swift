//
//  ServiceItemCell.swift
//  Masar
//
//  Created by Moe Radhi  on 17/12/2025.
//

import UIKit

class ServiceItemCell: UITableViewCell {

    // MARK: - Outlets
    // تأكد من توصيل هذه العناصر في الستوري بورد بالخلية في الصفحة الثانية
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel! // إذا كان لديك ليبل للتفاصيل
    @IBOutlet weak var bookingButton: UIButton!
    
    // MARK: - Actions Closure
    // هذا الكلوجر عشان نستلم ضغطة الزر في الكنترولر
    var onBookingTapped: (() -> Void)?

    // MARK: - Button Action
    @IBAction func bookingButtonAction(_ sender: Any) {
        // تشغيل الكلوجر عند الضغط
        onBookingTapped?()
    }
    
    // MARK: - Configuration
    func configure(with item: ServiceItem) {
        serviceNameLabel.text = item.name
        priceLabel.text = item.price
        detailsLabel?.text = item.details
        
        // تنسيق الزر (اختياري)
        bookingButton.layer.cornerRadius = 8
        bookingButton.layer.borderWidth = 1
        bookingButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
}
