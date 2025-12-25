//
//  ReportItem.swift
//  Masar
//
//  Created by BP-36-212-13 on 25/12/2025.
//
import Foundation
import UIKit

// MARK: - Data Model
struct ReportItem {
    let reportID: String
    let subject: String
    let status: ReportStatus
    
    enum ReportStatus: String {
        case pending = "Pending"
        case underReview = "Under Review"
        case resolved = "Resolved"
        case rejected = "Rejected"
        
        var color: UIColor {
            switch self {
            case .pending:
                return .systemOrange
            case .underReview:
                return .systemBlue
            case .resolved:
                return .systemGreen
            case .rejected:
                return .systemRed
            }
        }
    }
    
    init(reportID: String, subject: String, status: String) {
        self.reportID = reportID
        self.subject = subject
        self.status = ReportStatus(rawValue: status) ?? .pending
    }
}
