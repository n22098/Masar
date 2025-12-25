import UIKit

class ReportManagementTVC: UITableViewController {
    
    // MARK: - Properties
    private let viewModel = ReportManagementViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Report Management"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        // Row heights
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        // Remove empty cells
        tableView.tableFooterView = UIView()
        
        // Separator styling
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .systemGray5
        
        // Register cell if needed (if not using storyboard)
        // tableView.register(UINib(nibName: "ReportItemCell", bundle: nil), forCellReuseIdentifier: ReportItemCell.identifier)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfReports()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReportItemCell.identifier,
            for: indexPath
        ) as? ReportItemCell else {
            print("❌ Error: Could not dequeue ReportItemCell")
            return UITableViewCell()
        }
        
        if let report = viewModel.report(at: indexPath.row) {
            cell.configure(with: report)
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let report = viewModel.report(at: indexPath.row) else { return }
        
        print("Selected report: \(report.reportID)")
        showReportDetails(report)
    }
    
    // MARK: - Navigation
    
    private func showReportDetails(_ report: ReportItem) {
        // TODO: Navigate to detail view controller
        // let detailVC = ReportDetailViewController(report: report)
        // navigationController?.pushViewController(detailVC, animated: true)
        
        // Or using segue:
        // performSegue(withIdentifier: "ShowReportDetails", sender: report)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReportDetails",
           let report = sender as? ReportItem {
            // Pass report to detail view controller
            // if let detailVC = segue.destination as? ReportDetailViewController {
            //     detailVC.report = report
            // }
        }
    }
}

// MARK: - Search Functionality (Optional)
extension ReportManagementTVC: UISearchResultsUpdating {
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search reports..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        // Implement search filtering
        // let filteredReports = viewModel.searchReports(with: searchText)
        // Update table view with filtered results
        tableView.reloadData()
    }
}
