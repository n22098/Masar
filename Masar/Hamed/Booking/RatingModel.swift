//
//  RatingModel.swift
//  Masar
//
//  Created by BP-36-212-14 on 30/12/2025.
//

import Foundation

// هذا هو الموديل الناقص الذي يسبب الخطأ
struct Rating: Codable {
    var stars: Double
    var feedback: String
    var date: Date
    var bookingName: String?
    var username: String = "Guest" // قيمة افتراضية لأنك لم ترسلها في صفحة التقييم
}
