import UIKit

// The data model


class ReportManagementTVC: UITableViewController {

    // Mock data
    let reports = [
        ReportItem(reportID: "ID: #9821", subject: "Inappropriate Content", status: "Pending"),
        ReportItem(reportID: "ID: #9822", subject: "Spam Report", status: "Under Review"),
        ReportItem(reportID: "ID: #9823", subject: "Account Verification", status: "Resolved")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report Management"
        
        // AUTO LAYOUT FIX: These lines allow the cell to grow and fit the labels
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 'as? ReportItemCell' connects this code to your custom class
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showReportCell", for: indexPath) as? ReportItemCell else {
            return UITableViewCell()
        }
        
        let report = reports[indexPath.row]

        // Set text safely (using '?' prevents the "found nil" crash)
        cell.idLabel?.text = report.reportID
        cell.subjectLabel?.text = report.subject
        cell.statusLabel?.text = report.status
        
        // Apply colors based on status
        switch report.status {
        case "Pending":
            cell.statusLabel?.textColor = .systemOrange
        case "Resolved":
            cell.statusLabel?.textColor = .systemGreen
        default:
            cell.statusLabel?.textColor = .systemGray
        }

        return cell
    }
}
