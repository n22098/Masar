import UIKit
import FirebaseFirestore

class ProviderDetailsTVC: UITableViewController {

    // MARK: - Properties
    var provider: Provider?
    private var currentStatus: String = "approved"
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Outlets
    
    // 1. Header Outlets (تأكد من ربطها بالمربع العلوي Header View)
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var statusBadge: UILabel!
    
    // 2. Cell Outlets (خلايا البيانات)
    @IBOutlet weak var fullNameValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var phoneValueLabel: UILabel!
    @IBOutlet weak var usernameValueLabel: UILabel!
    
    // 3. Footer Outlets (الأزرار السفلية)
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        setupUI() // تنسيق التصميم
        setupStatusMenu()
        loadData()
    }
    
    // MARK: - Setup
    private func setupNavigation() {
        title = "Provider Details"
        // إعدادات البار العلوي لتطابق Seeker
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupTableView() {
        // لون الخلفية وتنسيق الفواصل
        tableView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // إزالة المسافة العلوية المزعجة (مثل كود Seeker)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func setupUI() {
        // 1. تنسيق الصورة
        if let profileImageView = profileImageView {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.layer.cornerRadius = 45 // نصف القطر ليكون دائري (بافتراض الحجم 90x90)
            profileImageView.clipsToBounds = true
            profileImageView.layer.borderWidth = 3
            profileImageView.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        }
        
        // 2. تنسيق بادج الحالة (Active/Suspended)
        if let statusBadge = statusBadge {
            statusBadge.font = .systemFont(ofSize: 13, weight: .semibold)
            statusBadge.textAlignment = .center
            statusBadge.layer.cornerRadius = 12
            statusBadge.clipsToBounds = true
        }
        
        // 3. تنسيق زر القائمة المنسدلة
        if let statusButton = statusButton {
            statusButton.layer.cornerRadius = 12
            statusButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            statusButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
            statusButton.showsMenuAsPrimaryAction = true
        }
        
        // 4. تنسيق زر الحفظ
        if let saveButton = saveButton {
            saveButton.backgroundColor = brandColor
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            saveButton.layer.cornerRadius = 16
            
            // إضافة ظل للزر
            saveButton.layer.shadowColor = brandColor.cgColor
            saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            saveButton.layer.shadowRadius = 12
            saveButton.layer.shadowOpacity = 0.3
            saveButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
            
            // إضافة حركات الضغط (Animations)
            saveButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
            saveButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    // MARK: - Animations
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    // MARK: - Data Logic
    private func setupStatusMenu() {
        let actions = [
            UIAction(title: "Approved", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                self?.currentStatus = "approved"
                self?.updateStatusUI()
            },
            UIAction(title: "Suspended", image: UIImage(systemName: "xmark.circle.fill"), attributes: .destructive) { [weak self] _ in
                self?.currentStatus = "suspended"
                self?.updateStatusUI()
            }
        ]
        statusButton?.menu = UIMenu(children: actions)
    }
    
    private func loadData() {
        guard let provider = provider else { return }
        
        // تعبئة الهيدر
        profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView?.tintColor = brandColor.withAlphaComponent(0.5)
        usernameLabel?.text = provider.username.isEmpty ? "N/A" : provider.username
        roleLabel?.text = provider.category // أو "Provider"
        
        // تعبئة الخلايا
        fullNameValueLabel?.text = provider.fullName
        emailValueLabel?.text = provider.email
        phoneValueLabel?.text = provider.phone.isEmpty ? "N/A" : provider.phone
        usernameValueLabel?.text = provider.username
        
        // الحالة
        currentStatus = provider.status.lowercased()
        if currentStatus.isEmpty { currentStatus = "approved" }
        updateStatusUI()
        
        // تحديث الجدول
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func updateStatusUI() {
        let isApproved = currentStatus == "approved" || currentStatus == "active"
        let color: UIColor = isApproved ? .systemGreen : .systemRed
        let displayStatus = isApproved ? "Approved" : "Suspended"
        
        // تحديث البادج
        statusBadge?.text = displayStatus
        statusBadge?.textColor = color
        statusBadge?.backgroundColor = color.withAlphaComponent(0.15)
        
        // تحديث الزر
        statusButton?.setTitle(displayStatus, for: .normal)
        statusButton?.backgroundColor = color.withAlphaComponent(0.15)
        statusButton?.setTitleColor(color, for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let uid = provider?.uid else { return }
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.6
        saveButton.setTitle("Saving...", for: .normal)
        
        // التحديث في قاعدة البيانات
        Firestore.firestore().collection("provider_requests").document(uid).updateData([
            "status": currentStatus
        ]) { [weak self] error in
            guard let self = self else { return }
            
            self.saveButton.isEnabled = true
            self.saveButton.alpha = 1.0
            self.saveButton.setTitle("Save Changes", for: .normal)
            
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to update.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                print("✅ Status Updated")
                self.provider?.status = self.currentStatus
                
                let alert = UIAlertController(title: "Success", message: "Status updated successfully!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }
}
