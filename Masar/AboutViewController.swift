//
//  AboutViewController.swift
//  Masar
//
//  Created by BP-36-212-05 on 13/12/2025.
//

import UIKit

final class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "About"

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text =
"""
About Masar:

Welcome to Masar!

Masar is a platform that connects individuals who offer skills and services with people who need them.

Our mission is to empower local communities by making it easy to discover, collaborate, and grow together.

Thank you for using Masar.
"""

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
