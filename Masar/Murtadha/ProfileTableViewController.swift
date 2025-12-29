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
        return 9 // Personal Info, Privacy, About, Report, Reset Password, Dark Mode, Language, Delete Account, Log Out
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
        
        cardView.addSubview(titleLabel)
        
        // Set titles and accessories based on row
        switch indexPath.row {
        case 0:
            titleLabel.text = "Personal Information"
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 1:
            titleLabel.text = "Privacy and Policy"
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 2:
            titleLabel.text = "About"
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 3:
            titleLabel.text = "Report an Issue"
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 4:
            titleLabel.text = "Reset Password"
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 5:
            titleLabel.text = "Dark Mode"
            let toggleSwitch = UISwitch()
            toggleSwitch.onTintColor = brandColor
            toggleSwitch.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
            toggleSwitch.addTarget(self, action: #selector(darkModeToggled(_:)), for: .valueChanged)
            toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(toggleSwitch)
            
            NSLayoutConstraint.activate([
                toggleSwitch.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
                toggleSwitch.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
            ])
            
        case 6:
            titleLabel.text = "Language"
            let languageLabel = UILabel()
            let currentLang = UserDefaults.standard.string(forKey: "appLanguage") ?? "English"
            languageLabel.text = currentLang
            languageLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            languageLabel.textColor = brandColor
            languageLabel.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(languageLabel)
            
            let arrowImageView = createArrowImageView()
            cardView.addSubview(arrowImageView)
            
            NSLayoutConstraint.activate([
                languageLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -10),
                languageLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
                
                arrowImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
                arrowImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
                arrowImageView.widthAnchor.constraint(equalToConstant: 12),
                arrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
        case 7:
            titleLabel.text = "Delete Account"
            titleLabel.textColor = .red
            let arrowImageView = createArrowImageView()
            arrowImageView.tintColor = .red
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        case 8:
            titleLabel.text = "Log Out"
            titleLabel.textColor = .red
            let arrowImageView = createArrowImageView()
            arrowImageView.tintColor = .red
            cardView.addSubview(arrowImageView)
            setupArrowConstraints(arrowImageView, in: cardView)
            
        default:
            break
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
        
        return cell
    }
    
    // Helper methods for creating UI elements
    func createArrowImageView() -> UIImageView {
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .lightGray
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        return arrowImageView
    }
    
    func setupArrowConstraints(_ arrowImageView: UIImageView, in cardView: UIView) {
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            arrowImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
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
            break // Dark Mode toggle handled by switch
        case 6:
            showLanguageOptions()
        case 7:
            showDeleteAccountAlert()
        case 8:
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
        showScrollableAlert(
            title: "Privacy and Policy",
            message: getPrivacyPolicyText()
        )
    }
    
    func showAbout() {
        showScrollableAlert(
            title: "About Masar",
            message: getAboutText()
        )
    }
    
    func showReportIssue() {
        let alert = UIAlertController(
            title: "Report an Issue",
            message: "If you have any questions or suggestions, feel free to contact us at:\n\nEmail: Masar@gmail.com\nPhone: +973-39871234",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Dark Mode & Language Actions
    @objc func darkModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        
        if sender.isOn {
            // Enable dark mode
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        } else {
            // Disable dark mode
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            }
        }
    }
    
    func showLanguageOptions() {
        let alert = UIAlertController(
            title: "Choose Language",
            message: "Select your preferred language",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "English", style: .default) { [weak self] _ in
            self?.changeLanguage(to: "English")
        })
        
        alert.addAction(UIAlertAction(title: "العربية (Arabic)", style: .default) { [weak self] _ in
            self?.changeLanguage(to: "Arabic")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func changeLanguage(to language: String) {
        UserDefaults.standard.set(language, forKey: "appLanguage")
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Language Changed",
            message: "The app language has been changed to \(language). Please restart the app for changes to take full effect.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Reload the table to update the language label
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Scrollable Alert
    func showScrollableAlert(title: String, message: String) {
        // Create a custom view controller for displaying long text
        let contentVC = UIViewController()
        contentVC.modalPresentationStyle = .pageSheet
        
        if let sheet = contentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        contentVC.view.backgroundColor = .white
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(titleLabel)
        
        // Text view for scrollable content
        let textView = UITextView()
        textView.text = message
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .darkGray
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(textView)
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.backgroundColor = brandColor
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(dismissScrollableAlert), for: .touchUpInside)
        contentVC.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            textView.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            
            closeButton.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: contentVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        present(contentVC, animated: true)
    }
    
    @objc func dismissScrollableAlert() {
        dismiss(animated: true)
    }
    
    // MARK: - Content Text
    func getAboutText() -> String {
        return """
        Welcome to Masar!
        
        At Masar, we believe in the power of community — where people can share their skills, offer their services, and connect with others who need them. Our mobile application is designed to make it easier for individuals in the Kingdom of Bahrain to find, offer, and exchange local skills and services in a convenient and trustworthy way.
        
        Our Mission
        Empower individuals and small service providers by giving them a platform to showcase their talents and connect with people who need their expertise. Whether you're a handyman, tutor, designer, or mechanic, Masar helps you reach those who need your help quickly and easily.
        
        What We Offer
        
        • Skill & Service Search: Browse and search for local professionals or individuals offering the services you need — from home repairs to photography, tutoring, and more.
        
        • Service Posting: If you have a skill or service to offer, create a profile and post your services within minutes. Let others in your community find and hire you with ease.
        
        • Secure Communication: Contact service providers or clients directly through our secure in-app messaging feature — fast, safe, and simple.
        
        • Ratings & Reviews: We value trust and transparency. That's why users can rate and review each other's services to help maintain quality and reliability across the community.
        
        • Location-Based Results: Find nearby service providers instantly using our location-based search — connecting you with people in your area who can help right away.
        
        • User-Friendly Interface: Our app is built with simplicity and usability in mind. Whether you're offering a service or searching for one, Masar makes it straightforward and intuitive for everyone.
        
        Our Vision
        We aim to create a connected community in Bahrain where skills, services, and opportunities can be exchanged with ease. Masar aspires to become the go-to local platform for people to discover, collaborate, and grow together.
        
        Join Us
        Download Masar today and become part of a community built on trust, collaboration, and local connection. Whether you're looking for help or ready to offer your expertise, Masar is here to make it happen.
        
        East or West, Masar is the Best!
        
        Version 1.0
        """
    }
    
    func getPrivacyPolicyText() -> String {
        return """
        Masar operates the Local Skills & Services Exchange application. This page is used to inform Masar users regarding our policies with the collection, use, and disclosure of personal information if anyone decides to use our Service.
        
        By using the Masar app, you agree to the collection and use of information in accordance with this policy. The personal information that we collect is used for providing, improving, and personalizing our Service. We will not use or share your information with anyone except as described in this Privacy Policy.
        
        Information Collection and Use
        To enhance your experience while using our Service, we may require you to provide certain personally identifiable information, including but not limited to your full name, phone number, location, and service preferences. The information we collect will be used to:
        
        • Help match users seeking skills or services with those providing them.
        • Facilitate communication between users.
        • Improve and personalize your experience in the app.
        
        Service Providers
        We may employ third-party companies and individuals for the following purposes:
        
        • To assist in improving our Service
        • To provide the Service on our behalf
        • To analyze app usage and performance
        
        These third parties may have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.
        
        Security
        We value your trust in providing your personal information and strive to use commercially acceptable means to protect it. However, please remember that no method of transmission over the internet, or method of electronic storage, is 100% secure.
        
        Links to Other Sites
        Our Service may contain links to third-party sites. If you click on a third-party link, you will be directed to that site. We are not responsible for the content or privacy policies of these websites and strongly advise you to review their policies.
        
        Children's Privacy
        Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.
        
        Changes to This Privacy Policy
        We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes. Changes are effective immediately after being posted on this page.
        
        Contact Us
        If you have any questions or suggestions about our Privacy Policy, feel free to contact us at:
        
        Email: Masar@gmail.com
        Phone: +973-39871234
        """
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
