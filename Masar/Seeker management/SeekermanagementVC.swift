import UIKit

// 1. كلاس الخلية المخصصة (تصميم البطاقة)
class SeekerCardCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // إعداد البطاقة
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // إعداد الاسم
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // إعداد السهم
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(chevronImageView)
        
        // القيود (Constraints)
        NSLayoutConstraint.activate([
            // حدود البطاقة
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // مكان الاسم
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // مكان السهم
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 8),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(name: String) {
        nameLabel.text = name
    }
    
    // أنيميشن الضغط
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}

// 2. الكنترولر الرئيسي
class SeekermanagementVC: UITableViewController {

    // اللون البنفسجي الموحد
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // تسجيل الخلية الجديدة (هذا السطر هو الذي يحل مشكلة التداخل)
        // ملاحظة: استخدمت نفس الـ Identifier الموجود عندك في الكود القديم
        tableView.register(SeekerCardCell.self, forCellReuseIdentifier: "showSeekerDetailsCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        self.title = "Seeker Management"
        
        // إعداد النافيجيشن بار (بنفسجي + أبيض)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // زر الإضافة
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        // خلفية الجدول
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // تأكد أن SampleData معرفة لديك في المشروع
        return SampleData.seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // استخدام الخلية المخصصة SeekerCardCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath) as? SeekerCardCell else {
            return UITableViewCell()
        }
        
        let seeker = SampleData.seekers[indexPath.row]
        cell.configure(name: seeker.fullName)
        
        return cell
    }
    
    // MARK: - Navigation
    // لإلغاء التحديد عند العودة
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // نقوم بتشغيل الانتقال يدوياً لأننا نستخدم كود للخلية
        performSegue(withIdentifier: "showSeekerDetailsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SeekerDetailsTVC {
            
            // Check if segue is from the + button
            if segue.identifier == "addSeekerSegue" {
                // Adding new seeker
                detailVC.seeker = nil
                detailVC.isNewSeeker = true
            }
            // Check if segue is from table cell selection
            else if segue.identifier == "showSeekerDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // Showing existing seeker
                    detailVC.seeker = SampleData.seekers[indexPath.row]
                    detailVC.isNewSeeker = false
                }
            }
        }
    }
}
