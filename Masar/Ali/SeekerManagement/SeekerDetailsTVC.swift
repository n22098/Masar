import UIKit
import FirebaseFirestore

class SeekerDetailsTVC: UITableViewController {

    // MARK: - Outlets
    // تم تحويلها إلى UILabel
    @IBOutlet weak var fullNameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var usernameLabel: UILabel?
    
    // زر الحالة (القديم)
    @IBOutlet weak var statusMenuButton: UIButton?
    
    // MARK: - Properties
    var seeker: Seeker?
    var isNewSeeker: Bool = false // (لم يعد لها فائدة كبيرة في وضع العرض فقط، لكن تركتها لعدم كسر الكود)
    private var currentStatus: String = "Active"
    
    // UI Elements
    private let headerContainer = UIView()
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let statusLabel = UILabel()
    
    private let footerContainer = UIView()
    private let footerTitleLabel = UILabel()
    private let statusButton = UIButton(type: .system)
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainSettings()
        setupHeaderOnlyInfo()
        setupLabelStyles() // دالة التنسيق الجديدة للـ Labels
        setupFooterButtonOnly()
        loadData()
        
        // (تم إزالة زر الحفظ لأن الصفحة أصبحت للعرض فقط)
        
        // إصلاح المسافات في iOS 15+
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Header Logic (إظهار العنوان في الوسط فقط)
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = .white
            
            let label = UILabel()
            label.text = "Personal Information"
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
            ])
            
            return headerView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 45 : 0
    }
    
    // MARK: - Setup Functions
    private func setupMainSettings() {
        title = "Profile Details" // لم نعد بحاجة لـ New Seeker لأننا في وضع عرض
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        statusMenuButton?.isHidden = true
    }

    private func setupHeaderOnlyInfo() {
        let headerHeight: CGFloat = 140
        headerContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight)
        headerContainer.backgroundColor = .white
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 12
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.systemGray5.cgColor
        profileImage.clipsToBounds = true
        headerContainer.addSubview(profileImage)
        
        nameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(nameLabel)
        
        roleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        roleLabel.textColor = .gray
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(roleLabel)
        
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            profileImage.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            roleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 5),
            statusLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20)
        ])
        
        tableView.tableHeaderView = headerContainer
    }
    
    private func setupFooterButtonOnly() {
        let footerHeight: CGFloat = 100
        footerContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight)
        footerContainer.backgroundColor = .white
        
        footerTitleLabel.text = "Account Status"
        footerTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        footerTitleLabel.textColor = .gray
        footerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.addSubview(footerTitleLabel)
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        statusButton.configuration = config
        statusButton.showsMenuAsPrimaryAction = true
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Active", .systemGreen) },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Ban", .systemRed) }
        ]
        statusButton.menu = UIMenu(children: actions)
        
        footerContainer.addSubview(statusButton)
        
        NSLayoutConstraint.activate([
            footerTitleLabel.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 10),
            footerTitleLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 20),
            
            statusButton.topAnchor.constraint(equalTo: footerTitleLabel.bottomAnchor, constant: 8),
            statusButton.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 20),
            statusButton.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: -20),
            statusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.tableFooterView = footerContainer
    }
    
    // MARK: - تنسيق الـ Labels
    private func setupLabelStyles() {
        let labels = [fullNameLabel, emailLabel, phoneLabel, usernameLabel]
        
        for label in labels {
            guard let lbl = label else { continue }
            
            // إعدادات الخط واللون
            lbl.textColor = .darkGray
            lbl.font = .systemFont(ofSize: 16, weight: .regular)
            lbl.textAlignment = .right // أو left حسب تصميمك في الستوري بورد
            
            // إضافة الخط الفاصل السفلي (Bottom Line)
            lbl.layer.sublayers?.forEach { if $0.name == "bottomLine" { $0.removeFromSuperlayer() } }
            
            let bottomLine = CALayer()
            bottomLine.name = "bottomLine"
            bottomLine.frame = CGRect(x: 0, y: 49, width: tableView.bounds.width, height: 1)
            bottomLine.backgroundColor = UIColor.systemGray5.cgColor
            lbl.layer.addSublayer(bottomLine)
            
            // ملاحظة: الـ Labels لا تدعم الـ leftView، لذلك يجب عليك إضافة عناوين الحقول (مثل "Full Name")
            // مباشرة في الستوري بورد كـ Labels ثابتة بجانب هذه الـ Labels.
        }
    }

    // MARK: - Load Data
    private func loadData() {
        guard let seeker = seeker else { return }
        
        nameLabel.text = seeker.fullName
        roleLabel.text = "Role: \(seeker.role)"
        
        if let img = UIImage(named: seeker.imageName) {
            profileImage.image = img
        } else {
            profileImage.image = UIImage(systemName: "person.crop.square.fill")
            profileImage.tintColor = .systemGray4
        }
        
        // تعبئة البيانات في الـ Labels
        fullNameLabel?.text = seeker.fullName
        emailLabel?.text = seeker.email
        phoneLabel?.text = seeker.phone
        usernameLabel?.text = seeker.username
        
        let color: UIColor
        switch seeker.status {
        case "Active": color = .systemGreen
        case "Ban": color = .systemRed
        default: color = .systemGray
        }
        updateStatusUI(seeker.status, color)
    }
    
    // MARK: - Save Logic (تم إرسال حالة التحديث فقط للزر السفلي)
    private func updateStatusUI(_ status: String, _ color: UIColor) {
        currentStatus = status
        // هنا يمكنك إضافة كود لحفظ تغيير الحالة فقط في Firebase إذا أردت
        // لأن باقي الحقول أصبحت للقراءة فقط
        
        statusButton.configuration?.title = status
        statusButton.configuration?.baseBackgroundColor = color.withAlphaComponent(0.15)
        statusButton.configuration?.baseForegroundColor = color
        
        statusLabel.text = "Status: \(status)"
        statusLabel.textColor = color
        
        // حفظ الحالة في الفايربيس عند التغيير من القائمة
        if let uid = seeker?.uid {
             let db = Firestore.firestore()
             db.collection("users").document(uid).updateData(["status": status]) { err in
                 if err == nil {
                     print("Status updated to \(status)")
                 }
             }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
