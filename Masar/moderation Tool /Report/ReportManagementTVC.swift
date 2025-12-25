import UIKit

class ReportManagementTVC: UITableViewController {
    
    private let viewModel = ReportManagementViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reports"
        
        // تفعيل الارتفاع التلقائي للخلية بناءً على محتوى الـ StackView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfReports()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReportItemCell", for: indexPath) as? ReportItemCell else {
            return UITableViewCell()
        }
        
        if let report = viewModel.report(at: indexPath.row) {
            cell.configure(with: report)
        }
        
        return cell
    }
}
