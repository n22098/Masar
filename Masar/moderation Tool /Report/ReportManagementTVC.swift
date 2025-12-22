import UIKit


class ReportManagementTVC: UITableViewController {

    // MARK: - Properties
    // Mock data based on your Report Management design
    let reports = [
        ReportItem(reportID: "ID: #9821", subject: "Inappropriate Content", status: "Pending"),
        ReportItem(reportID: "ID: #9822", subject: "Spam Report", status: "Under Review"),
        ReportItem(reportID: "ID: #9823", subject: "Account Verification", status: "Resolved")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report Management"
        
        // Cleanup the empty cells at the bottom
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure "reportCell" matches the Identifier you set in Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "showReportCell", for: indexPath)
        
        let report = reports[indexPath.row]

        // Accessing the 3 labels using Tags (Set these in Storyboard: 1, 2, and 3)
        if let idLabel = cell.viewWithTag(1) as? UILabel {
            idLabel.text = report.reportID
        }
        
        if let subjectLabel = cell.viewWithTag(2) as? UILabel {
            subjectLabel.text = report.subject
        }
        
        if let statusLabel = cell.viewWithTag(3) as? UILabel {
            statusLabel.text = report.status
            // Optional: Change color based on status
            statusLabel.textColor = report.status == "Pending" ? .systemOrange : .systemGray
        }

        return cell
    }


    }

