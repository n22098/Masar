import UIKit

class moderationToolTVC: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
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
        
        self.navigationItem.title = "Moderations Tool"
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // 1. إخفاء أي نصوص مكررة موجودة مسبقاً
        for subview in cell.contentView.subviews {
            if let label = subview as? UILabel, label != cell.textLabel && label != cell.detailTextLabel {
                label.removeFromSuperview()
            }
        }
        
        // 2. إنشاء خلفية البطاقة (Card View)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        // 2. إنشاء خلفية البطاقة (Card View)
        var cardBackgroundView: UIView?
        
        if let existingCard = cell.viewWithTag(999) {
            cardBackgroundView = existingCard
        } else {
            let cardBackground = UIView()
            cardBackground.tag = 999
            cardBackground.backgroundColor = .white
            cardBackground.layer.cornerRadius = 12
            
            cardBackground.layer.shadowColor = UIColor.black.cgColor
            cardBackground.layer.shadowOpacity = 0.05
            cardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardBackground.layer.shadowRadius = 4
            
            cell.contentView.addSubview(cardBackground)
            cell.contentView.sendSubviewToBack(cardBackground)
            
            cardBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardBackground.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                cardBackground.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
                cardBackground.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                cardBackground.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            cardBackgroundView = cardBackground
        }
        
        // 3. إضافة سهم مخصص
        if cell.contentView.viewWithTag(888) == nil, let cardBg = cardBackgroundView {
            let arrowImageView = UIImageView()
            arrowImageView.tag = 888
            arrowImageView.image = UIImage(systemName: "chevron.right")
            arrowImageView.tintColor = .systemGray3
            arrowImageView.contentMode = .scaleAspectFit
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(arrowImageView)
            cell.contentView.bringSubviewToFront(arrowImageView)
            
            NSLayoutConstraint.activate([
                arrowImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                arrowImageView.trailingAnchor.constraint(equalTo: cardBg.trailingAnchor, constant: -16),
                arrowImageView.widthAnchor.constraint(equalToConstant: 12),
                arrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        // 4. تنسيق النص والأيقونة
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cell.textLabel?.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 1.0)
        cell.detailTextLabel?.text = nil
        
        // 5. تعبئة البيانات حسب indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                // Category Management
                cell.textLabel?.text = "Category Management"
                cell.imageView?.image = UIImage(systemName: "square.grid.2x2.fill")
                cell.imageView?.tintColor = brandColor
            }
            else if indexPath.row == 1 {
                // Report Management
                cell.textLabel?.text = "Reports"
                cell.imageView?.image = UIImage(systemName: "exclamationmark.bubble.fill")
                cell.imageView?.tintColor = brandColor
            }
            else if indexPath.row == 2 {
                // Verification
                cell.textLabel?.text = "Verification"
                cell.imageView?.image = UIImage(systemName: "checkmark.shield.fill")
                cell.imageView?.tintColor = brandColor
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
