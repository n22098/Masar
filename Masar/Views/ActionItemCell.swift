import UIKit

class ActionItemCell: UITableViewCell {

    // نبقي هذا الربط لمنع حدوث Crash، لكن سنبني التصميم برمجياً ليكون أجمل
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - UI Components (العناصر الجديدة للتصميم الاحترافي)
    
    // حاوية الأيقونة الملونة
    private let iconContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12 // زوايا دائرية
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // الأيقونة نفسها
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // العنوان الجديد (بخط أوضح)
    private let customTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // سهم التنقل
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .systemGray3
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // نخفي العنوان القديم القادم من الستوريبورد لنستخدم التصميم الجديد
        if titleLabel != nil { titleLabel.isHidden = true }
        
        setupModernDesign()
    }

    // دالة لعمل مسافة بين الخلايا (كأنها بطاقات منفصلة)
    override func layoutSubviews() {
        super.layoutSubviews()
        // تصغير حدود الخلية لتعطي انطباع "البطاقة العائمة"
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
    }

    private func setupModernDesign() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // تصميم البطاقة البيضاء
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        
        // إضافة ظل ناعم واحترافي
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        
        // إضافة العناصر للشاشة
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(customTitleLabel)
        contentView.addSubview(arrowImageView)
        
        // تفعيل القيود (Constraints)
        NSLayoutConstraint.activate([
            // مكان حاوية الأيقونة (يسار)
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 48),
            iconContainerView.heightAnchor.constraint(equalToConstant: 48),
            
            // مكان الأيقونة داخل الحاوية
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // مكان العنوان (بجانب الأيقونة)
            customTitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            customTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // مكان السهم (يمين)
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - Configuration Function (هنا الحل للمشكلة)
    // الآن الخلية تقبل الاسم والأيقونة واللون
    func configure(title: String, iconName: String, brandColor: UIColor) {
        customTitleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        
        // تلوين الخلفية بلون خفيف (Light Opacity) والأيقونة بلون غامق
        iconContainerView.backgroundColor = brandColor.withAlphaComponent(0.1)
        iconImageView.tintColor = brandColor
    }
}
