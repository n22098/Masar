//
//  Message.swift
//  Masar
//
//  Created by BP-36-212-19 on 11/12/2025.
//

import Foundation
import FirebaseFirestore

struct Message {
    let id: String
    let senderId: String
    let receiverId: String
    let text: String?
    let imageURL: String?
    let timestamp: Date
    let isRead: Bool // 🔥 إضافة لمعرفة هل قرأ الرسالة أم لا
}
