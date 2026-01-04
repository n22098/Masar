//
//  UserManagementVC.swift
//  Masar
//
//  Created by BP-19-130-15 on 19/12/2025.
//

import UIKit

/// UserManagementVC: Handles the administrative interface for managing different user types.
/// OOD Principle: Inheritance - Inherits from UITableViewController to leverage built-in
/// list management and scrolling behavior.
class UserManagementVC: UITableViewController {

    // MARK: - Properties
    /// Centralized color palette for the project (Encapsulation).
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModernDesign()
    }
    
    /// setupModernDesign: Configures the visual identity of the screen.
    /// OOD Note: Separating the UI setup from the logic ensures better maintainability.
    private func setupModernDesign() {
        // 1. Navigation Bar Setup: Applying the brand identity to the top bar.
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

        // 2. TableView Setup: Customizing the list background and spacing.
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none // Hiding default lines to use Card View design
        
        // Remove excess header space for a cleaner look
        tableView.tableHeaderView = nil
        
        // Content Insets: Adding top padding for the first card
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    // MARK: - Table View Delegate logic
    
    /// willDisplay: This method is called right before a cell is shown.
    /// We use it here to perform "View Injection" – adding custom card styling to standard cells.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // 1. View Cleanup: Removing or hiding default labels that aren't needed.
        cell.contentView.subviews.forEach { subview in
            if let label = subview as? UILabel {
                if label != cell.textLabel && label != cell.detailTextLabel {
                    label.isHidden = true
                }
            }
        }
        
        // 2. Basic Cell Configuration
        cell.backgroundColor = .clear
        // OOD Note: Disabling the default system accessory to provide a custom-positioned one.
        cell.accessoryType = .none
        cell.detailTextLabel?.isHidden = true
        
        var cardBackgroundView: UIView?

        // 3. Card View Construction: Creating a rounded container with a shadow.
        // OOD Principle: Reusability - We check for Tag 999 to avoid creating multiple views during scrolling.
        if let existingCard = cell.viewWithTag(999) {
            cardBackgroundView = existingCard
        } else {
            let cardBackground = UIView()
            cardBackground.tag = 999
            cardBackground.backgroundColor = .white
            cardBackground.layer.cornerRadius = 12
            
            // Applying Core Animation Shadow (UX Depth)
            cardBackground.layer.shadowColor = UIColor.black.cgColor
            cardBackground.layer.shadowOpacity = 0.05
            cardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardBackground.layer.shadowRadius = 4
            
            cell.contentView.addSubview(cardBackground)
            cell.contentView.sendSubviewToBack(cardBackground) // Ensure text is visible on top
            
            // Auto Layout Constraints for the Card
            cardBackground.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardBackground.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
                cardBackground.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5),
                cardBackground.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                cardBackground.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            
            cardBackgroundView = cardBackground
        }
        
        // 4. Custom Accessory: Adding a manual "Chevron" arrow inside the card.
        // We use Tag 888 to ensure we only add this once per cell.
        if cell.contentView.viewWithTag(888) == nil, let cardBg = cardBackgroundView {
            let arrowImageView = UIImageView()
            arrowImageView.tag = 888
            arrowImageView.image = UIImage(systemName: "chevron.right")
            arrowImageView.tintColor = .systemGray3
            arrowImageView.contentMode = .scaleAspectFit
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(arrowImageView)
            cell.contentView.bringSubviewToFront(arrowImageView)

            // Anchoring the arrow relative to the Card Background (OOD Component Design)
            NSLayoutConstraint.activate([
                arrowImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                arrowImageView.trailingAnchor.constraint(equalTo: cardBg.trailingAnchor, constant: -16),
                arrowImageView.widthAnchor.constraint(equalToConstant: 12),
                arrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        // 5. Data Mapping: Assigning text and icons based on the row index.
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.textLabel?.textColor = .darkGray
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Seeker Management"
            cell.imageView?.image = UIImage(systemName: "person.2.circle.fill")
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Provider Management"
            cell.imageView?.image = UIImage(systemName: "briefcase.circle.fill")
        }
        
        // Icon Styling
        cell.imageView?.tintColor = brandColor
    }
    
    /// heightForRowAt: Sets a fixed height to accommodate the card design.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    /// didSelectRowAt: Handles user interaction.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Immediate visual feedback: Deselecting the row after tap
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
