// ===================================================================================
// NOTIFICATIONS VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Displays a real-time list of user notifications.
//
// KEY FEATURES:
// 1. Real-Time Sync: Uses Firestore SnapshotListener to update UI instantly when data changes.
// 2. Data Filtering: Fetches only notifications belonging to the current user.
// 3. User Feedback: Shows an "Empty State" label if no notifications exist.
// 4. Read Status: Visually distinguishes between read and unread items (Blue dot).
// 5. Interaction: Updates the database to mark items as "read" upon tapping.
// ===================================================================================

import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Notification Model
// Defines the structure of a notification object
struct NotificationModel {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
}

// MARK: - Notifications View Controller
class NotificationsViewController: UITableViewController {
    
    // MARK: - Properties
    // Local array to hold data fetched from Firebase
    var notifications: [NotificationModel] = []
    
    // Database Reference
    let db = Firestore.firestore()
    
    // Listener Registration: stored to remove the listener when the view disappears (prevents memory leaks)
    var listener: ListenerRegistration?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop listening for updates when the user leaves this screen
        listener?.remove()
    }
    
    // MARK: - UI Configuration
    private func setupUI() {
        title = "Notifications"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        // Register the custom cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
    }
    
    // MARK: - Fetching Data from Firebase
    private func fetchNotifications() {
        // Ensure user is logged in
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        // Query Construction:
        // 1. Select 'notifications' collection
        // 2. Filter by 'userId' to ensure privacy
        // 3. Sort by 'timestamp' descending (newest first)
        listener = db.collection("notifications")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Map Firestore documents to our local NotificationModel
                self.notifications = documents.compactMap { doc -> NotificationModel? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let message = data["message"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    
                    let isRead = data["isRead"] as? Bool ?? false
                    
                    return NotificationModel(
                        id: doc.documentID,
                        title: title,
                        message: message,
                        timestamp: timestamp.dateValue(),
                        isRead: isRead
                    )
                }
                
                // Update UI on the Main Thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Empty State Logic: Show a label if the list is empty
        if notifications.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            emptyLabel.text = "No Notifications Yet"
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let item = notifications[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    // MARK: - User Interaction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Mark as Read Logic: Update Firestore only if currently unread
        let notification = notifications[indexPath.row]
        if !notification.isRead {
            db.collection("notifications").document(notification.id).updateData(["isRead": true])
        }
    }
}

// MARK: - Custom Notification Cell
// A Programmatic UI Cell (No Storyboard needed for this specific cell)
class NotificationCell: UITableViewCell {
    
    // Container view to create the "Card" effect
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        // Shadow configuration
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bell.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Blue dot indicator for unread messages
    private let readIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Layout Configuration
    private func setupCellLayout() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        [iconImageView, titleLabel, messageLabel, timeLabel, readIndicator].forEach { containerView.addSubview($0) }
        
        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Container Constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Icon Constraints
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            // Message Constraints
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Time Constraints
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Read Indicator (Blue Dot) Constraints
            readIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            readIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            readIndicator.widthAnchor.constraint(equalToConstant: 8),
            readIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    // MARK: - Cell Configuration
    func configure(with item: NotificationModel) {
        titleLabel.text = item.title
        messageLabel.text = item.message
        timeLabel.text = item.timestamp.timeAgoDisplay() // Uses the extension below
        
        // Visual Styling: Unread vs Read
        if !item.isRead {
            // Unread: Blue border, visible dot, bold text
            containerView.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.3).cgColor
            containerView.layer.borderWidth = 1
            readIndicator.isHidden = false
            titleLabel.font = .boldSystemFont(ofSize: 16)
        } else {
            // Read: Clean look, hidden dot
            containerView.layer.borderWidth = 0
            readIndicator.isHidden = true
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        }
    }
}

// MARK: - Date Formatting Extension
extension Date {
    // Converts a Date object to a relative string (e.g., "5 min ago", "Yesterday")
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
