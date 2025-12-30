//
//  ReportItem.swift
//  Masar
//
//  Created by BP-36-213-19 on 28/12/2025.
//import Foundation
import FirebaseFirestore // Required for @DocumentID

struct ReportItem: Identifiable, Codable {
    @DocumentID var id: String? // Automatically takes the unique ID from the Firebase document
    
    let reportID: String
    let subject: String
    let reporter: String
}
