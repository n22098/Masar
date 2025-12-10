//
//  ChatMessage.swift
//  Masar
//
//  Created by BP-36-201-07 on 10/12/2025.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let time: String
}
