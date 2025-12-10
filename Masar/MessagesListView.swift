//
//  MessagesListView.swift
//  Masar
//
//  Created by BP-36-201-07 on 10/12/2025.
//

import SwiftUI

struct MessagesListView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ChatView()) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading) {
                            Text("Sayed Husain")
                                .font(.headline)
                            Text("Software Engineer")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                Spacer()
            }
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    MessagesListView()
}



