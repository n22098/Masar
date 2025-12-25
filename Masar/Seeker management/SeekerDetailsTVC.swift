import UIKit

class SeekerDetailsTVC: UITableViewController {

    // MARK: - Outlets
    // اربط هذه الحقول فقط من الستوري بورد
    @IBOutlet weak var fullNameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var phoneTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    
    // سنستخدم هذا فقط لإخفائه، وسنبني زراً جديداً بالكود لضمان شكله
    @IBOutlet weak var statusMenuButton: UIButton?
    
    // MARK: - Properties
    var seeker: Seeker?
    var isNewSeeker: Bool = false
    private var currentStatus: String = "Active"
    
    // العناصر البرمجية (لبناء الهيدر المثالي)
    private let headerView = UIView()
    private let proProfileImage = UIImageView()
    private let proNameLabel = UILabel()
    private let proRoleLabel = UILabel()
    private let proStatusButton = UIButton(type: .system)
    
    // ألوان المشروع
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // بيانات وهمية للتجربة
        if seeker == nil && !isNewSeeker {
            seeker = SampleData.seekers.first
        }
        
        setupMainDesign()      // إعداد الصفحة
        setupProHeader()       // بناء الهيدر بالكود
        setupTextFieldsStyle() // تجميل الحقول
        loadData()             // تعبئة البيانات
        
