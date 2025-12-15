//
//  ProfileViewController.swift
//  Masar
//
//  Created by BP-36-212-05 on 15/12/2025.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let sections: [[AccountOption]] = [
        [
            AccountOption(title: "Personal information", type: .normal),
            AccountOption(title: "Privacy and policy", type: .normal),
            AccountOption(title: "About", type: .normal)
        ],
        [
            AccountOption(title: "Logout", type: .destructive),
            AccountOption(title: "Delete account", type: .destructive)
        ]
    ]
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://www.freeprivacypolicy.com/blog/privacy-policy-url/") else { return }
        UIApplication.shared.open(url)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupTableView()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        view.addSubview(headerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Account"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)

        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.text = "👤"
        avatarLabel.font = UIFont.systemFont(ofSize: 48)
        view.addSubview(avatarLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Ali Husain Ali"
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(nameLabel)

        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "@Ali_874"
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        usernameLabel.textColor = .secondaryLabel
        view.addSubview(usernameLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            avatarLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            avatarLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AccountOptionCell.self, forCellReuseIdentifier: AccountOptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.allowsSelection = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .default))
        present(alert, animated: true)
    }

    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "Delete account?",
            message: "Are you sure you want to delete your account?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.showDeletedConfirmation()
        })
        present(alert, animated: true)
    }

    private func showDeletedConfirmation() {
        let alert = UIAlertController(
            title: "Your account has been deleted",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AccountOptionCell.reuseIdentifier,
            for: indexPath
        ) as! AccountOptionCell
        cell.configure(with: sections[indexPath.section][indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.row == 1 {
            openPrivacyPolicy()
        } else if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(
                PersonalInfoViewController(),
                animated: true
            )
        } else if indexPath.section == 0 && indexPath.row == 2 {
            navigationController?.pushViewController(
                AboutViewController(),
                animated: true
            )
        } else if indexPath.section == 1 && indexPath.row == 0 {
            showLogoutAlert()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            showDeleteAccountAlert()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }


}
