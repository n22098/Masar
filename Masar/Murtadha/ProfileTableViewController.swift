import UIKit
import FirebaseAuth

class ProfileTableViewController: UITableViewController {

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // 🔥 FIXED: Now this color automatically changes between Light and Dark mode
    let lightBg = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .systemBackground : UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }
    
    // قائمة العناصر بالترتيب الصحيح (مع الترجمة)
    var menuItems: [String] {
        return [
            NSLocalizedString("Personal Information", comment: ""),
            NSLocalizedString("Privacy and Policy", comment: ""),
            NSLocalizedString("About", comment: ""),
            NSLocalizedString("Report an Issue", comment: ""),
            NSLocalizedString("Reset Password", comment: ""),
            NSLocalizedString("Delete Account", comment: ""),
            NSLocalizedString("Log Out", comment: ""),
            NSLocalizedString("Dark Mode", comment: ""),
            NSLocalizedString("Language", comment: "")
        ]
    }
    
    let menuIcons = [
        "person.circle",
        "lock.shield",
        "info.circle",
        "exclamationmark.bubble",
        "key",
        "trash",
        "arrow.right.square",
        "moon.fill",
        "globe"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadDarkModePreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        tableView.reloadData() // ريلود للغة
    }
    
    // تحميل تفضيلات Dark Mode عند فتح التطبيق
    func loadDarkModePreference() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyDarkMode(isDarkMode)
    }

    func setupTableView() {
        // This will now respect the dynamic color
        tableView.backgroundColor = lightBg
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
    }

    func setupNavigationBar() {
        title = NSLocalizedString("Profile", comment: "")
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
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dark Mode cell with switch
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.configure(title: menuItems[indexPath.row], icon: menuIcons[indexPath.row], color: brandColor)
            cell.switchToggled = { [weak self] isOn in
                self?.darkModeToggled(isOn: isOn)
            }
            // Ensure cell background adapts
            cell.backgroundColor = .secondarySystemGroupedBackground
            return cell
        }
        
        // Regular menu cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItems[indexPath.row]
        content.image = UIImage(systemName: menuIcons[indexPath.row])
        content.imageProperties.tintColor = brandColor
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        // Use system colors so they turn black in dark mode
        cell.backgroundColor = .secondarySystemGroupedBackground
        
        return cell
    }
    
    // MARK: - Header
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // MARK: - Table View Delegate
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
        case 7:
            break // Dark Mode - handled by switch
        case 8:
            showLanguageOptions()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    // MARK: - Dark Mode
    func darkModeToggled(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: "isDarkMode")
        applyDarkMode(isOn)
    }
    
    func applyDarkMode(_ isOn: Bool) {
        // تطبيق Dark Mode على جميع النوافذ في التطبيق
        // 🔥 Ensure UI updates on Main Thread
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { window in
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.overrideUserInterfaceStyle = isOn ? .dark : .light
                    })
                }
            
            // تحديث الواجهة الحالية
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Language
    func showLanguageOptions() {
        let alert = UIAlertController(
            title: "Choose Language",
            message: "Select your preferred language",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "English", style: .default) { [weak self] _ in
            self?.changeLanguage(to: "en", displayName: "English")
        })
        
        alert.addAction(UIAlertAction(title: "العربية (Arabic)", style: .default) { [weak self] _ in
            self?.changeLanguage(to: "ar", displayName: "Arabic")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func changeLanguage(to languageCode: String, displayName: String) {
        // حفظ اللغة
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.set(languageCode, forKey: "appLanguage")
        UserDefaults.standard.synchronize()
        
        // رسالة تأكيد
        let alert = UIAlertController(
            title: "Language Changed",
            message: "The app language has been changed to \(displayName). The app will restart now.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.restartApp()
        })
        
        present(alert, animated: true)
    }
    
    func restartApp() {
        // إعادة تشغيل التطبيق من البداية
        guard let window = UIApplication.shared.windows.first else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // تحقق إذا المستخدم مسجل دخول
        if Auth.auth().currentUser != nil {
            // المستخدم مسجل دخول، ارجع للستوري بورد المناسب
            if let userType = UserDefaults.standard.string(forKey: "userType") {
                let targetStoryboard = UIStoryboard(name: userType, bundle: nil)
                if let rootVC = targetStoryboard.instantiateInitialViewController() {
                    window.rootViewController = rootVC
                }
            }
        } else {
            // المستخدم مو مسجل دخول، ارجع لصفحة تسجيل الدخول
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            window.rootViewController = signInVC
        }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
    }
    
    // MARK: - Delete Account
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
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { [weak self] error in
            if let error = error {
                self?.showAlert("Failed to delete account: \(error.localizedDescription)")
            } else {
                self?.goToSignIn()
            }
        }
    }
    
    // MARK: - Log Out
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
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            window.rootViewController = signInVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    // MARK: - Scrollable Alert
    func showScrollableAlert(title: String, message: String) {
        let contentVC = UIViewController()
        contentVC.modalPresentationStyle = .pageSheet
        
        if let sheet = contentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        contentVC.view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(titleLabel)
        
        let textView = UITextView()
        textView.text = message
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = .label
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(textView)
        
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
        Empower individuals and small service providers by giving them a platform to showcase their talents and connect with people who need their expertise. Whether you're a handyman, tutor, designer, or mechanic, Masar helps you reach those who need their help quickly and easily.
        
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

// MARK: - Custom Switch Cell
class SwitchCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()
    
    var switchToggled: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        selectionStyle = .none
    }
    
    func configure(title: String, icon: String, color: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
        switchControl.onTintColor = color
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        switchControl.isOn = isDarkMode
    }
    
    @objc private func switchValueChanged() {
        switchToggled?(switchControl.isOn)
    }
}
