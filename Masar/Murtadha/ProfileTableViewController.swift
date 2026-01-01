import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

// MARK: - Profile View Controller
class ProfileTableViewController: UITableViewController {

    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Dynamic Background Color
    let dynamicBg = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .systemBackground : UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }
    
    // Menu Items
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadDarkModePreference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        tableView.reloadData()
    }
    
    // MARK: - Setup UI
    func setupTableView() {
        tableView.backgroundColor = dynamicBg
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.separatorStyle = .singleLine
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
    
    func loadDarkModePreference() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyDarkMode(isDarkMode)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return menuItems.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dark Mode Cell (Index 7)
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.configure(title: menuItems[indexPath.row], icon: menuIcons[indexPath.row], color: brandColor)
            cell.switchToggled = { [weak self] isOn in
                self?.darkModeToggled(isOn: isOn)
            }
            cell.backgroundColor = .secondarySystemGroupedBackground
            return cell
        }
       
        // Standard Cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = menuItems[indexPath.row]
        content.image = UIImage(systemName: menuIcons[indexPath.row])
        content.imageProperties.tintColor = brandColor
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemGroupedBackground
        return cell
    }
    
    // MARK: - Header View
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
       
        let iconContainer = UIView()
        iconContainer.backgroundColor = brandColor.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.isUserInteractionEnabled = true // FIXED: Enable interaction
       
        let iconImageView = UIImageView(image: UIImage(systemName: "person.fill"))
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tag = 100 // Tag for later reference
       
        // FIXED: Add tap gesture for avatar upload
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        iconContainer.addGestureRecognizer(tapGesture)
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 120 }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 55 }
    
    // MARK: - Did Select Row (Actions)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        switch indexPath.row {
        case 0: navigateToPersonalInfo()
        case 1: showScrollableAlert(title: "Privacy Policy", message: getPrivacyPolicyText())
        case 2: showScrollableAlert(title: "About Masar", message: getAboutText())
        case 3:
            // FIXED: Check if user is admin - admins cannot report issues
            if let userRole = UserManager.shared.currentUser?.role, userRole == "admin" {
                showAlert("Admins cannot report issues.")
            } else {
                showReportSheet()
            }
        case 4: navigateToResetPassword()
        case 5: showDeleteAccountAlert()
        case 6: showLogOutAlert()
        case 7: break // Dark Mode Switch
        case 8: showLanguageOptions()
        default: break
        }
    }
    
    // MARK: - Report Functionality
    func showReportSheet() {
        let reportSheet = ReportSheetViewController()
        if let sheet = reportSheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(reportSheet, animated: true)
    }

    // MARK: - Navigation & Segues
    func navigateToPersonalInfo() { performSegue(withIdentifier: "goToPersonalInfo", sender: nil) }
    func navigateToResetPassword() { performSegue(withIdentifier: "goToResetPassword", sender: nil) }

    // MARK: - Account Actions
    func showLogOutAlert() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            try? Auth.auth().signOut()
            self?.goToSignIn()
        })
        present(alert, animated: true)
    }
    
    func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "Delete Account", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Auth.auth().currentUser?.delete { error in
                if let error = error { self?.showAlert("Error: \(error.localizedDescription)") }
                else { self?.goToSignIn() }
            }
        })
        present(alert, animated: true)
    }
    
    func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = signInVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    // MARK: - Dark Mode & Language
    func darkModeToggled(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: "isDarkMode")
        applyDarkMode(isOn)
    }
    
    func applyDarkMode(_ isOn: Bool) {
        guard let window = UIApplication.shared.windows.first else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = isOn ? .dark : .light
        }
        tableView.reloadData()
    }
    
    func showLanguageOptions() {
        let alert = UIAlertController(title: "Language", message: "Select Language", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "English", style: .default) { _ in self.changeLanguage(to: "en") })
        alert.addAction(UIAlertAction(title: "العربية", style: .default) { _ in self.changeLanguage(to: "ar") })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func changeLanguage(to code: String) {
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        let alert = UIAlertController(title: "Restart Required", message: "Please restart the app to apply changes.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Helpers
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showScrollableAlert(title: String, message: String) {
        let contentVC = UIViewController()
        contentVC.view.backgroundColor = .systemBackground
       
        let textView = UITextView()
        textView.text = message
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentVC.view.addSubview(textView)
       
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentVC.view.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor, constant: -20),
            textView.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor, constant: -20)
        ])
       
        if let sheet = contentVC.sheetPresentationController { sheet.detents = [.medium(), .large()] }
        present(contentVC, animated: true)
    }
    
    // MARK: - 🔥 UPDATED TEXT CONTENT 🔥
    
    func getAboutText() -> String {
        return """
        Welcome to Masar!

        At Masar, we believe in the power of community — where people can share their skills, offer their services, and connect with others who need them. Our mobile application is designed to make it easier for individuals in the Kingdom of Bahrain to find, offer, and exchange local skills and services in a convenient and trustworthy way.

        Our Mission
        Empower individuals and small service providers by giving them a platform to showcase their talents and connect with people who need their expertise. Whether you’re a handyman, tutor, designer, or mechanic , Masar helps you reach those who need your help quickly and easily.

        What We Offer
        Skill & Service Search:
        Browse and search for local professionals or individuals offering the services you need — from home repairs to photography, tutoring, and more.

        Service Posting:
        If you have a skill or service to offer, create a profile and post your services within minutes. Let others in your community find and hire you with ease.

        Secure Communication:
        Contact service providers or clients directly through our secure in-app messaging feature — fast, safe, and simple.

        Ratings & Reviews:
        We value trust and transparency. That’s why users can rate and review each other’s services to help maintain quality and reliability across the community.

        Location-Based Results:
        Find nearby service providers instantly using our location-based search — connecting you with people in your area who can help right away.

        User-Friendly Interface:
        Our app is built with simplicity and usability in mind. Whether you’re offering a service or searching for one, Masar makes it straightforward and intuitive for everyone.

        Our Vision
        We aim to create a connected community in Bahrain where skills, services, and opportunities can be exchanged with ease. Masar aspires to become the go-to local platform for people to discover, collaborate, and grow together.

        Join Us
        Download Masar today and become part of a community built on trust, collaboration, and local connection. Whether you’re looking for help or ready to offer your expertise

        Masar is here to make it happen.
        East or west Masar is the Best
        """
    }

    func getPrivacyPolicyText() -> String {
        return """
        Masar operates the Local Skills & Services Exchange application.
        This page is used to inform Masar users regarding our policies with the collection, use, and disclosure of personal information if anyone decides to use our Service.
        
        By using the Masar app, you agree to the collection and use of information in accordance with this policy. The personal information that we collect is used for providing, improving, and personalizing our Service. We will not use or share your information with anyone except as described in this Privacy Policy.
        
        Information Collection and Use
        To enhance your experience while using our Service, we may require you to provide certain personally identifiable information, including but not limited to your full name, phone number, location, and service preferences. The information we collect will be used to:

        Help match users seeking skills or services with those providing them.
        Facilitate communication between users.
        Improve and personalize your experience in the app.

        Service Providers
        We may employ third-party companies and individuals for the following purposes:
        To assist in improving our Service;
        To provide the Service on our behalf;
        To analyze app usage and performance.

        These third parties may have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.

        Security
        We value your trust in providing your personal information and strive to use commercially acceptable means to protect it. However, please remember that no method of transmission over the internet, or method of electronic storage, is 100% secure.

        Links to Other Sites
        Our Service may contain links to third-party sites. If you click on a third-party link, you will be directed to that site. We are not responsible for the content or privacy policies of these websites and strongly advise you to review their policies.

        Children’s Privacy
        Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.

        Changes to This Privacy Policy
        We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes. Changes are effective immediately after being posted on this page.

        Contact Us
        If you have any questions or suggestions about our Privacy Policy
        feel free to contact us at:
        Masar@gmail.com
        +973-39871234
        """
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
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28), iconImageView.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, icon: String, color: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
        switchControl.onTintColor = color
        switchControl.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    @objc private func switchValueChanged() { switchToggled?(switchControl.isOn) }
}


