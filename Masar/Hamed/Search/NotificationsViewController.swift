import UIKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Notification Model
struct NotificationModel {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
}

// MARK: - Notifications View Controller (Real Data)
class NotificationsViewController: UITableViewController {
    
    // مصفوفة لتخزين البيانات القادمة من الفايربيس
    var notifications: [NotificationModel] = []
    let db = Firestore.firestore()
    
    // ليسنر للاستماع للتحديثات الحية
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        
        // جلب البيانات
        fetchNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // إيقاف الاستماع عند الخروج لتوفير الموارد
        listener?.remove()
    }
    
    // MARK: - Fetching Data from Firebase
    private func fetchNotifications() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        // جلب الإشعارات الخاصة بالمستخدم الحالي مرتبة حسب الوقت
        listener = db.collection("notifications")
            .whereField("userId", isEqualTo: currentUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching notifications: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
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
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // إظهار رسالة إذا لم تكن هناك تنبيهات
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // تحديث حالة القراءة في الفايربيس عند الضغط
        let notification = notifications[indexPath.row]
        if !notification.isRead {
            db.collection("notifications").document(notification.id).updateData(["isRead": true])
        }
    }
}

// MARK: - Updated Notification Cell
class NotificationCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    // مؤشر القراءة (نقطة زرقاء صغيرة)
    private let readIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.addSubview(containerView)
        [iconImageView, titleLabel, messageLabel, timeLabel, readIndicator].forEach { containerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // مكان مؤشر القراءة (أعلى اليمين في الكونتينر)
            readIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            readIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            readIndicator.widthAnchor.constraint(equalToConstant: 8),
            readIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with item: NotificationModel) {
        titleLabel.text = item.title
        messageLabel.text = item.message
        timeLabel.text = item.timestamp.timeAgoDisplay() // استخدام دالة الوقت
        
        // تغيير التصميم بناء على القراءة
        if !item.isRead {
            containerView.layer.borderColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 0.3).cgColor
            containerView.layer.borderWidth = 1
            readIndicator.isHidden = false
            titleLabel.font = .boldSystemFont(ofSize: 16)
        } else {
            containerView.layer.borderWidth = 0
            readIndicator.isHidden = true
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        }
    }
}

// MARK: - Date Extension for "Time Ago"
extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
