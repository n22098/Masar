import UIKit

class ServiceHeaderCell: UITableViewCell {
    
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    func configure(name: String?, price: String?) {
        label1.text = "Service"
        label2.text = name
        label3.text = price
        label4.text = "Details"
    }
}
