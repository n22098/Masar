//
//  PersonalInfoViewController.swift
//  Masar
//
//  Created by BP-36-212-05 on 13/12/2025.
//

import UIKit

final class PersonalInfoViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarLabel = UILabel()

    private let fullNameField = UITextField()
    private let phoneField = UITextField()
    private let emailField = UITextField()
    private let genderControl = UISegmentedControl(items: ["Male", "Female"])
    private let cprField = UITextField()
    private let usernameField = UITextField()
    private let passwordField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Personal Information"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(didTapSave)
        )

        setupLayout()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        avatarLabel.text = "👤"
        avatarLabel.font = UIFont.systemFont(ofSize: 64)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarLabel)

        let stack = UIStackView(arrangedSubviews: [
            labeled("Full Name", fullNameField),
            labeled("Phone Number", phoneField),
            labeled("Email", emailField),
            labeled("Gender", genderControl),
            labeled("CPR Number", cprField),
            labeled("Username", usernameField),
            labeled("Password", passwordField)
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            avatarLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            avatarLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            stack.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        passwordField.isSecureTextEntry = true
    }

    private func labeled(_ title: String, _ field: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel

        if let tf = field as? UITextField {
            tf.borderStyle = .roundedRect
        }

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    @objc private func didTapSave() {
        UserService.shared.updateProfile(
            name: fullNameField.text ?? "",
            username: usernameField.text ?? "",
            avatarEmoji: "👤"
        )

        navigationController?.popViewController(animated: true)
    }



    private func showCancelled() {
        let alert = UIAlertController(
            title: "Cancelled",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSaved() {
        let alert = UIAlertController(
            title: "Your changes were saved",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
