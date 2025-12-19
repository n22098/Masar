//
//  ServiceModel.swift
//  Masar
//
//  Created by Moe Radhi  on 19/12/2025.
//

import Foundation

struct ServiceModel {
    var id: String
    var name: String
    var price: String
    var description: String
    var icon: String
    var category: String
    var isActive: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         price: String,
         description: String,
         icon: String = "briefcase.fill",
         category: String = "IT Solutions",
         isActive: Bool = true) {
        self.id = id
        self.name = name
        self.price = price
        self.description = description
        self.icon = icon
        self.category = category
        self.isActive = isActive
    }
}
