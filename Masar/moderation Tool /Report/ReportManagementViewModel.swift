import Foundation

class ReportManagementViewModel {
    
    // MARK: - Properties
    private(set) var reports: [ReportItem] = []
    
    // MARK: - Initialization
    init() {
        loadMockData()
    }
    
    // MARK: - Data Management
    private func loadMockData() {
        reports = [
            ReportItem(reportID: "#9821", subject: "Inappropriate Content", status: "Pending"),
            ReportItem(reportID: "#9822", subject: "Spam Report", status: "Under Review"),
            ReportItem(reportID: "#9823", subject: "Account Verification", status: "Resolved"),
            ReportItem(reportID: "#9824", subject: "Harassment Report", status: "Pending"),
            ReportItem(reportID: "#9825", subject: "Fake Profile", status: "Rejected")
        ]
    }
    
    // MARK: - Public Methods
    func numberOfReports() -> Int {
        return reports.count
    }
    
    func report(at index: Int) -> ReportItem? {
        guard index >= 0 && index < reports.count else { return nil }
        return reports[index]
    }
    
    func filterReports(by status: ReportItem.ReportStatus) -> [ReportItem] {
        return reports.filter { $0.status == status }
    }
    
    func searchReports(with query: String) -> [ReportItem] {
        guard !query.isEmpty else { return reports }
        return reports.filter {
            $0.reportID.lowercased().contains(query.lowercased()) ||
            $0.subject.lowercased().contains(query.lowercased())
        }
    }
}
