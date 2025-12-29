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
        // لا نحتاج لإعدادات الخلايا هنا لأنها موجودة في الستوري بورد
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
    
    // ---------------------------------------------------------
    // ❌ تم حذف دوال DataSource (numberOfSections, numberOfRows, cellForRow)
    // لكي يظهر تصميم الستوري بورد (Static Cells)
    // ---------------------------------------------------------
    
    // MARK: - Header (الأيقونة العلوية)
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
    
    // MARK: - TableView Delegate (التعامل مع الضغطات)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // تأكد أن ترتيب الـ Cases يطابق ترتيب الخلايا في الستوري بورد
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
            break // Dark Mode toggle handled by switch inside cell
        case 6:
            showLanguageOptions()
        case 7:
            showDeleteAccountAlert()
        case 8:
            showLogOutAlert()
        default:
            break
        }
        
        // إلغاء التحديد لجمالية الأنيميشن
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
    
    // MARK: - Dark Mode & Language Actions
    // ملاحظة: لكي يعمل هذا، يجب ربط الـ Switch في الستوري بورد بهذا الآكشن
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
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
        
        let alert = UIAlertController(
            title: "Language Changed",
            message: "The app language has been changed to \(language). Please restart the app for changes to take full effect.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Scrollable Alert
    func showScrollableAlert(title: String, message: String) {
        let contentVC = UIViewController()
        contentVC.modalPresentationStyle = .pageSheet
        
        if let sheet = contentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        contentVC.view.backgroundColor = .white // أو استخدام لون النظام للداكن والفاتح
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(titleLabel)
        
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
        // تأكد أن "Main" هو اسم ملف الستوري بورد الذي يحتوي على صفحة الدخول
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // تأكد أن "SignInViewController" هو الـ Storyboard ID لصفحة الدخول
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            window.rootViewController = signInVC
            
            // أنيميشن بسيط للانتقال
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
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
