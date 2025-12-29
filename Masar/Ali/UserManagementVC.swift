//
//  UserManagementVC.swift
//  Masar
//
//  Created by BP-19-130-15 on 19/12/2025.
//

import UIKit

class UserManagementVC: UITableViewController {

    // ألوان المشروع
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupModernDesign()
    }
    
    private func setupModernDesign() {
        // 1. إعداد العنوان والنافيجيشن بار
        self.navigationItem.title = "User Management"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false

        // 2. إعداد خلفية الجدول
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none
        
        // إزالة الهيدر الفائض
        tableView.tableHeaderView = nil
        
        // إضافة مسافة علوية بسيطة
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table view data source logic
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // 1. تنظيف الخلية من العناصر الزائدة
        cell.contentView.subviews.forEach { subview in
            if let label = subview as? UILabel {
                if label != cell.textLabel && label != cell.detailTextLabel {
                    label.isHidden = true
                }
            }
        }
        
        // 2. إعدادات الخلية الأساسية
        cell.backgroundColor = .clear
        // 🛑 مهم جداً: نلغي السهم الافتراضي لأننا سنضيف سهماً مخصصاً داخل البطاقة
        cell.accessoryType = .none
        // نخفي التفاصيل الافتراضية
        cell.detailTextLabel?.isHidden = true
        
        // تعريف متغير للبطاقة الخلفية لنستخدمه في قيود السهم لاحقاً
        var cardBackgroundView: UIView?

        // 3. إنشاء خلفية البطاقة (Card View)
        // نستخدم تاج 999 للبطاقة
        if let existingCard = cell.viewWithTag(999) {
            cardBackgroundView = existingCard
        } else {
            let cardBackground = UIView()
            cardBackground.tag = 999
            cardBackground.backgroundColor = .white
            cardBackground.layer.cornerRadius = 12
            
            // إضافة ظل
            cardBackground.layer.shadowColor = UIColor.black.cgColor
            cardBackground.layer.shadowOpacity = 0.05
            cardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardBackground.layer.shadowRadius = 4
            
            cell.contentView.addSubview(cardBackground)
            cell.contentView.sendSubviewToBack(cardBackground)
            
            cardBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardBackground.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
                cardBackground.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5),
                // هوامش البطاقة الجانبية
                cardBackground.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                cardBackground.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            
            cardBackgroundView = cardBackground
        }
        
        // 4. ✅ إضافة سهم مخصص "داخل البوكس"
        // نستخدم تاج مختلف (مثلاً 888) للسهم المخصص لضمان عدم تكراره
        if cell.contentView.viewWithTag(888) == nil, let cardBg = cardBackgroundView {
            let arrowImageView = UIImageView()
            arrowImageView.tag = 888
            // استخدام أيقونة السهم الافتراضية للنظام
            arrowImageView.image = UIImage(systemName: "chevron.right")
            // نفس اللون الرمادي الذي كنت تستخدمه
            arrowImageView.tintColor = .systemGray3
            arrowImageView.contentMode = .scaleAspectFit
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(arrowImageView)
            // التأكد من أن السهم يظهر فوق البطاقة
            cell.contentView.bringSubviewToFront(arrowImageView)

            NSLayoutConstraint.activate([
                // توسيط السهم عمودياً
                arrowImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                // ✅ ربط الحافة اليمنى للسهم بالحافة اليمنى للبطاقة (وليس الخلية) مع مسافة بسيطة
                arrowImageView.trailingAnchor.constraint(equalTo: cardBg.trailingAnchor, constant: -16),
                // تحديد حجم مناسب للسهم
                arrowImageView.widthAnchor.constraint(equalToConstant: 12),
                arrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        // 5. تنسيق النصوص الأساسية والأيقونات
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.textLabel?.textColor = .darkGray
        
        // تعبئة البيانات والأيقونات
        if indexPath.row == 0 {
            cell.textLabel?.text = "Seeker Management"
            cell.imageView?.image = UIImage(systemName: "person.2.circle.fill")
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Provider Management"
            cell.imageView?.image = UIImage(systemName: "briefcase.circle.fill")
        }
        
        // تلوين أيقونة السطر (التي على اليسار)
        cell.imageView?.tintColor = brandColor
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
