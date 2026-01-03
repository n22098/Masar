import UIKit

final class ChatViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let user: AppUser
    private var messages: [Message] = []
    private let conversation: Conversation
    private var inputBottomConstraint: NSLayoutConstraint!
    
    private var currentUserId: String {
        AuthService.shared.currentUserId ?? ""
    }
    
    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputContainer = UIView()
    private let attachButton = UIButton(type: .system)
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // Init
    init(conversation: Conversation) {
        self.conversation = conversation
        self.user = conversation.user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "chat_background") ?? UIImage()) // إذا عندك صورة خلفية
        if view.backgroundColor == nil { view.backgroundColor = UIColor(red: 236/255, green: 229/255, blue: 221/255, alpha: 1) }

        setupNavigationBar()
        setupTableView()
        setupInputBar()
        
        // الاستماع للرسائل
        ChatService.shared.listenForMessages(currentUserId: currentUserId, otherUserId: user.id) { [weak self] msgs in
            DispatchQueue.main.async {
                self?.messages = msgs
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
        }

        // الكيبورد
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: - Navigation Bar (Clean Design)
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1) // اللون البنفسجي
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        // Custom Title View (Avatar + Name)
        let titleView = UIView()
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: 36).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        avatar.layer.cornerRadius = 18
        avatar.clipsToBounds = true
        avatar.backgroundColor = .systemGray4
        avatar.image = UIImage(systemName: "person.circle.fill")
        avatar.tintColor = .white
        
        let nameLbl = UILabel()
        nameLbl.text = user.name
        nameLbl.textColor = .white
        nameLbl.font = .boldSystemFont(ofSize: 16)
        
        stack.addArrangedSubview(avatar)
        stack.addArrangedSubview(nameLbl)
        
        titleView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: titleView.widthAnchor),
            stack.heightAnchor.constraint(equalTo: titleView.heightAnchor)
        ])
        
        navigationItem.titleView = titleView
    }

    // MARK: - UI Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear // لتظهر خلفية الواتساب
        tableView.separatorStyle = .none
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupInputBar() {
        inputContainer.backgroundColor = .white
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        // Attach (+) Button
        attachButton.setImage(UIImage(systemName: "plus"), for: .normal)
        attachButton.tintColor = .systemBlue
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.addTarget(self, action: #selector(didTapAttach), for: .touchUpInside)
        inputContainer.addSubview(attachButton)
        
        // Send Button
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        inputContainer.addSubview(sendButton)
        
        // Text Field
        textField.placeholder = "Message"
        textField.backgroundColor = UIColor(white: 0.96, alpha: 1)
        textField.layer.cornerRadius = 18
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Padding inside text field
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        textField.leftView = padding
        textField.leftViewMode = .always
        inputContainer.addSubview(textField)
        
        inputBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 60),
            inputBottomConstraint,
            
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),
            
            attachButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 10),
            attachButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 30),
            attachButton.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 35),
            sendButton.heightAnchor.constraint(equalToConstant: 35),
            
            textField.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: - Actions
    
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        
        // ✅ This is the "Video Tab" enabler.
        // It tells iOS to show both images and videos in the picker.
        picker.mediaTypes = ["public.image", "public.movie"]
        
        present(picker, animated: true)
    }
    
    // 🔥 القائمة المنسدلة عند الضغط على (+)
    @objc private func didTapAttach() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentImagePicker(source: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo & Video Library", style: .default, handler: { _ in
            self.presentImagePicker(source: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            // يمكنك إضافة كود إرسال الموقع هنا لاحقاً
            print("Location tapped")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    // رفع الصورة عند اختيارها
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // إرسال الصورة
        ChatService.shared.sendImageUsingCloudinary(image: image, from: currentUserId, to: user.id)
    }

    @objc private func didTapSend() {
        guard let text = textField.text, !text.isEmpty else { return }
        ChatService.shared.sendMessage(text: text, from: currentUserId, to: user.id)
        textField.text = ""
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    // معالجة الكيبورد
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let isHidden = frame.origin.y >= UIScreen.main.bounds.height
        inputBottomConstraint.constant = isHidden ? 0 : -(frame.height - view.safeAreaInsets.bottom)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if !isHidden { self.scrollToBottom() }
        }
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as! MessageCell
        cell.configure(with: messages[indexPath.row], currentUserId: currentUserId)
        return cell
    }
}
