import UIKit
import FirebaseFirestore
import FirebaseAuth

final class SimpleChatViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var otherUser: AppUser?
    var conversationId: String?
    
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)
    
    private var messages: [Message] = []
    private var listener: ListenerRegistration?
    private var bottomConstraint: NSLayoutConstraint!
    
    private var currentUid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startListening()
        setupKeyboardObservers()
    }
    
    deinit {
        listener?.remove() //
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        setupCustomNavBar()
        setupTableView()
        setupInputArea()
    }

    private func setupCustomNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
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
        avatar.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        avatar.image = UIImage(systemName: "person.circle.fill")
        avatar.tintColor = .white
        
        let nameLbl = UILabel()
        nameLbl.text = otherUser?.name ?? "Chat"
        nameLbl.textColor = .white
        nameLbl.font = .boldSystemFont(ofSize: 17)
        
        stack.addArrangedSubview(avatar)
        stack.addArrangedSubview(nameLbl)
        titleView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            stack.heightAnchor.constraint(equalTo: titleView.heightAnchor)
        ])
        navigationItem.titleView = titleView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupInputArea() {
        messageInputView.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputView)
        
        attachButton.setImage(UIImage(systemName: "plus"), for: .normal)
        attachButton.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.addTarget(self, action: #selector(didTapAttach), for: .touchUpInside)
        messageInputView.addSubview(attachButton)
        
        messageTextField.placeholder = "Message..."
        messageTextField.backgroundColor = .white
        messageTextField.layer.cornerRadius = 20
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        messageTextField.leftViewMode = .always
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.delegate = self
        messageInputView.addSubview(messageTextField)
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        messageInputView.addSubview(sendButton)
        
        bottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            messageInputView.heightAnchor.constraint(equalToConstant: 70),
            
            attachButton.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 12),
            attachButton.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 10),
            attachButton.widthAnchor.constraint(equalToConstant: 35),
            attachButton.heightAnchor.constraint(equalToConstant: 35),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: attachButton.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 35),
            sendButton.heightAnchor.constraint(equalToConstant: 35),
            
            messageTextField.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 10),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageTextField.centerYAnchor.constraint(equalTo: attachButton.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor)
        ])
    }

    // MARK: - Data Handling
    private func startListening() {
        guard let otherUid = otherUser?.id else { return }
        
        // Using the unified listener from ChatService
        listener = ChatService.shared.listenForMessages(currentUserId: currentUid, otherUserId: otherUid) { [weak self] updatedMessages in
            self?.messages = updatedMessages
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
        }
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Actions
    @objc private func didTapSend() {
        guard let text = messageTextField.text, !text.isEmpty, let otherUid = otherUser?.id else { return }
        
        // Using ChatService to send text
        ChatService.shared.sendMessage(text: text, from: currentUid, to: otherUid)
        messageTextField.text = ""
    }

    @objc private func didTapAttach() {
        let alert = UIAlertController(title: "Attach Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.presentPicker(source: .camera) })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in self.presentPicker(source: .photoLibrary) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func presentPicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        
        // enable video selection
        picker.mediaTypes = ["public.image", "public.movie"]
        
        present(picker, animated: true)
    }

    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let otherUid = otherUser?.id else { return } //
        let currentUid = Auth.auth().currentUser?.uid ?? "" //

        if let videoURL = info[.mediaURL] as? URL {
            // Handle Video
            ChatService.shared.sendVideoUsingCloudinary(videoURL: videoURL, from: currentUid, to: otherUid)
        } else if let image = info[.originalImage] as? UIImage {
            // Handle Image
            ChatService.shared.sendImageUsingCloudinary(image: image, from: currentUid, to: otherUid)
        }
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let isHidden = frame.cgRectValue.origin.y >= UIScreen.main.bounds.height
        bottomConstraint.constant = isHidden ? 0 : -frame.cgRectValue.height + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if !isHidden { self.scrollToBottom() }
        }
    }
}

// MARK: - TableView Extensions
extension SimpleChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as! MessageCell
//        cell.configure(with: messages[indexPath.row], currentUserId: currentUid) //
//        return cell
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        
        cell.configure(with: message, currentUserId: currentUid)
        
        // ✅ Unified closure: Handles both Images and Videos
        cell.onImageTapped = { [weak self] tappedImage in
            guard let self = self else { return }
            
            // 1. Check if the message is a video based on the URL extension
            if let urlString = message.imageURL, urlString.contains(".mp4") {
                guard let url = URL(string: urlString) else { return }
                let videoVC = VideoPreviewViewController(videoURL: url)
                videoVC.modalPresentationStyle = .fullScreen
                self.present(videoVC, animated: true)
            } else {
                // 2. Otherwise, treat it as an image and use the passed 'tappedImage'
                let previewVC = ImagePreviewViewController()
                previewVC.image = tappedImage // ✅ Uses the image passed from the cell
                previewVC.modalPresentationStyle = .fullScreen
                self.present(previewVC, animated: true)
            }
        }
        
        return cell
    }
}
