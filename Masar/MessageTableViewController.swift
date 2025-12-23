import UIKit

class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    var providerData: ServiceProviderModel?
    
    private let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // Sample messages for demonstration
    private var messages: [Message] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
        
        // Register cells
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Navigation bar
        title = providerData?.name ?? "Chat"
        
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
        
        // Table view
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 80, right: 0)
        tableView.keyboardDismissMode = .interactive
        
        // Setup input accessory view (message input bar)
        setupInputAccessoryView()
    }
    
    private func setupInputAccessoryView() {
        // Create input toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        toolbar.barStyle = .default
        toolbar.backgroundColor = .white
        
        let textField = UITextField(frame: CGRect(x: 10, y: 5, width: view.frame.width - 70, height: 40))
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        textField.tag = 100
        
        let sendButton = UIButton(type: .system)
        sendButton.frame = CGRect(x: view.frame.width - 55, y: 5, width: 45, height: 40)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = brandColor
        sendButton.layer.cornerRadius = 8
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
        
        toolbar.addSubview(textField)
        toolbar.addSubview(sendButton)
        
        // Note: For proper keyboard handling, you'll need to add this as input accessory
        // For now, we'll add it to the table footer
        tableView.tableFooterView = toolbar
    }
    
    private func loadMessages() {
        // Sample messages for demonstration
        messages = [
            Message(text: "Hello! I'm interested in your services.", isSentByMe: true, timestamp: Date()),
            Message(text: "Hi there! Thank you for reaching out. How can I help you today?", isSentByMe: false, timestamp: Date().addingTimeInterval(60)),
            Message(text: "I'd like to know more about the website development package.", isSentByMe: true, timestamp: Date().addingTimeInterval(120)),
            Message(text: "Of course! The package includes responsive design, SEO optimization, and more. Would you like to schedule a consultation?", isSentByMe: false, timestamp: Date().addingTimeInterval(180))
        ]
    }
    
    @objc private func sendMessageTapped() {
        guard let toolbar = tableView.tableFooterView,
              let textField = toolbar.viewWithTag(100) as? UITextField,
              let messageText = textField.text,
              !messageText.isEmpty else {
            return
        }
        
        // Add new message
        let newMessage = Message(text: messageText, isSentByMe: true, timestamp: Date())
        messages.append(newMessage)
        
        // Clear text field
        textField.text = ""
        
        // Reload table and scroll to bottom
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // Simulate provider response after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let response = Message(text: "Thank you for your message. I'll get back to you shortly!", isSentByMe: false, timestamp: Date())
            self.messages.append(response)
            let responseIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.insertRows(at: [responseIndexPath], with: .automatic)
            self.tableView.scrollToRow(at: responseIndexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Message Model
struct Message {
    let text: String
    let isSentByMe: Bool
    let timestamp: Date
}

// MARK: - Message Cell
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
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        // Bubble constraints
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            bubbleView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -4)
        ])
        
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        // Message label constraints
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
        
        // Time label constraints
        NSLayoutConstraint.activate([
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.text
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        if message.isSentByMe {
            // Sent message (right side, purple)
            bubbleView.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
            messageLabel.textColor = .white
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            timeLabel.textAlignment = .right
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor).isActive = true
        } else {
            // Received message (left side, light gray)
            bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            messageLabel.textColor = .black
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
            timeLabel.textAlignment = .left
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
        }
    }
}
