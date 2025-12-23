//
//  AccountOption.swift
//  Masar
//
//  Created by BP-36-212-05 on 15/12/2025.
//

import Foundation

enum AccountOptionType {
    case normal
    case destructive
}

struct AccountOption {
    let title: String
    let type: AccountOptionType
}
