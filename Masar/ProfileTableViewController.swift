import UIKit
import FirebaseAuth

class ProfileTableViewController: UITableViewController {

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    func setupTableView() {
        tableView.backgroundColor = lightBg
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = 60
    }

    func setupNavigationBar() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7 // Personal Info, Privacy, About, Report, Reset Password, Delete Account, Log Out
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ProfileCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cardView)
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .lightGray
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(arrowImageView)
        
        // Set titles based on row
        switch indexPath.row {
        case 0:
            titleLabel.text = "Personal Information"
        case 1:
            titleLabel.text = "Privacy and Policy"
        case 2:
            titleLabel.text = "About"
        case 3:
            titleLabel.text = "Report an Issue"
        case 4:
            titleLabel.text = "Reset Password"
        case 5:
            titleLabel.text = "Delete Account"
            titleLabel.textColor = .red
            arrowImageView.tintColor = .red
        case 6:
            titleLabel.text = "Log Out"
            titleLabel.textColor = .red
            arrowImageView.tintColor = .red
        default:
            break
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            arrowImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = brandColor.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "person.fill")
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigateToPersonalInfo()
        case 1:
            showPrivacyPolicy()
        case 2:
            showAbout()
        case 3:
            showReportIssue()
        case 4:
            navigateToResetPassword()
        case 5:
            showDeleteAccountAlert()
        case 6:
            showLogOutAlert()
        default:
            break
        }
    }
    
    // MARK: - Navigation
    func navigateToPersonalInfo() {
        performSegue(withIdentifier: "goToPersonalInfo", sender: nil)
    }
    
    func navigateToResetPassword() {
        performSegue(withIdentifier: "goToResetPassword", sender: nil)
    }
    
    // MARK: - Actions
    func showPrivacyPolicy() {
        let alert = UIAlertController(
            title: "Privacy and Policy",
            message: "Your privacy matters to us. We protect your personal information and use it only for service delivery.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showAbout() {
        let alert = UIAlertController(
            title: "About Masar",
            message: "Masar is your trusted platform for connecting service seekers with providers.\n\nVersion 1.0",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showReportIssue() {
        let alert = UIAlertController(
            title: "Report an Issue",
            message: "Please contact our support team at support@masar.com or call +973-1234-5678",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    func deleteAccount() {
        // Delete user from Firebase Auth
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { [weak self] error in
            if let error = error {
                self?.showAlert("Failed to delete account: \(error.localizedDescription)")
            } else {
                self?.goToSignIn()
            }
        }
    }
    
    func showLogOutAlert() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Do you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            do {
                try Auth.auth().signOut()
                self?.goToSignIn()
            } catch {
                self?.showAlert("Failed to log out. Please try again.")
            }
        })

        present(alert, animated: true)
    }

    // MARK: - Navigation to Sign In
    func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(
            withIdentifier: "SignInViewController"
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            window.rootViewController = signInVC
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Alert Helper
    func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Profile",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
