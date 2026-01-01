import UIKit
import FirebaseAuth // 🔥 الاعتماد الكلي على الفايربيس

class ConversationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var conversations: [Conversation] = []
    
    // 🔥 جلب رقم المستخدم الحقيقي فقط
    var currentUserId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // للتأكد من حالة تسجيل الدخول في الكونسول
        if currentUserId.isEmpty {
            print("⚠️ ConversationsVC: No user logged in via Firebase Authentication.")
        } else {
            print("✅ ConversationsVC: User logged in with ID: \(currentUserId)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConversations()
    }
    
    func setupUI() {
        title = "Messages"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func loadConversations() {
        // ⛔️ إذا لم يكن هناك مستخدم حقيقي، توقف ولا تجلب شيئاً
        guard !currentUserId.isEmpty else {
            print("❌ Cannot fetch conversations: User is not logged in.")
            // اختياري: يمكنك هنا إظهار رسالة للمستخدم تطلب منه تسجيل الدخول
            return
        }
        
        print("🔄 Fetching conversations from Firestore for: \(currentUserId)...")
        
        FirebaseManager.shared.getConversations(userId: currentUserId) { [weak self] convos in
            print("📦 Firestore returned \(convos.count) conversations.")
            self?.conversations = convos
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChat",
           let chatVC = segue.destination as? ChatViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            
            let conv = conversations[indexPath.row]
            chatVC.conversation = conv
            chatVC.currentUserId = currentUserId
        }
    }
}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let conv = conversations[indexPath.row]
        cell.configure(conv, userId: currentUserId)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView?.layer.cornerRadius = 25
        profileImageView?.clipsToBounds = true
    }
    
    func configure(_ conv: Conversation, userId: String) {
        // تحديد من هو الطرف الآخر بناءً على المستخدم الحالي
        let isSeeker = conv.seekerId == userId
        
        // عرض اسم الطرف الآخر
        nameLabel?.text = isSeeker ? conv.providerName : conv.seekerName
        
        serviceLabel?.text = conv.serviceName
        lastMessageLabel?.text = conv.lastMessage
        timeLabel?.text = formatTime(conv.lastTime)
        
        // صورة افتراضية
        profileImageView?.image = UIImage(systemName: "person.circle.fill")
        profileImageView?.tintColor = .systemGray
    }
    
    func formatTime(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let fmt = DateFormatter()
            fmt.dateFormat = "h:mm a"
            return fmt.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM d"
            return fmt.string(from: date)
        }
    }
}
