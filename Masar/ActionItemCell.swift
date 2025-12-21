import UIKit

class ActionItemCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()
            setupDesign()
        }

        // 🔥 1. دالة المسافات (لجعلها بطاقات منفصلة) 🔥
        override func layoutSubviews() {
            super.layoutSubviews()
            // زدنا المسافة التحتية (bottom) إلى 16 عشان تبعد عن بعض أكثر
            // وزدنا المسافات الجانبية إلى 20 عشان تكون أعرض
            contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 20, bottom: 16, right: 20))
        }
        
        // 🔥 2. دالة التصميم (الشكل، الحدود، السهم) 🔥
        func setupDesign() {
            // الخلفية الشفافة
            backgroundColor = .clear
            selectionStyle = .none
            
            // تصميم البطاقة البيضاء
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 16 // زوايا أكبر
            
            // إضافة حدود خفيفة (Border)
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemGray5.cgColor
            
            // إضافة ظل خفيف جداً
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOpacity = 0.08
            contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
            contentView.layer.shadowRadius = 6
            contentView.layer.masksToBounds = false
            
            // 👉 إضافة السهم (>) في نهاية الخلية
            let arrowImage = UIImage(systemName: "chevron.right")
            let arrowImageView = UIImageView(image: arrowImage)
            // تلوين السهم بنفس لون التطبيق البنفسجي ليكون متناسقاً
            arrowImageView.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
            accessoryView = arrowImageView
        }

        func configure(title: String) {
            titleLabel.text = title
            // تكبير الخط وتغميقه ليصبح واضحاً جداً
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            titleLabel.textColor = .darkText
        }
    }
