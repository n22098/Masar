import UIKit

class SeekerDetailsTVC: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var fullNameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var phoneTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    
    // الزر القديم (مخفي)
    @IBOutlet weak var statusMenuButton: UIButton?
    
    // MARK: - Properties
    var seeker: Seeker?
    var isNewSeeker: Bool = false
    private var currentStatus: String = "Active"
    
    // عناصر الهيدر
    private let headerContainer = UIView()
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    
    // عناصر الفوتر (الزر فقط)
    private let footerContainer = UIView()
    private let statusButton = UIButton(type: .system)
    
    // الألوان
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if seeker == nil && !isNewSeeker {
            seeker = SampleData.seekers.first
        }
        
        setupMainSettings()
        setupHeaderOnlyInfo()   // الهيدر (تم تقليص المساحة)
        setupListStyleFields()  // القائمة
        setupFooterButtonOnly() // الفوتر (تم رفع الزر للأعلى)
        loadData()
        setupSaveButton()
    }
    
    // MARK: - 1. إعدادات الصفحة
    private func setupMainSettings() {
        title = isNewSeeker ? "New Seeker" : "Profile Details"
        
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

    // MARK: - 2. الهيدر (تم تقليص الارتفاع)
    private func setupHeaderOnlyInfo() {
        // 👇 قللنا الارتفاع هنا لتقليل المساحة الفارغة العلوية
        let headerHeight: CGFloat = 120
        headerContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight)
        headerContainer.backgroundColor = .white
        
        // الصورة (يسار)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 50
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor.systemGray6.cgColor
        profileImage.clipsToBounds = true
        headerContainer.addSubview(profileImage)
        
        // الاسم
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(nameLabel)
        
        // الوظيفة
        roleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        roleLabel.textColor = .gray
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(roleLabel)
        
        // القيود
        NSLayoutConstraint.activate([
            // الصورة
            profileImage.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            profileImage.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.heightAnchor.constraint(equalToConstant: 100),
            
            // الاسم والوظيفة (في المنتصف بجانب الصورة)
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: -10),
            nameLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20)
        ])
        
        tableView.tableHeaderView = headerContainer
    }
    
    // MARK: - 3. الفوتر (تم رفع الزر للأعلى)
    private func setupFooterButtonOnly() {
        let footerHeight: CGFloat = 80 // ارتفاع صغير وملموم
        footerContainer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight)
        footerContainer.backgroundColor = .white
        
        // إعداد الزر
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        statusButton.configuration = config
        statusButton.showsMenuAsPrimaryAction = true
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        
        // القائمة المنسدلة
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Active", .systemGreen) },
            UIAction(title: "Suspend", image: UIImage(systemName: "pause.circle.fill")) { [weak self] _ in self?.updateStatusUI("Suspend", .systemOrange) },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Ban", .systemRed) }
        ]
        statusButton.menu = UIMenu(children: actions)
        
        footerContainer.addSubview(statusButton)
        
        // القيود للفوتر
        NSLayoutConstraint.activate([
            // 👇 هنا السر: قللنا المسافة العلوية إلى 4 فقط ليكون تحت العنوان مباشرة
            statusButton.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 4),
            statusButton.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 20),
            statusButton.heightAnchor.constraint(equalToConstant: 44),
            statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        tableView.tableFooterView = footerContainer
    }
    
    // MARK: - 4. تصميم القائمة (List Style)
    private func setupListStyleFields() {
        let fields = [fullNameTextField, emailTextField, phoneTextField, usernameTextField]
        let labels = ["Full Name", "Email", "Phone", "Username"]
        
        for (index, tf) in fields.enumerated() {
            guard let tf = tf else { continue }
            
            tf.borderStyle = .none
            tf.backgroundColor = .white
            tf.layer.sublayers?.forEach { if $0.name == "bottomLine" { $0.removeFromSuperlayer() } }
            
            let labelWidth: CGFloat = 100
            let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 50))
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth - 10, height: 50))
            label.text = labels[index]
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = .black
            leftContainer.addSubview(label)
            
            tf.leftView = leftContainer
            tf.leftViewMode = .always
            
            tf.textColor = .darkGray
            tf.textAlignment = .left
            tf.font = .systemFont(ofSize: 16, weight: .regular)
            tf.placeholder = ""
            
            let bottomLine = CALayer()
            bottomLine.name = "bottomLine"
            bottomLine.frame = CGRect(x: 0, y: 49, width: tableView.bounds.width, height: 1)
            bottomLine.backgroundColor = UIColor.systemGray5.cgColor
            tf.layer.addSublayer(bottomLine)
            
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }

    // MARK: - 5. البيانات
    private func loadData() {
        guard let seeker = seeker else { return }
        
        nameLabel.text = seeker.fullName
        roleLabel.text = seeker.roleType
        
        if let img = UIImage(named: seeker.imageName) {
            profileImage.image = img
        } else {
            profileImage.image = UIImage(systemName: "person.circle.fill")
            profileImage.tintColor = .systemGray4
        }
        
        fullNameTextField?.text = seeker.fullName
        emailTextField?.text = seeker.email
        phoneTextField?.text = seeker.phone
        usernameTextField?.text = seeker.username
        
        let color: UIColor
        switch seeker.status {
        case "Active": color = .systemGreen
        case "Suspend": color = .systemOrange
        case "Ban": color = .systemRed
        default: color = .systemGray
        }
        updateStatusUI(seeker.status, color)
    }
    
    private func updateStatusUI(_ status: String, _ color: UIColor) {
        currentStatus = status
        seeker?.status = status
        statusButton.configuration?.title = status
        statusButton.configuration?.baseBackgroundColor = color.withAlphaComponent(0.15)
        statusButton.configuration?.baseForegroundColor = color
    }
    
    // MARK: - 6. الحفظ
    private func setupSaveButton() {
        let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        saveBtn.tintColor = .white
        navigationItem.rightBarButtonItem = saveBtn
    }
    
    @objc private func saveTapped() {
        guard let name = fullNameTextField?.text, !name.isEmpty else { return }
        
        if isNewSeeker {
            let new = Seeker(fullName: name, email: emailTextField?.text ?? "", phone: phoneTextField?.text ?? "", username: usernameTextField?.text ?? "", status: currentStatus, imageName: "profile1", roleType: "Seeker")
            SampleData.seekers.append(new)
        } else {
            if let index = SampleData.seekers.firstIndex(where: { $0.fullName == seeker?.fullName }) {
                SampleData.seekers[index].fullName = name
                SampleData.seekers[index].email = emailTextField?.text ?? ""
                SampleData.seekers[index].phone = phoneTextField?.text ?? ""
                SampleData.seekers[index].status = currentStatus
            }
        }
        
        let success = UIAlertController(title: "Success", message: "Changes saved successfully.", preferredStyle: .alert)
        success.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(success, animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
