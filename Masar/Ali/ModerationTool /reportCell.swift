//
//  reportCell.swift
//  Masar
//
//  Created by BP-36-215-13 on 28/12/2025.
//
import UIKit

class reportCell: UITableViewCell {

    // If you have a Label in your UI, connect it here
    // @IBOutlet weak var reportTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // ADD THIS METHOD:
    func configure(title: String) {
        // Apply the title to your UI element
        // reportTitleLabel.text = title
        print("Report cell configured with: \(title)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
