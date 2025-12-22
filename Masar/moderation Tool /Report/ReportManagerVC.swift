//
//  ReportManagerVC.swift
//  Masar
//
//  Created by BP-36-201-08 on 15/12/2025.
//

import UIKit

class ReportManagerVC: UITableViewController {
    
    // 1. Create a sample data source (Replace this with your actual data later)
    var reportsArray: [Report] = [
        Report(id: "R101", reporter: "John Doe", email: "john@example.com", subject: "Pothole", description: "Large pothole on Main St."),
        Report(id: "R102", reporter: "Jane Smith", email: "jane@example.com", subject: "Street Light", description: "The light at the corner is flickering.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Report Management"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // We have 1 section of reports
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportsArray.count // Return the number of items in our array
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. Make sure "ReportCell" is the IDENTIFIER in Storyboard for the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath)

        let report = reportsArray[indexPath.row]
        cell.textLabel?.text = report.subject
        cell.detailTextLabel?.text = report.reporter

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 2. IMPORTANT: Change this to match the SEGUE IDENTIFIER in Storyboard
        // Usually, you should name the segue "showReportDetail"
        if segue.identifier == "showReportDetail" {
            
            if let destinationVC = segue.destination as? ReportDetailTVC,
               let indexPath = tableView.indexPathForSelectedRow {
                
                let selectedReport = reportsArray[indexPath.row]
                destinationVC.report = selectedReport
            }
        }
    }
        
    
}
