import UIKit

class ReportItemCell: UITableViewCell {
    
    // MARK: - IBOutlets
    // These must be connected in your Storyboard!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Setup font styles to prevent overlapping and look professional
        idLabel.font = .systemFont(ofSize: 12, weight: .bold)
        subjectLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
    }
}
