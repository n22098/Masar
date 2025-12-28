//
//  ReportItem.swift
//  Masar
//
//  Created by BP-36-213-19 on 28/12/2025.
//
import Foundation

struct ReportItem: Identifiable {
    // We use UUID to satisfy the Identifiable protocol,
    // or you can use the reportID if it is always unique.
    let id = UUID()
    
    let reportID: String
    let subject: String
    let reporter: String
    
    // Optional: Add a date or status if needed later
    // let dateReported: Date
}
