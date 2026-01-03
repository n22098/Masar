import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

// MARK: - Profile View Controller
class ProfileTableViewController: UITableViewController {

    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // ⚠️⚠️ إعدادات Cloudinary (تم التعديل بناءً على بياناتك) ⚠️⚠️
    let cloudinaryCloudName = "dsjx9ehz2"
    let cloudinaryUploadPreset = "ml_default"

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

    var currentProfileImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadAndApplyDarkMode()
        
        // جلب الصورة المحفوظة
        loadProfileImageFromFirebase()
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
    
    func loadAndApplyDarkMode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyDarkModeToAllWindows(isDarkMode)
    }
    
    // MARK: - Load Image Function
    func loadProfileImageFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }
            
            if let imageUrlString = data["profileImageURL"] as? String, !imageUrlString.isEmpty {
                print("🔄 Found Cloudinary URL: \(imageUrlString)")
                
                if let url = URL(string: imageUrlString) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.currentProfileImage = image
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return menuItems.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 7 { // Dark Mode
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.configure(title: menuItems[indexPath.row], icon: menuIcons[indexPath.row], color: brandColor)
            cell.switchToggled = { [weak self] isOn in self?.darkModeToggled(isOn: isOn) }
            cell.backgroundColor = .secondarySystemGroupedBackground
            return cell
        }
        
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
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.isUserInteractionEnabled = true
        
        let iconImageView = UIImageView()
        if let savedImage = currentProfileImage {
            iconImageView.image = savedImage
            iconImageView.contentMode = .scaleAspectFill
        } else {
            iconImageView.image = UIImage(systemName: "person.fill")
            iconImageView.contentMode = .scaleAspectFit
        }
        
        iconImageView.tintColor = brandColor
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tag = 100
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        iconContainer.addGestureRecognizer(tapGesture)
        
        headerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            iconImageView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor)
        ])
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 120 }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 55 }
    
    // MARK: - Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0: navigateToPersonalInfo()
        case 1: showScrollableAlert(title: "Privacy Policy", message: getPrivacyPolicyText())
        case 2: showScrollableAlert(title: "About Masar", message: getAboutText())
        case 3:
            if let userRole = UserManager.shared.currentUser?.role, userRole == "admin" { showAlert("Admins cannot report issues.") }
            else { showReportSheet() }
        case 4: navigateToResetPassword()
        case 5: showDeleteAccountAlert()
        case 6: showLogOutAlert()
        case 8: showLanguageOptions()
        default: break
        }
    }
    
    func showReportSheet() {
        let reportSheet = ReportSheetViewController()
        if let sheet = reportSheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        present(reportSheet, animated: true)
    }

    func navigateToPersonalInfo() { performSegue(withIdentifier: "goToPersonalInfo", sender: nil) }
    func navigateToResetPassword() { performSegue(withIdentifier: "goToResetPassword", sender: nil) }

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
    
    func darkModeToggled(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: "isDarkMode")
        UserDefaults.standard.synchronize()
        applyDarkModeToAllWindows(isOn)
        tableView.reloadData()
    }
    
    func applyDarkModeToAllWindows(_ isDark: Bool) {
        let style: UIUserInterfaceStyle = isDark ? .dark : .light
        UIApplication.shared.connectedScenes.forEach { scene in
            if let windowScene = scene as? UIWindowScene {
                windowScene.windows.forEach { window in
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.overrideUserInterfaceStyle = style
                    })
                }
            }
        }
        if let window = UIApplication.shared.windows.first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = style
            })
        }
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
    
    func getAboutText() -> String { return "About Masar text..." }
    func getPrivacyPolicyText() -> String { return "Privacy Policy text..." }
}

// MARK: - ☁️ Cloudinary Upload Extension
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
                self.currentProfileImage = image
                self.tableView.reloadData()
                
                let alert = UIAlertController(title: "Uploading...", message: "Please wait while we upload to Cloudinary.", preferredStyle: .alert)
                self.present(alert, animated: true)
                
                // 🚀 استدعاء دالة الرفع لـ Cloudinary
                self.uploadToCloudinary(image: image, loadingAlert: alert)
            }
        }
    }
    
    // دالة الرفع باستخدام Cloudinary API
    func uploadToCloudinary(image: UIImage, loadingAlert: UIAlertController) {
        // 1. تأكد من وجود اسم السحابة والبريست
        guard cloudinaryCloudName != "YOUR_CLOUD_NAME", cloudinaryUploadPreset != "YOUR_UPLOAD_PRESET" else {
            DispatchQueue.main.async {
                loadingAlert.message = "Error: Please set Cloudinary Name & Preset in Code."
                loadingAlert.addAction(UIAlertAction(title: "OK", style: .default))
            }
            return
        }

        // 2. تجهيز الرابط
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudinaryCloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 3. تجهيز بيانات الصورة (Multipart Form Data)
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        var body = Data()
        
        // إضافة upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(cloudinaryUploadPreset)\r\n".data(using: .utf8)!)
        
        // إضافة الصورة
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // 4. الإرسال
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    loadingAlert.message = "Upload Failed: \(error.localizedDescription)"
                    loadingAlert.addAction(UIAlertAction(title: "OK", style: .default))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                // 5. قراءة الرد (JSON) لاستخراج الرابط
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let secureUrl = json["secure_url"] as? String {
                    
                    print("✅ Cloudinary Upload Success: \(secureUrl)")
                    
                    // 6. الحفظ في فايربيس
                    self.saveImageURLToFirestore(url: secureUrl, loadingAlert: loadingAlert)
                    
                } else {
                    print("❌ Cloudinary Response Error: \(String(data: data, encoding: .utf8) ?? "")")
                    DispatchQueue.main.async {
                        loadingAlert.message = "Upload Failed: Check Cloud Name/Preset."
                        loadingAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    }
                }
            } catch {
                print("❌ JSON Parsing Error: \(error)")
            }
        }.resume()
    }
    
    func saveImageURLToFirestore(url: String, loadingAlert: UIAlertController) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).setData([
            "profileImageURL": url
        ], merge: true) { error in
            
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        self.showAlert("Failed to save URL: \(error.localizedDescription)")
                    } else {
                        self.showAlert("✅ Avatar updated successfully!")
                    }
                }
            }
        }
    }
}

// الكلاسات المساعدة (لا تغيير عليها)
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

class ReportSheetViewController: UIViewController, UITextViewDelegate {
    private let titleLabel = UILabel()
    private let subjectField = UITextField()
    private let descriptionTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    func setupUI() {
        titleLabel.text = "Report an Issue"; titleLabel.font = .boldSystemFont(ofSize: 22); titleLabel.textAlignment = .center
        subjectField.placeholder = "Subject"; subjectField.borderStyle = .roundedRect; subjectField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        descriptionTextView.text = "Describe your issue..."; descriptionTextView.textColor = .lightGray; descriptionTextView.layer.borderWidth = 1; descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor; descriptionTextView.layer.cornerRadius = 8; descriptionTextView.delegate = self
        submitButton.setTitle("Submit", for: .normal); submitButton.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0); submitButton.setTitleColor(.white, for: .normal); submitButton.layer.cornerRadius = 10; submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true; submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subjectField, descriptionTextView, submitButton])
        stack.axis = .vertical; stack.spacing = 20; stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack); view.addSubview(activityIndicator); activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 150),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func submitTapped() {
        guard let sub = subjectField.text, !sub.isEmpty else { return }
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray { textView.text = ""; textView.textColor = .label }
    }
}
