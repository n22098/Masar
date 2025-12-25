import UIKit

class ReportItemCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "ReportItemCell"
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        idLabel?.text = nil
        subjectLabel?.text = nil
        statusLabel?.text = nil
    }
    
    // MARK: - Configuration
    private func configureAppearance() {
        // Cell styling
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        
        // ID Label styling
        idLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        idLabel?.textColor = .systemGray
        
        // Subject Label styling
        subjectLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subjectLabel?.textColor = .label
        subjectLabel?.numberOfLines = 2
        
        // Status Label styling
        statusLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
    func configure(with report: ReportItem) {
        idLabel?.text = report.reportID
        subjectLabel?.text = report.subject
        statusLabel?.text = report.status.rawValue
        statusLabel?.textColor = report.status.color
    }
}
