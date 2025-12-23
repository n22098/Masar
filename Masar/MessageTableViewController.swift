import UIKit

// MARK: - Message List Controller
class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    // This variable receives data from the previous screen
    var providerData: ServiceProviderModel?
    
    private let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    private var conversations: [Conversation] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadConversations()
        
        // Register the cell
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        
        // Check if we came from a specific provider (via "Chat" button)
        if let provider = providerData {
            handleIncomingProvider(provider)
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Messages"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    private func loadConversations() {
        // Dummy Data
        conversations = [
            Conversation(
                providerName: "Sayed Husain",
                providerRole: "Software Engineer",
                providerImage: "person1",
                lastMessage: "Of course! The package includes responsive design...",
                timestamp: Date().addingTimeInterval(-300),
                unreadCount: 2,
                isOnline: true
            ),
            Conversation(
                providerName: "Amin Altajer",
                providerRole: "Computer Repair",
                providerImage: "person2",
                lastMessage: "I can fix that for you tomorrow",
                timestamp: Date().addingTimeInterval(-3600),
                unreadCount: 0,
                isOnline: false
            )
        ]
        
        conversations.sort { $0.timestamp > $1.timestamp }
    }
    
    private func handleIncomingProvider(_ provider: ServiceProviderModel) {
        // 1. Check if conversation exists
        if let index = conversations.firstIndex(where: { $0.providerName == provider.name }) {
            let convo = conversations.remove(at: index)
            conversations.insert(convo, at: 0)
            openChat(for: convo)
        } else {
            // 2. Create new conversation
            let newConvo = Conversation(
                providerName: provider.name,
                providerRole: provider.role,
                providerImage: provider.imageName,
                lastMessage: "Start a new conversation",
                timestamp: Date(),
                unreadCount: 0,
                isOnline: true
            )
            conversations.insert(newConvo, at: 0)
            openChat(for: newConvo)
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation Logic (FIXED: No Segue needed)
    private func openChat(for conversation: Conversation) {
        // We create the controller manually to avoid "Missing Segue" crashes
        let chatVC = ChatDetailTableViewController()
        chatVC.providerName = conversation.providerName
        chatVC.providerRole = conversation.providerRole
        chatVC.providerImage = conversation.providerImage
        // If you need to pass the full model:
        // chatVC.providerData = self.providerData
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        openChat(for: conversation)
    }
}

// MARK: - Chat Detail Controller
class ChatDetailTableViewController: UITableViewController {
    
    var providerName: String?
    var providerRole: String?
    var providerImage: String?
    var providerData: ServiceProviderModel?
    
    private let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    private var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
        // Important: Register the cell here since we are not using Storyboard prototypes for the detail
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    }
    
    private func setupUI() {
        title = providerName ?? "Chat"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 80, right: 0)
        
        setupInputAccessoryView()
    }
    
    private func setupInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        toolbar.barStyle = .default
        toolbar.backgroundColor = .white
        
        let textField = UITextField(frame: CGRect(x: 16, y: 10, width: view.frame.width - 86, height: 40))
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        textField.tag = 100
        
        let sendButton = UIButton(type: .system)
        sendButton.frame = CGRect(x: view.frame.width - 60, y: 10, width: 44, height: 40)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = brandColor
        sendButton.layer.cornerRadius = 8
        sendButton.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
        
        toolbar.addSubview(textField)
        toolbar.addSubview(sendButton)
        tableView.tableFooterView = toolbar
    }
    
    private func loadMessages() {
        messages = [
            Message(text: "Hello! I'm interested in your services.", isSentByMe: true, timestamp: Date()),
            Message(text: "Hi! How can I help you?", isSentByMe: false, timestamp: Date().addingTimeInterval(60))
        ]
    }
    
    @objc private func sendMessageTapped() {
        guard let toolbar = tableView.tableFooterView,
              let textField = toolbar.viewWithTag(100) as? UITextField,
              let text = textField.text, !text.isEmpty else { return }
        
        let msg = Message(text: text, isSentByMe: true, timestamp: Date())
        messages.append(msg)
        textField.text = ""
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - Models
struct Conversation {
    let providerName: String
    let providerRole: String
    let providerImage: String
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
    let isOnline: Bool
}

struct Message {
    let text: String
    let isSentByMe: Bool
    let timestamp: Date
}

// MARK: - Cells
class ConversationCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with conversation: Conversation) {
        nameLabel.text = conversation.providerName
        messageLabel.text = conversation.lastMessage
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timeLabel.text = formatter.localizedString(for: conversation.timestamp, relativeTo: Date())
        
        if let image = UIImage(named: conversation.providerImage) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}

class MessageCell: UITableViewCell {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!
    private var timeLeading: NSLayoutConstraint!
    private var timeTrailing: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            bubbleView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        bubbleLeading = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailing = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        timeLeading = timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        timeTrailing = timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.text
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        if message.isSentByMe {
            bubbleView.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
            messageLabel.textColor = .white
            
            bubbleLeading.isActive = false
            timeLeading.isActive = false
            bubbleTrailing.isActive = true
            timeTrailing.isActive = true
            
            timeLabel.textAlignment = .right
        } else {
            bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            messageLabel.textColor = .black
            
            bubbleTrailing.isActive = false
            timeTrailing.isActive = false
            bubbleLeading.isActive = true
            timeLeading.isActive = true
            
            timeLabel.textAlignment = .left
        }
    }
}
