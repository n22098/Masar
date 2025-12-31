import UIKit

final class ChatViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let user: User
    private var messages: [Message] = []
    private let conversation: Conversation
    private var inputBottomConstraint: NSLayoutConstraint!
    
    private var currentUserId: String {
        AuthService.shared.currentUserId ?? ""
    }
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let inputContainer = UIView()
    private let attachButton = UIButton(type: .system)
    private let textField = UITextField()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        // لون زر الإرسال (يمكنك تغييره للون البنفسجي أو لون مميز آخر)
        button.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var didAutoFocusOnce = false

    // MARK: - Init
    init(conversation: Conversation) {
        self.conversation = conversation
        self.user = conversation.user
        self.messages = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didAutoFocusOnce {
            didAutoFocusOnce = true
            DispatchQueue.main.async { [weak self] in
                self?.textField.becomeFirstResponder()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // 1. إعداد البار العلوي (بدلاً من الهيدر المخصص)
        setupNavigationBar()
        
        setupTableView()
        setupInputBar()
        scrollToBottom(animated: false)
        
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)

        ChatService.shared.listenForMessages(
            currentUserId: currentUserId,
            otherUserId: user.id
        ) { [weak self] messages in
            DispatchQueue.main.async {
                self?.messages = messages
                self?.tableView.reloadData()
                self?.scrollToBottom(animated: true)
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ إظهار البار العلوي لهذه الشاشة
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        // في شاشة الشات، نفضل العنوان الصغير (Inline) وليس الكبير
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // ✅ اللون البنفسجي الموحد
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white // لون زر الرجوع
        
        // إعداد عنوان مخصص (صورة + اسم) في الوسط
        setupCustomTitleView()
    }
    
    private func setupCustomTitleView() {
        // وعاء (Container) للعنوان
        let titleView = UIView()
        
        // صورة المستخدم
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray4
        
        // تحميل الصورة
        if let imageName = user.profileImageName, let url = URL(string: imageName) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")
            imageView.tintColor = .white
        }
        
        // الاسم
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .white
        
        // الإيميل (اختياري كعنوان فرعي)
        let subtitleLabel = UILabel()
        subtitleLabel.text = user.email
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        
        // ترتيب العناصر رأسياً (اسم تحته ايميل)
        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 0
        
        // ترتيب الصورة بجانب النصوص
        let mainStack = UIStackView(arrangedSubviews: [imageView, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            
            mainStack.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            // لتحديد حجم الـ TitleView بناءً على محتواه
            mainStack.topAnchor.constraint(equalTo: titleView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        ])
        
        navigationItem.titleView = titleView
    }

    // MARK: - Layout Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // لون خلفية واتساب (بيج فاتح)
        tableView.backgroundColor = UIColor(red: 236/255, green: 229/255, blue: 221/255, alpha: 1)
        
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            // ✅ الجدول يبدأ من الـ Safe Area (تحت البار العلوي مباشرة)
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupInputBar() {
        textField.returnKeyType = .send
        textField.delegate = self
        textField.isUserInteractionEnabled = true
        inputContainer.isUserInteractionEnabled = true

        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = .white
        inputContainer.layer.borderColor = UIColor.systemGray5.cgColor
        inputContainer.layer.borderWidth = 1
        
        inputContainer.layer.shadowColor = UIColor.black.cgColor
        inputContainer.layer.shadowOpacity = 0.05
        inputContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputContainer.layer.shadowRadius = 3
        
        view.addSubview(inputContainer)

        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.setImage(UIImage(systemName: "plus"), for: .normal)
        attachButton.tintColor = .systemBlue
        inputContainer.addSubview(attachButton)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Message"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.font = UIFont.systemFont(ofSize: 16)
        inputContainer.addSubview(textField)

        inputContainer.addSubview(sendButton)

        inputBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBottomConstraint.isActive = true
        
        attachButton.addTarget(self, action: #selector(didTapAttach), for: .touchUpInside)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 60),

            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            attachButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            attachButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 30),
            attachButton.heightAnchor.constraint(equalToConstant: 30),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),

            textField.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Actions

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }

    @objc private func didTapSend() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        let senderId = AuthService.shared.currentUserId
        guard !senderId.isEmpty else { return }

        ChatService.shared.sendMessage(
            text: text,
            from: senderId,
            to: conversation.user.id
        )

        textField.text = ""
    }

    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let keyboardVisible = keyboardFrame.origin.y < UIScreen.main.bounds.height
        let height = keyboardVisible ? keyboardFrame.height - view.safeAreaInsets.bottom : 0

        inputBottomConstraint.constant = -height

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16),
            animations: {
                self.view.layoutIfNeeded()
                if keyboardVisible {
                    self.scrollToBottom(animated: false)
                }
            }
        )
    }
    
    // MARK: - Attachment Actions
    @objc private func didTapAttach() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openPhotoLibrary()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        guard !currentUserId.isEmpty else { return }

        ChatService.shared.sendImageUsingCloudinary(
            image: image,
            from: currentUserId,
            to: user.id
        )
    }
}

// MARK: - Delegates
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as! MessageCell
        cell.configure(
            with: messages[indexPath.row],
            currentUserId: currentUserId
        )
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
