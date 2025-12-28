





import UIKit

class ModerationCell: UITableViewCell {

    // 1. Connect these to your labels in the Storyboard/Cell
    @IBOutlet weak var reportIDLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // 2. Add the missing configure method
    func configure(with report: ReportItem) {
        reportIDLabel.text = report.reportID
        subjectLabel.text = report.subject
        reporterLabel.text = "By: \(report.reporter)"
    }
}
