//
//  Categorycell.swift
//  Masar
//
//  Created by BP-36-215-13 on 28/12/2025.
//
import UIKit

class Categorycell: UITableViewCell {

    // 1. If you have a Label in your storyboard cell, connect it here
    // @IBOutlet weak var cellTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // 2. Add the missing function here:
    func configure(title: String) {
        // This is where you apply the text to your UI elements
        // For example, if you have a label named titleLabel:
        // titleLabel.text = title
        
        print("Cell configured with title: \(title)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
