import Foundation

class ReportManagementViewModel {
    private(set) var reports: [ReportItem] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        reports = [
            ReportItem(reportID: "#9821", subject: "Inappropriate Content", reporter: "Ahmed Mohamed"),
            ReportItem(reportID: "#9822", subject: "Spam Report", reporter: "Sara Khalid"),
            ReportItem(reportID: "#9823", subject: "Account Verification", reporter: "John Doe"),
            ReportItem(reportID: "#9824", subject: "Harassment", reporter: "Fatima Ali")
        ]
    }
    
    func numberOfReports() -> Int {
        return reports.count
    }
    
    func report(at index: Int) -> ReportItem? {
        guard index >= 0 && index < reports.count else { return nil }
        return reports[index]
    }
}
