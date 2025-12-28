//
//  verificationCell.swift
//  Masar
//
//  Created by BP-36-215-13 on 28/12/2025.
//
import UIKit

class verificationCell: UITableViewCell {

    // If you have a label in your storyboard, connect it here:
    // @IBOutlet weak var verificationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Add this function to stop the error
    func configure(title: String) {
        // Example of setting the text if you have a label:
        // verificationLabel.text = title
        print("Verification cell updated to: \(title)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
