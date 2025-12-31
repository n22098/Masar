//
//  SimpleChatViewController.swift
//  Masar
//
//  Created for Messages functionality
//

import UIKit

class SimpleChatViewController: UIViewController {
    var conversationId: String?
    var otherUserId: String?
    var otherUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Chat with \(otherUserName ?? "User")"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        print("💬 [SimpleChat] Opened chat: \(conversationId ?? "N/A")")
    }
}
