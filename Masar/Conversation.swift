//
//  Conversation.swift
//  Masar
//
<<<<<<< HEAD
//  Created by BP-36-212-19 on 11/12/2025.
//

import Foundation

struct Conversation {
    let id: UUID
    let user: User
    var messages: [Message]
}

// Sample data with unique messages per user.
enum SampleConversations {
    static let items: [Conversation] = [
        Conversation(
            id: UUID(),
            user: User(id: UUID(), name: "Sayed Husain", subtitle: "Software Engineer", avatarEmoji: "👨‍💻"),
            messages: [
                Message(id: UUID(), text: "Hi, I need to create a website for my work.", isIncoming: true, date: Date().addingTimeInterval(-3600)),
                Message(id: UUID(), text: "Sure—send me your requirements and I’ll propose a template or make a custom one.", isIncoming: false, date: Date().addingTimeInterval(-3500)),
                Message(id: UUID(), text: "Great, I’ll share it in a few hours.", isIncoming: true, date: Date().addingTimeInterval(-3400))
            ]
        ),
        Conversation(
            id: UUID(),
            user: User(id: UUID(), name: "Ali Hassan", subtitle: "Product Manager", avatarEmoji: "😀"),
            messages: [
                Message(id: UUID(), text: "Can you review the Q1 roadmap?", isIncoming: true, date: Date().addingTimeInterval(-7200)),
                Message(id: UUID(), text: "Yes—will send comments today.", isIncoming: false, date: Date().addingTimeInterval(-7100))
            ]
        ),
        Conversation(
            id: UUID(),
            user: User(id: UUID(), name: "Ghassan AlShajjar", subtitle: "UI Designer", avatarEmoji: "👨"),
            messages: [
                Message(id: UUID(), text: "I uploaded the new screens to Figma.", isIncoming: true, date: Date().addingTimeInterval(-5400)),
                Message(id: UUID(), text: "Awesome, I’ll review and leave feedback.", isIncoming: false, date: Date().addingTimeInterval(-5300)),
                Message(id: UUID(), text: "Thank You", isIncoming: true, date: Date().addingTimeInterval(-5200))
            ]
        ),
        Conversation(
            id: UUID(),
            user: User(id: UUID(), name: "Mohammed Ali", subtitle: "iOS Developer", avatarEmoji: "📱"),
            messages: [
                Message(id: UUID(), text: "The TestFlight build crashes when opening settings.", isIncoming: true, date: Date().addingTimeInterval(-9000)),
                Message(id: UUID(), text: "I’ll check. Do you have logs or a video?", isIncoming: false, date: Date().addingTimeInterval(-8950)),
                Message(id: UUID(), text: "I Sent You sysdiagnose and a screen recording.", isIncoming: true, date: Date().addingTimeInterval(-8900))
            ]
        )
    ]
}
=======
//  Created by BP-36-212-05 on 15/12/2025.
//
import Foundation

struct Conversation {
    let id: String
    let user: User
    let lastMessage: String
    let lastUpdated: Date
}

>>>>>>> 5fc0ec21c6f220f016f76b852eb752b75f53b331
