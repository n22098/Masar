import UIKit

/// moderationToolTVC: A specialized menu for administrators to access moderation functions.
/// OOD Principle: Customization via Delegation - This controller uses the 'willDisplay' delegate
/// method to perform real-time UI injection on standard cells.
class moderationToolTVC: UITableViewController {
    
    // MARK: - Properties
    /// Centralized brand color to maintain a professional administrative aesthetic.
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    /// Configures the Navigation Bar and global TableView appearance.
    private func setupUI() {
        // Navigation Bar styling: Ensuring white text on a purple background.
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
        
        // TableView styling: Background color and removal of default separator lines.
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    /// heightForRowAt: Provides consistent vertical spacing for the card design.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    // MARK: - Table View Delegate
    
    /// willDisplay: OOD Principle (View Enrichment) - This method allows us to modify
    /// the cell's view hierarchy right before it appears on the screen.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // 1. Cleanup Logic: Prevents UI stacking bugs when cells are reused during scrolling.
        for subview in cell.contentView.subviews {
            if let label = subview as? UILabel, label != cell.textLabel && label != cell.detailTextLabel {
                label.removeFromSuperview()
            }
        }
        
        // 2. Card Setup: Setting the cell to be transparent so our custom card shows through.
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.accessoryType = .none
        cell.selectionStyle = .none // Prevents the default gray highlight
        
        var cardBackgroundView: UIView?
        
        // 2. Card View Creation: Using a 'Tag' system (999) to identify and reuse our custom background.
        if let existingCard = cell.viewWithTag(999) {
            cardBackgroundView = existingCard
        } else {
            let cardBackground = UIView()
            cardBackground.tag = 999
            cardBackground.backgroundColor = .white
            cardBackground.layer.cornerRadius = 12
            
            // Soft Shadow for a modern "floating" look (UX Depth).
            cardBackground.layer.shadowColor = UIColor.black.cgColor
            cardBackground.layer.shadowOpacity = 0.05
            cardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardBackground.layer.shadowRadius = 4
            
            cell.contentView.addSubview(cardBackground)
            cell.contentView.sendSubviewToBack(cardBackground)
            
            // Auto Layout: Pins the card inside the cell with custom margins.
            cardBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardBackground.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                cardBackground.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
                cardBackground.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                cardBackground.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            cardBackgroundView = cardBackground
        }
        
        // 3. Custom Accessory: Adding a manual chevron inside the card (Tag 888).
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
        
        // 4. Content Formatting: Styling the default text label.
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cell.textLabel?.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 1.0)
        cell.detailTextLabel?.text = nil
        
        // 5. Data Population: Hard-coding the menu items for the tool.
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Category Management"
                cell.imageView?.image = UIImage(systemName: "square.grid.2x2.fill")
                cell.imageView?.tintColor = brandColor
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Reports"
                cell.imageView?.image = UIImage(systemName: "exclamationmark.bubble.fill")
                cell.imageView?.tintColor = brandColor
            }
            else if indexPath.row == 2 {
                cell.textLabel?.text = "Verification"
                cell.imageView?.image = UIImage(systemName: "checkmark.shield.fill")
                cell.imageView?.tintColor = brandColor
            }
        }
    }
    
    /// didSelectRowAt: Provides visual feedback when a menu item is tapped.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
