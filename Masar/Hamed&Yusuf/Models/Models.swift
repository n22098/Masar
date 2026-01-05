//
//  Models.swift
//  Masar
//
//  Created by Moe Radhi  on 17/12/2025.
//

import Foundation

enum ServiceCategory {
    case itSolutions
    case teaching
    case digitalServices
}

struct erviceProviderModel {
    let name: String
    let role: String
    let rating: String
    let imageName: String
    let category: ServiceCategory
}
//
//struct ServiceItem {
//    let name: String
//    let price: String
//    let details: String
//}
