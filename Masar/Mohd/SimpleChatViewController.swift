import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices
import UniformTypeIdentifiers

final class SimpleChatViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    // MARK: - Properties
    var otherUser: AppUser?
    var conversationId: String?
    
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)
    
    private var messages: [Message] = []
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // قيد أسفل الشاشة (لتحريكه مع الكيبورد)
    private var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMessages()
        setupKeyboardObservers()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 🔥 طلبك: خلفية بيضاء
        view.backgroundColor = .white
        
        setupCustomNavBar()
        setupTableView()
        setupInputArea()
    }

    private func setupCustomNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // اللون البنفسجي الخاص بتطبيقك
        appearance.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // تصميم العنوان (صورة + اسم)
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
        tableView.backgroundColor = .white // خلفية الجدول بيضاء أيضاً
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // إضافة مسافة في الأسفل عشان آخر رسالة ما تتغطى
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        view.addSubview(tableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupInputArea() {
        messageInputView.backgroundColor = UIColor(white: 0.96, alpha: 1.0) // رمادي فاتح جداً للشريط
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        
        // إضافة ظل خفيف للشريط من الأعلى
        messageInputView.layer.shadowColor = UIColor.black.cgColor
        messageInputView.layer.shadowOpacity = 0.05
        messageInputView.layer.shadowOffset = CGSize(width: 0, height: -2)
        messageInputView.layer.shadowRadius = 4
        
        view.addSubview(messageInputView)
        
        // زر المرفقات
        attachButton.setImage(UIImage(systemName: "plus"), for: .normal)
        attachButton.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.addTarget(self, action: #selector(didTapAttach), for: .touchUpInside)
        messageInputView.addSubview(attachButton)
        
        // حقل النص
        messageTextField.placeholder = "Type a message..."
        messageTextField.borderStyle = .none
        messageTextField.backgroundColor = .white
        messageTextField.layer.cornerRadius = 20
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.borderColor = UIColor.systemGray5.cgColor
        
        // مسافة بادئة داخل الحقل
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 40))
        messageTextField.leftView = paddingView
        messageTextField.leftViewMode = .always
        
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.delegate = self
        messageInputView.addSubview(messageTextField)
        
        // زر الإرسال
        let sendIcon = UIImage(systemName: "paperplane.fill")
        sendButton.setImage(sendIcon, for: .normal)
        sendButton.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        messageInputView.addSubview(sendButton)
        
        // 🔥 إصلاح القيود: تثبيت الشريط في أسفل الـ View
        bottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint, // تفعيل القيد السفلي
            messageInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80), // زيادة الارتفاع قليلاً
            
            attachButton.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 12),
            // نرفع الأزرار قليلاً للأعلى لتفادي الـ Home Indicator
            attachButton.topAnchor.constraint(equalTo: messageInputView.topAnchor, constant: 15),
            attachButton.widthAnchor.constraint(equalToConstant: 30),
            attachButton.heightAnchor.constraint(equalToConstant: 30),
            
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
    
    // MARK: - Actions & Logic
    
    @objc private func didTapAttach() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentImagePicker(source: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo & Video Library", style: .default, handler: { _ in
            self.presentImagePicker(source: .photoLibrary)
        }))
        
        // 🔥 خيار الملفات
        alert.addAction(UIAlertAction(title: "Document / File", style: .default, handler: { _ in
            self.presentDocumentPicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // --- Image Picker ---
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.5) {
            uploadFileToFirebase(data: data, folder: "chat_images", type: "image/jpg")
        }
    }
    
    // --- Document Picker ---
    private func presentDocumentPicker() {
        let supportedTypes: [UTType] = [UTType.pdf, UTType.text, UTType.image]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // نحتاج لتحويل الملف إلى Data لرفعه
        do {
            let data = try Data(contentsOf: url)
            uploadFileToFirebase(data: data, folder: "chat_files", type: "application/pdf") // يمكن تحسين نوع الملف لاحقاً
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    // --- Upload Logic ---
    private func uploadFileToFirebase(data: Data, folder: String, type: String) {
        let fileName = UUID().uuidString
        let ref = storage.reference().child("\(folder)/\(fileName)")
        
        let hud = UIAlertController(title: "Sending...", message: nil, preferredStyle: .alert)
        present(hud, animated: true)
        
        ref.putData(data, metadata: nil) { _, error in
            hud.dismiss(animated: true)
            if let error = error {
                print("Error uploading: \(error.localizedDescription)")
                return
            }
            ref.downloadURL { url, _ in
                guard let downloadURL = url?.absoluteString else { return }
                self.sendMessage(text: nil, imageURL: downloadURL)
            }
        }
    }
    
    @objc private func didTapSend() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        sendMessage(text: text, imageURL: nil)
        messageTextField.text = ""
    }
    
    private func sendMessage(text: String?, imageURL: String?) {
        guard let currentUid = Auth.auth().currentUser?.uid, let otherUid = otherUser?.id else { return }
        let chatId = conversationId ?? UUID().uuidString
        self.conversationId = chatId
        
        let data: [String: Any] = [
            "senderId": currentUid,
            "receiverId": otherUid,
            "text": text ?? "",
            "imageURL": imageURL ?? "",
            "timestamp": Timestamp(date: Date()),
            "isRead": false,
            "participants": [currentUid, otherUid]
        ]
        
        db.collection("conversations").document(chatId).collection("messages").addDocument(data: data)
        
        let msgPreview = (imageURL != nil && !imageURL!.isEmpty) ? "📎 Attachment" : (text ?? "")
        db.collection("conversations").document(chatId).setData([
            "lastMessage": msgPreview,
            "updatedAt": Timestamp(date: Date()),
            "participants": [currentUid, otherUid]
        ], merge: true)
    }
    
    private func fetchMessages() {
        guard let chatId = conversationId else { return }
        db.collection("conversations").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { doc -> Message? in
                    let d = doc.data()
                    return Message(
                        id: doc.documentID,
                        senderId: d["senderId"] as? String ?? "",
                        receiverId: d["receiverId"] as? String ?? "",
                        text: d["text"] as? String,
                        imageURL: d["imageURL"] as? String,
                        timestamp: (d["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        isRead: d["isRead"] as? Bool ?? false
                    )
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !self.messages.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = keyboardFrame.cgRectValue.height
            // نحرك الشريط للأعلى بمقدار ارتفاع الكيبورد
            bottomConstraint.constant = -height
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
            if !messages.isEmpty { tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true) }
        }
    }
    
    @objc private func keyboardWillHide() {
        // نعيد الشريط للأسفل (الوضع الطبيعي)
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}

extension SimpleChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as! MessageCell
        let currentUid = Auth.auth().currentUser?.uid ?? ""
        cell.configure(with: messages[indexPath.row], currentUserId: currentUid)
        return cell
    }
}
