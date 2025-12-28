import UIKit

class ReportItemCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    
    // الألوان الموحدة للمشروع
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // العناصر الإضافية للتصميم
    private var containerView: UIView!
    private var stackView: UIStackView?
    private var chevronImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
            // خلفية الخلية شفافة
            backgroundColor = .clear
            selectionStyle = .none
            
            // 👇 أضف هذا السطر لإخفاء السهم الخارجي الزائد
            accessoryType = .none
            
            // إعداد حاوية البطاقة
            setupContainerView()
            
            // إعداد المحتوى
            setupStackView()
            setupChevron()
        }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12 // زوايا دائرية
        // إضافة ظل خفيف جداً للاحترافية
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        
        // تثبيت البطاقة مع هوامش من الأطراف
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func setupStackView() {
        // التأكد من إزالة العناصر من الـ Superview الأصلي
        [idLabel, subjectLabel, reporterLabel].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            $0?.removeFromSuperview()
        }
        
        // إنشاء الـ StackView
        stackView = UIStackView(arrangedSubviews: [idLabel, subjectLabel, reporterLabel].compactMap { $0 })
        stackView?.axis = .vertical
        stackView?.spacing = 6
        stackView?.alignment = .leading
        stackView?.distribution = .fill
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let stack = stackView {
            // نضيف الـ Stack داخل الـ ContainerView وليس الـ ContentView
            containerView.addSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40), // مساحة للسهم
                stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
            ])
        }
    }
    
    private func setupChevron() {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronImageView = UIImageView(image: image)
        chevronImageView?.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        chevronImageView?.contentMode = .scaleAspectFit
        chevronImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let chevron = chevronImageView {
            containerView.addSubview(chevron) // داخل البطاقة
            
            NSLayoutConstraint.activate([
                chevron.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                chevron.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                chevron.widthAnchor.constraint(equalToConstant: 8),
                chevron.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
    }

    func configure(with report: ReportItem) {
            // ID: صغير ورمادي في الأعلى
            idLabel?.text = "#\(report.reportID)"
            idLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            idLabel?.textColor = UIColor.systemGray2
            
            // Subject: العنوان الرئيسي - بارز
            subjectLabel?.text = report.subject
            subjectLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            subjectLabel?.textColor = UIColor.black
            
            // Reporter: تلوين الاسم فقط
            let reporterText = "Reporter: "
            let nameText = report.reporter
            
            // التصحيح هنا: استخدمنا .foregroundColor بدلاً من .textColor
            let attributedString = NSMutableAttributedString(string: reporterText, attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.gray // ✅ الصحيح
            ])
            
            attributedString.append(NSAttributedString(string: nameText, attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: brandColor // ✅ الصحيح
            ]))
            
            reporterLabel?.attributedText = attributedString
        }
    
    // إضافة أنيميشن عند الضغط لجعل التطبيق يشعرك بالحيوية
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.backgroundColor = highlighted ? UIColor(white: 0.97, alpha: 1) : .white
        }
    }
}
