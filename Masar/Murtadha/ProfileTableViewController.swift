import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

// MARK: - Profile View Controller
class ProfileTableViewController: UITableViewController {

    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // ⚠️⚠️ إعدادات Cloudinary ⚠️⚠️
    let cloudinaryCloudName = "dsjx9ehz2"
    let cloudinaryUploadPreset = "ml_default"

    // Dynamic Background Color
    let dynamicBg = UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ? .systemBackground : UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }
    
    // ✅ Check if user is admin from MULTIPLE sources
    private var isAdmin: Bool {
        // Method 1: Check UserDefaults (set during login)
        let roleFromDefaults = UserDefaults.standard.string(forKey: "userRole") ?? ""
        if roleFromDefaults.lowercased() == "admin" {
            print("🔍 Admin detected from UserDefaults")
            return true
        }
        
        // Method 2: Check UserManager (if available)
        if let userRole = UserManager.shared.currentUser?.role, userRole.lowercased() == "admin" {
            print("🔍 Admin detected from UserManager")
            return true
        }
        
        print("🔍 Not an admin - showing full menu")
        return false
    }
    
    // Menu Items - Dynamically filtered based on admin status
    var menuItems: [String] {
        var items = [String]()
        
        // Only show Personal Information for non-admins
        if !isAdmin {
            items.append(NSLocalizedString("Personal Information", comment: ""))
        }
        
        items.append(NSLocalizedString("Privacy and Policy", comment: ""))
        items.append(NSLocalizedString("About", comment: ""))
        
        // ✅ Only show Report an Issue for non-admins
        if !isAdmin {
            items.append(NSLocalizedString("Report an Issue", comment: ""))
        }
        
        // ✅ Only show Reset Password for non-admins
        if !isAdmin {
            items.append(NSLocalizedString("Reset Password", comment: ""))
        }
        
        // ✅ Only show Delete Account for non-admins
        if !isAdmin {
            items.append(NSLocalizedString("Delete Account", comment: ""))
        }
        
        items.append(NSLocalizedString("Log Out", comment: ""))
        items.append(NSLocalizedString("Dark Mode", comment: ""))
        items.append(NSLocalizedString("Language", comment: ""))
        
        return items
    }
    
    var menuIcons: [String] {
        var icons = [String]()
        
        // Only show Personal Information icon for non-admins
        if !isAdmin {
            icons.append("person.circle")
        }
        
        icons.append("lock.shield")
        icons.append("info.circle")
        
        // ✅ Only show Report an Issue icon for non-admins
        if !isAdmin {
            icons.append("exclamationmark.bubble")
        }
        
        // ✅ Only show Reset Password icon for non-admins
        if !isAdmin {
            icons.append("key")
        }
        
        // ✅ Only show Delete Account icon for non-admins
        if !isAdmin {
            icons.append("trash")
        }
        
        icons.append("arrow.right.square")
        icons.append("moon.fill")
        icons.append("globe")
        
        return icons
    }

    var currentProfileImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadAndApplyDarkMode()
        
        // Debug: Print admin status
        print("🔍 DEBUG - Is Admin: \(isAdmin)")
        print("🔍 DEBUG - Menu Items: \(menuItems)")
        
        // جلب الصورة المحفوظة
        loadProfileImageFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        // Debug: Print admin status on each appearance
        print("🔍 DEBUG viewWillAppear - Is Admin: \(isAdmin)")
        
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
        // Check if admin - load from UserDefaults instead
        if isAdmin {
            print("👑 Loading admin profile image from local storage...")
            if let base64String = UserDefaults.standard.string(forKey: "adminProfileImage"),
               let imageData = Data(base64Encoded: base64String),
               let image = UIImage(data: imageData) {
                print("✅ Admin profile image loaded from local storage")
                self.currentProfileImage = image
                self.tableView.reloadData()
            } else {
                print("ℹ️ No admin profile image found in local storage")
            }
            return
        }
        
        // Regular user - load from Firebase
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user ID - cannot load profile image")
            return
        }
        
        print("📥 Loading profile image for user: \(uid)")
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else {
                if let error = error {
                    print("❌ Error loading user data: \(error.localizedDescription)")
                }
                return
            }
            
            if let imageUrlString = data["profileImageURL"] as? String, !imageUrlString.isEmpty {
                print("✅ Found profile image URL: \(imageUrlString)")
                
                if let url = URL(string: imageUrlString) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            print("✅ Profile image downloaded successfully")
                            DispatchQueue.main.async {
                                self.currentProfileImage = image
                                self.tableView.reloadData()
                            }
                        } else {
                            print("❌ Failed to download or convert image")
                        }
                    }
                } else {
                    print("❌ Invalid URL format")
                }
            } else {
                print("ℹ️ No profile image URL found in Firebase")
            }
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return menuItems.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if this is the Dark Mode row
        // For admin: Dark Mode is at index 3 (Privacy, About, Logout, DarkMode)
        // For non-admin: Dark Mode is at index 7 (PersonalInfo, Privacy, About, Report, Reset, Delete, Logout, DarkMode)
        let darkModeIndex = isAdmin ? 3 : 7
        
        if indexPath.row == darkModeIndex {
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
        iconContainer.isUserInteractionEnabled = true  // ✅ Allow tapping for everyone
        
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
        
        // ✅ Everyone can upload profile pictures
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
        
        let selectedItem = menuItems[indexPath.row]
        
        // Map the selected item to the appropriate action
        switch selectedItem {
        case NSLocalizedString("Personal Information", comment: ""):
            navigateToPersonalInfo()
        case NSLocalizedString("Privacy and Policy", comment: ""):
            showScrollableAlert(title: "Privacy Policy", message: getPrivacyPolicyText())
        case NSLocalizedString("About", comment: ""):
            showScrollableAlert(title: "About Masar", message: getAboutText())
        case NSLocalizedString("Report an Issue", comment: ""):
            showReportSheet()
        case NSLocalizedString("Reset Password", comment: ""):
            navigateToResetPassword()
        case NSLocalizedString("Delete Account", comment: ""):
            showDeleteAccountAlert()
        case NSLocalizedString("Log Out", comment: ""):
            showLogOutAlert()
        case NSLocalizedString("Language", comment: ""):
            showLanguageOptions()
        default:
            break
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
            // ✅ Clear user role from UserDefaults on logout
            UserDefaults.standard.removeObject(forKey: "userRole")
            // Note: We keep adminProfileImage so it persists across logins
            UserDefaults.standard.synchronize()
            
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
                if let error = error {
                    self?.showAlert("Error: \(error.localizedDescription)")
                } else {
                    // ✅ Clear user role from UserDefaults on delete
                    UserDefaults.standard.removeObject(forKey: "userRole")
                    UserDefaults.standard.synchronize()
                    
                    self?.goToSignIn()
                }
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
    
    func getAboutText() -> String {
        return """
        Welcome to Masar!

        At Masar, we believe in the power of community — where people can share their skills, offer their services, and connect with others who need them. Our mobile application is designed to make it easier for individuals in the Kingdom of Bahrain to find, offer, and exchange local skills and services in a convenient and trustworthy way.

        Our Mission
        Empower individuals and small service providers by giving them a platform to showcase their talents and connect with people who need their expertise.
        Whether you're a handyman, tutor, designer, or mechanic, Masar helps you reach those who need your help quickly and easily.

        What We Offer
        • Skill & Service Search:
        Browse and search for local professionals or individuals offering the services you need — from home repairs to photography, tutoring, and more.

        • Service Posting:
        If you have a skill or service to offer, create a profile and post your services within minutes. Let others in your community find and hire you with ease.

        • Secure Communication:
        Contact service providers or clients directly through our secure in-app messaging feature — fast, safe, and simple.

        • Ratings & Reviews:
        We value trust and transparency. That's why users can rate and review each other's services to help maintain quality and reliability across the community.

        • Location-Based Results:
        Find nearby service providers instantly using our location-based search — connecting you with people in your area who can help right away.

        • User-Friendly Interface:
        Our app is built with simplicity and usability in mind. Whether you're offering a service or searching for one, Masar makes it straightforward and intuitive for everyone.

        Our Vision
        We aim to create a connected community in Bahrain where skills, services, and opportunities can be exchanged with ease.
        Masar aspires to become the go-to local platform for people to discover, collaborate, and grow together.

        Join Us
        Download Masar today and become part of a community built on trust, collaboration, and local connection. Whether you're looking for help or ready to offer your expertise.

        Masar is here to make it happen.
        East or west Masar is the Best!
        """
    }
    
    func getPrivacyPolicyText() -> String {
        return """
        Masar operates the Local Skills & Services Exchange application.
        This page is used to inform Masar users regarding our policies with the collection, use, and disclosure of personal information if anyone decides to use our Service.

        By using the Masar app, you agree to the collection and use of information in accordance with this policy. The personal information that we collect is used for providing, improving, and personalizing our Service. We will not use or share your information with anyone except as described in this Privacy Policy.

        Information Collection and Use
        To enhance your experience while using our Service, we may require you to provide certain personally identifiable information, including but not limited to your full name, phone number, location, and service preferences. The information we collect will be used to:
        • Help match users seeking skills or services with those providing them.
        • Facilitate communication between users.
        • Improve and personalize your experience in the app.

        Service Providers
        We may employ third-party companies and individuals for the following purposes:
        • To assist in improving our Service;
        • To provide the Service on our behalf;
        • To analyze app usage and performance.

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
        Masar@gmail.com
        +973-39871234
        """
    }
}

// MARK: - ☁️ Cloudinary Upload Extension
extension ProfileTableViewController: PHPickerViewControllerDelegate {
    
    // MARK: - 🖼️ Profile Image Actions
    @objc func avatarTapped() {
        let alert = UIAlertController(title: "Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        // 1. خيار اختيار صورة (نفس الكود القديم)
        alert.addAction(UIAlertAction(title: "Change Photo", style: .default) { _ in
            self.openPhotoPicker()
        })
        
        // 2. خيار حذف الصورة (يظهر فقط إذا كان المستخدم قد وضع صورة بالفعل)
        // هذا الخيار سيعيد الصورة إلى الـ Default
        if currentProfileImage != nil {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .destructive) { _ in
                self.removeProfilePhoto()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // لتجنب المشاكل في الآيباد
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }

    // دالة مساعدة لفتح الاستوديو (فصلنا الكود ليكون أرتب)
    func openPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // دالة حذف الصورة والعودة للافتراضي
    func removeProfilePhoto() {
        // 1. تحديث الواجهة فوراً (إزالة الصورة الحالية)
        self.currentProfileImage = nil
        self.tableView.reloadData() // سيعود الكود تلقائياً لاستخدام "person.fill" الموجود في viewForHeaderInSection
        
        // 2. حذف من البيانات (Backend/Storage)
        if isAdmin {
            UserDefaults.standard.removeObject(forKey: "adminProfileImage")
            UserDefaults.standard.synchronize()
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            // حذف حقل الصورة من فايربيس
            Firestore.firestore().collection("users").document(uid).updateData([
                "profileImageURL": FieldValue.delete()
            ]) { error in
                if let error = error {
                    print("❌ Error removing photo: \(error.localizedDescription)")
                } else {
                    print("✅ Photo removed successfully (Reverted to default)")
                }
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else {
            print("❌ No image selected")
            return
        }
        
        print("📸 Image selected, loading...")
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert("Failed to load image: \(error.localizedDescription)")
                }
                return
            }
            
            guard let image = object as? UIImage else {
                print("❌ Failed to convert to UIImage")
                DispatchQueue.main.async {
                    self.showAlert("Failed to process selected image")
                }
                return
            }
            
            print("✅ Image loaded successfully, size: \(image.size)")
            
            DispatchQueue.main.async {
                // Update UI immediately
                self.currentProfileImage = image
                self.tableView.reloadData()
                
                // Check if admin
                if self.isAdmin {
                    // Save admin image locally
                    print("👑 Saving admin profile image locally...")
                    self.saveAdminImageLocally(image: image)
                } else {
                    // Upload regular user image to Cloudinary
                    let alert = UIAlertController(title: "Uploading...", message: "Please wait while we upload your image.", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    self.uploadToCloudinary(image: image, loadingAlert: alert)
                }
            }
        }
    }
    
    // Save admin profile image to UserDefaults
    func saveAdminImageLocally(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ Failed to convert admin image to JPEG")
            showAlert("Failed to save profile picture")
            return
        }
        
        let base64String = imageData.base64EncodedString()
        UserDefaults.standard.set(base64String, forKey: "adminProfileImage")
        UserDefaults.standard.synchronize()
        
        print("✅ Admin profile image saved locally (\(imageData.count) bytes)")
        showAlert("✅ Admin profile picture saved successfully!")
    }
    
    // 🔥 Improved Cloudinary Upload with extensive debugging
    func uploadToCloudinary(image: UIImage, loadingAlert: UIAlertController) {
        print("🚀 Starting Cloudinary upload...")
        print("📋 Cloud Name: \(cloudinaryCloudName)")
        print("📋 Upload Preset: \(cloudinaryUploadPreset)")
        
        // 1. Validate configuration
        guard !cloudinaryCloudName.isEmpty,
              cloudinaryCloudName != "YOUR_CLOUD_NAME",
              !cloudinaryUploadPreset.isEmpty,
              cloudinaryUploadPreset != "YOUR_UPLOAD_PRESET" else {
            print("❌ Invalid Cloudinary configuration")
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self.showAlert("⚠️ Cloudinary not configured properly")
                }
            }
            return
        }

        // 2. Build URL
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudinaryCloudName)/image/upload"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self.showAlert("❌ Invalid Cloudinary URL")
                }
            }
            return
        }
        
        print("🌐 Upload URL: \(urlString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        
        // 3. Convert image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ Failed to convert image to JPEG")
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self.showAlert("❌ Failed to process image")
                }
            }
            return
        }
        
        print("📦 Image data size: \(imageData.count) bytes (\(imageData.count / 1024) KB)")
        
        // 4. Build multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(cloudinaryUploadPreset)\r\n".data(using: .utf8)!)
        
        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("📤 Total request size: \(body.count) bytes (\(body.count / 1024) KB)")
        print("⏳ Sending request to Cloudinary...")
        
        // 5. Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Check for network error
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert("❌ Upload failed: Network error")
                    }
                }
                return
            }
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("⚠️ Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            
            // Check data
            guard let data = data else {
                print("❌ No data received from server")
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert("❌ No response from server")
                    }
                }
                return
            }
            
            print("📥 Received data: \(data.count) bytes")
            
            // Parse JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("📋 Response JSON keys: \(json.keys)")
                    
                    // Check for error in response
                    if let errorDict = json["error"] as? [String: Any],
                       let message = errorDict["message"] as? String {
                        print("❌ Cloudinary error: \(message)")
                        DispatchQueue.main.async {
                            loadingAlert.dismiss(animated: true) {
                                self.showAlert("❌ Upload failed: \(message)")
                            }
                        }
                        return
                    }
                    
                    // Extract secure URL
                    if let secureUrl = json["secure_url"] as? String {
                        print("✅ Upload successful!")
                        print("🔗 Image URL: \(secureUrl)")
                        
                        // Save to Firebase
                        self.saveImageURLToFirestore(url: secureUrl, loadingAlert: loadingAlert)
                    } else {
                        print("❌ No secure_url in response")
                        print("📋 Full response: \(json)")
                        DispatchQueue.main.async {
                            loadingAlert.dismiss(animated: true) {
                                self.showAlert("❌ Invalid response from Cloudinary")
                            }
                        }
                    }
                } else {
                    print("❌ Response is not JSON")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📋 Raw response: \(responseString)")
                    }
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            self.showAlert("❌ Invalid response format")
                        }
                    }
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📋 Raw response: \(responseString)")
                }
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert("❌ Failed to parse server response")
                    }
                }
            }
        }.resume()
    }
    
    func saveImageURLToFirestore(url: String, loadingAlert: UIAlertController) {
        print("💾 Saving image URL to Firestore...")
        print("🔗 URL to save: \(url)")
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user ID found")
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    self.showAlert("❌ User not logged in")
                }
            }
            return
        }
        
        print("👤 User ID: \(uid)")
        
        let userData: [String: Any] = [
            "profileImageURL": url,
            "profileImageUpdatedAt": FieldValue.serverTimestamp()
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        print("❌ Firestore save error: \(error.localizedDescription)")
                        self.showAlert("❌ Failed to save: \(error.localizedDescription)")
                    } else {
                        print("✅ Profile image URL saved successfully!")
                        self.showAlert("✅ Profile picture updated successfully!")
                    }
                }
            }
        }
    }
}

// MARK: - Helper Classes
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