// MARK: - 🔥 REPORT SHEET CONTROLLER 🔥
class ReportSheetViewController: UIViewController, UITextViewDelegate {
    
    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Report an Issue"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subjectField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Subject (e.g., Technical Problem)"
        tf.borderStyle = .none
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()
    
    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 10
        tv.text = "Describe your issue..." // Placeholder
        tv.textColor = .lightGray
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit Report", for: .normal)
        btn.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.cornerRadius = 12
        btn.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return btn
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        descriptionTextView.delegate = self
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
       
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subjectField, descriptionTextView, submitButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(stack)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150),
            activityIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor)
        ])
    }
    
    // 🔥 Firebase Logic
    @objc private func submitTapped() {
        guard let subject = subjectField.text, !subject.isEmpty,
              descriptionTextView.text != "Describe your issue...", !descriptionTextView.text.isEmpty else {
            let alert = UIAlertController(title: "Missing Info", message: "Please fill all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
       
        startLoading(true)
       
        guard let user = Auth.auth().currentUser else {
            startLoading(false)
            return
        }
       
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, _ in
            guard let self = self else { return }
           
            let data = snapshot?.data()
            let reporterName = data?["fullName"] as? String ?? data?["name"] as? String ?? "Unknown User"
           
            let reportData: [String: Any] = [
                "id": UUID().uuidString.prefix(8).uppercased(),
                "reporter": reporterName,
                "email": user.email ?? "",
                "subject": subject,
                "description": self.descriptionTextView.text ?? "",
                "timestamp": FieldValue.serverTimestamp(),
                "status": "Pending"
            ]
           
            db.collection("reports").addDocument(data: reportData) { error in
                self.startLoading(false)
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    let alert = UIAlertController(title: "Sent!", message: "Report submitted successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.dismiss(animated: true) })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func startLoading(_ isLoading: Bool) {
        submitButton.setTitle(isLoading ? "" : "Submit Report", for: .normal)
        submitButton.isEnabled = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    
    // Placeholder Logic
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Describe your issue..."
            textView.textColor = .lightGray
        }
    }
}

// MARK: - FIXED: Avatar Upload Extension
extension ProfileTableViewController: PHPickerViewControllerDelegate {
    
    @objc func avatarTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            guard let self = self, let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                // Update the header view's image
                if let headerView = self.tableView.headerView(forSection: 0),
                   let iconContainer = headerView.subviews.first,
                   let iconImageView = iconContainer.viewWithTag(100) as? UIImageView {
                    iconImageView.image = image
                    iconImageView.contentMode = .scaleAspectFill
                    iconImageView.clipsToBounds = true
                    iconContainer.layer.cornerRadius = 40
                    iconContainer.clipsToBounds = true
                }
                
                // TODO: Upload to Firebase Storage if needed
                // For now, just update the UI
                self.showAlert("Avatar updated successfully!")
            }
        }
    }
}
