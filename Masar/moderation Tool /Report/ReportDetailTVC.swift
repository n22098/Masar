import UIKit

class ReportDetailTVC: UITableViewController {

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var report: Report?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        configureView()
    }

    func configureView() {
        guard let report = report else { return }
        
        idLabel.text = report.id
        reporterLabel.text = report.reporter
        emailLabel.text = report.email
        subjectLabel.text = report.subject
        descriptionLabel.text = report.description
    }

    // NOTE: DELETED numberOfSections, numberOfRowsInSection, and cellForRowAt.
    // Static cells do not need them and will break if they return 0.
}
