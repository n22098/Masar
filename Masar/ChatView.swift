//
//  ChatView.swift
//  Masar
//
//  Created by BP-36-201-07 on 10/12/2025.
//

import SwiftUI

struct ChatView: View {
    @State private var newMessage = ""
    @State private var messages = [
        ChatMessage(text: "Hello, I need to create a website for my work", isFromUser: true, time: "2:00pm"),
        ChatMessage(text: "Sure, send me your requirement details...", isFromUser: false, time: "2:03pm"),
        ChatMessage(text: "Okay thanks!", isFromUser: true, time: "2:04pm")
    ]

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { msg in
                        ChatBubble(message: msg)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Type a message…", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("Chat with provider")
    }

    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        messages.append(ChatMessage(text: newMessage, isFromUser: true, time: "Now"))
        newMessage = ""
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
}




