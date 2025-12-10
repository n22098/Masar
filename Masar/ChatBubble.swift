//
//  ChatBubble.swift
//  Masar
//
//  Created by BP-36-201-07 on 10/12/2025.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser { Spacer() }

            VStack(alignment: .trailing, spacing: 4) {
                Text(message.text)
                    .padding()
                    .background(
                        message.isFromUser ?
                            Color.green.opacity(0.25) :
                            Color.purple.opacity(0.12)
                    )
                    .cornerRadius(16)

                Text(message.time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if !message.isFromUser { Spacer() }
        }
    }
}

#Preview {
    VStack {
        ChatBubble(message: ChatMessage(text: "Hello", isFromUser: true, time: "2:00pm"))
        ChatBubble(message: ChatMessage(text: "Hi!", isFromUser: false, time: "2:03pm"))
    }
    .padding()
}