        // 👇 هذا هو الحل لمشكلة الزر
        setupSaveButtonProgrammatically()
    }
    
    // MARK: - 1. زر الحفظ (الحل المضمون)
    private func setupSaveButtonProgrammatically() {
        // ننشئ الزر بالكود لنتأكد أنه مربوط
        let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        saveBtn.tintColor = .white
        
        // نضعه في النافيجيشن بار
        self.navigationItem.rightBarButtonItem = saveBtn
    }
    
    @objc private func saveButtonTapped() {
        print("🟢 Save button pressed!") // للتأكد في الكونسول
        
        // التحقق من البيانات
        guard let name = fullNameTextField?.text, !name.isEmpty else {
            let alert = UIAlertController(title: "Missing Info", message: "Please enter the full name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // حفظ البيانات
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
        
        // ✅ إظهار رسالة النجاح
        let successAlert = UIAlertController(title: "Success", message: "Seeker details have been saved successfully!", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // العودة للصفحة السابقة بعد الضغط على OK
            self?.navigationController?.popViewController(animated: true)
        })
        present(successAlert, animated: true)
    }

    // MARK: - 2. إعداد التصميم (لإصلاح الشكل المكسور)
    private func setupMainDesign() {
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
        
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none
        
        statusMenuButton?.isHidden = true // إخفاء الزر القديم
    }

    // MARK: - 3. بناء الهيدر بالكود
    private func setupProHeader() {
        let headerHeight: CGFloat = 280
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight)
        headerView.backgroundColor = bgColor
        
        // خلفية بنفسجية
        let purpleBackground = UIView()
        purpleBackground.backgroundColor = brandColor
        purpleBackground.layer.cornerRadius = 30
        purpleBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        purpleBackground.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(purpleBackground)
        
        // الصورة
        proProfileImage.translatesAutoresizingMaskIntoConstraints = false
        proProfileImage.contentMode = .scaleAspectFill
        proProfileImage.layer.cornerRadius = 55
        proProfileImage.layer.borderWidth = 5
        proProfileImage.layer.borderColor = bgColor.cgColor
        proProfileImage.clipsToBounds = true
        proProfileImage.backgroundColor = .white
        headerView.addSubview(proProfileImage)
        
        // الاسم
        proNameLabel.translatesAutoresizingMaskIntoConstraints = false
        proNameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        proNameLabel.textColor = .black
        proNameLabel.textAlignment = .center
        headerView.addSubview(proNameLabel)
        
        proRoleLabel.translatesAutoresizingMaskIntoConstraints = false
        proRoleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        proRoleLabel.textColor = .gray
        proRoleLabel.textAlignment = .center
        headerView.addSubview(proRoleLabel)
        
        // زر الحالة الجديد
        proStatusButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        proStatusButton.configuration = config
        proStatusButton.showsMenuAsPrimaryAction = true
        
        let actions = [
            UIAction(title: "Active", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Active", .systemGreen) },
            UIAction(title: "Suspend", image: UIImage(systemName: "pause.circle.fill")) { [weak self] _ in self?.updateStatusUI("Suspend", .systemOrange) },
            UIAction(title: "Ban", image: UIImage(systemName: "xmark.circle.fill")) { [weak self] _ in self?.updateStatusUI("Ban", .systemRed) }
        ]
        proStatusButton.menu = UIMenu(children: actions)
        headerView.addSubview(proStatusButton)
        
        // القيود
        NSLayoutConstraint.activate([
            purpleBackground.topAnchor.constraint(equalTo: headerView.topAnchor),
            purpleBackground.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            purpleBackground.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            purpleBackground.heightAnchor.constraint(equalToConstant: 100),
            
            proProfileImage.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            proProfileImage.centerYAnchor.constraint(equalTo: purpleBackground.bottomAnchor),
            proProfileImage.widthAnchor.constraint(equalToConstant: 110),
            proProfileImage.heightAnchor.constraint(equalToConstant: 110),
            
            proNameLabel.topAnchor.constraint(equalTo: proProfileImage.bottomAnchor, constant: 12),
            proNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            proRoleLabel.topAnchor.constraint(equalTo: proNameLabel.bottomAnchor, constant: 4),
            proRoleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            proStatusButton.topAnchor.constraint(equalTo: proRoleLabel.bottomAnchor, constant: 16),
            proStatusButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            proStatusButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - 4. تجميل الحقول
    private func setupTextFieldsStyle() {
        let fields = [fullNameTextField, emailTextField, phoneTextField, usernameTextField]
        let icons = ["person", "envelope", "phone", "at"]
        let placeholders = ["Full Name", "Email Address", "Phone Number", "Username"]
        
        for (index, tf) in fields.enumerated() {
            guard let tf = tf else { continue }
            
            tf.borderStyle = .none
            tf.backgroundColor = .white
            tf.layer.cornerRadius = 12
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.systemGray5.cgColor
            tf.layer.shadowColor = UIColor.black.cgColor
            tf.layer.shadowOpacity = 0.03
            tf.layer.shadowOffset = CGSize(width: 0, height: 2)
            tf.layer.shadowRadius = 4
            
            let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
            let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
            iconView.image = UIImage(systemName: icons[index])
            iconView.tintColor = .systemGray2
            iconView.contentMode = .scaleAspectFit
            iconContainer.addSubview(iconView)
            
            tf.leftView = iconContainer
            tf.leftViewMode = .always
            tf.textColor = .black
            tf.attributedPlaceholder = NSAttributedString(string: placeholders[index], attributes: [.foregroundColor: UIColor.lightGray])
            
            tf.translatesAutoresizingMaskIntoConstraints = false
            if let heightConstraint = tf.constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint.constant = 50
            } else {
                tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
            }
        }
    }
    
    // MARK: - 5. تعبئة البيانات
    private func loadData() {
        guard let seeker = seeker else { return }
        
        proNameLabel.text = seeker.fullName
        proRoleLabel.text = seeker.roleType
        
        if let img = UIImage(named: seeker.imageName) {
            proProfileImage.image = img
        } else {
            proProfileImage.image = UIImage(systemName: "person.circle.fill")
            proProfileImage.tintColor = .systemGray4
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
        proStatusButton.configuration?.title = status
        proStatusButton.configuration?.baseBackgroundColor = color.withAlphaComponent(0.1)
        proStatusButton.configuration?.baseForegroundColor = color
    }
    
    // تباعد الخلايا
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    // إخفاء الكيبورد
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
