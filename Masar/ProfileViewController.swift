//
//  ProfileViewController.swift
//  Masar
//
//  Created by BP-36-212-05 on 15/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - UI

    private let headerView = UIView()
    private let titleLabel = UILabel()

    private let profileContainer = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: - Data
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupProfileSection()
        setupTableView()
        loadUser()
    }

    // MARK: - Header
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1)
        view.addSubview(headerView)

        titleLabel.text = "Account"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }

    // MARK: - Profile Section
    private func setupProfileSection() {
        profileContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileContainer)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 45
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .secondarySystemBackground
        profileImageView.isUserInteractionEnabled = true

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        profileImageView.addGestureRecognizer(imageTap)

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.textColor = .secondaryLabel
        usernameLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(editUsername))
        usernameLabel.addGestureRecognizer(tap)

        [profileImageView, nameLabel, usernameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            profileContainer.addSubview($0)
        }

        NSLayoutConstraint.activate([
            profileContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            profileContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            profileImageView.topAnchor.constraint(equalTo: profileContainer.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.heightAnchor.constraint(equalToConstant: 90),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.centerXAnchor.constraint(equalTo: profileContainer.centerXAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor)
        ])
    }

    // MARK: - Table
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(AccountOptionCell.self, forCellReuseIdentifier: AccountOptionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: profileContainer.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data
    private func loadUser() {
        
        UserService.shared.fetchCurrentUser { [weak self] user in
            guard let self = self, let user = user else { return }
            print("Loaded username:", user.username)

            DispatchQueue.main.async {
                self.nameLabel.text = user.name
                self.usernameLabel.text = "@\(user.username)"

                if let urlString = user.profileImageUrl,
                   let url = URL(string: urlString) {

                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data)

                        }
                    }.resume()
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.circle")
                }
            }
        }
    }



    // MARK: - Actions
    @objc private func changeProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    @objc private func editUsername() {
        let alert = UIAlertController(
            title: "Change Username",
            message: "Enter a new username",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Username"
            textField.autocapitalizationType = .none
            textField.text = self.usernameLabel.text?.replacingOccurrences(of: "@", with: "")
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let newUsername = alert.textFields?.first?.text,
                  !newUsername.isEmpty else { return }

            self.updateUsername(newUsername)
        })

        present(alert, animated: true)
    }

    private func updateUsername(_ newUsername: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .updateData([
                "username": newUsername
            ]) { error in
                if let error = error {
                    print("Failed to update username:", error)
                    return
                }

                DispatchQueue.main.async {
                    self.usernameLabel.text = "@\(newUsername)"
                }
            }
    }


    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Logout?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive))
        present(alert, animated: true)
    }
}

// MARK: - Image Picker
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        // Show immediately
        profileImageView.image = image

        // Upload to Cloudinary
        ChatService.shared.uploadImageToCloudinary(image: image) { imageUrl in
            guard let imageUrl = imageUrl else { return }

            // Save URL in Firestore
            Firestore.firestore()
                .collection("users")
                .document(Auth.auth().currentUser!.uid)
                .updateData([
                    "profileImageUrl": imageUrl
                ])
        }
    }

}

// MARK: - Table Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AccountOptionCell.reuseIdentifier,
            for: indexPath
        ) as! AccountOptionCell

        cell.configure(with: sections[indexPath.section][indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            navigationController?.pushViewController(PersonalInfoViewController(), animated: true)
        } else if indexPath.section == 0 && indexPath.row == 2 {
            navigationController?.pushViewController(AboutViewController(), animated: true)
        } else if indexPath.section == 1 && indexPath.row == 0 {
            showLogoutAlert()
        }
    }
}
