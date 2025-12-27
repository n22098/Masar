import UIKit

class ModerationCell: UITableViewCell {

    // MARK: - UI Components
    // حاوية البطاقة البيضاء
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // العنوان
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // السهم
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = UIColor.lightGray.withAlphaComponent(0.6)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. تنظيف الخلية الأصلية
        backgroundColor = .clear
        selectionStyle = .none
        textLabel?.isHidden = true // إخفاء النص القديم إذا وجد
        
        // 2. بناء التصميم الجديد
        setupModernDesign()
    }
    
    // هذه الدالة مهمة جداً لعمل مسافة بين الخلايا (شكل البطاقة العائمة)
    override func layoutSubviews() {
        super.layoutSubviews()
        // تصغير حجم المحتوى لترك مسافات من الجوانب ومن فوق وتحت
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
    }

    private func setupModernDesign() {
        // إضافة الحاوية لداخل الـ contentView
        contentView.addSubview(containerView)
        
        // تثبيت الحاوية لتملأ المساحة (بعد الـ inset)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // إضافة العناصر داخل الحاوية
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            // العنوان في المنتصف يساراً
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            // السهم في المنتصف يميناً
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    // دالة التعبئة
    func configure(title: String) {
        titleLabel.text = title
    }
    
    // أنيميشن الضغط
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            self.containerView.backgroundColor = highlighted ? UIColor(white: 0.95, alpha: 1) : .white
        }
    }
}
