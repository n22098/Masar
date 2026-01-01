import UIKit
import PhotosUI

class ChatViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var inputBottomConstraint: NSLayoutConstraint!
    
    var conversation: Conversation!
    var currentUserId = ""
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
    }
    
    func setupUI() {
        if let conversation = conversation {
            let isSeeker = conversation.seekerId == currentUserId
            title = isSeeker ? conversation.providerName : conversation.seekerName
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        inputTextView.layer.cornerRadius = 15
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.borderColor = UIColor.systemGray5.cgColor
        inputTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func loadMessages() {
        guard let conversation = conversation else { return }
        FirebaseManager.shared.getMessages(bookingId: conversation.bookingId) { [weak self] msgs in
            self?.messages = msgs
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.scrollToBottom()
            }
            if let userId = self?.currentUserId {
                FirebaseManager.shared.markRead(bookingId: conversation.bookingId, userId: userId)
            }
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        guard let text = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        guard let conversation = conversation else { return }
        
        let isSeeker = conversation.seekerId == currentUserId
        let receiverId = isSeeker ? conversation.providerId : conversation.seekerId
        let receiverName = isSeeker ? conversation.providerName : conversation.seekerName
        let senderName = isSeeker ? conversation.seekerName : conversation.providerName
        
        FirebaseManager.shared.sendTextMessage(
            bookingId: conversation.bookingId,
            senderId: currentUserId,
            senderName: senderName,
            receiverId: receiverId,
            receiverName: receiverName,
            text: text
        ) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.inputTextView.text = ""
                    self?.textViewDidChange(self!.inputTextView)
                }
            }
        }
    }
    
    @IBAction func attachTapped(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        inputBottomConstraint.constant = frame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom()
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        inputBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollToBottom() {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.async {
            let index = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: index, at: .bottom, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let msg = messages[indexPath.item]
        let isSent = msg.senderId == currentUserId
        
        if isSent {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentCell", for: indexPath) as! SentMessageCell
            cell.configure(with: msg)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReceivedCell", for: indexPath) as! ReceivedMessageCell
            cell.configure(with: msg)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let msg = messages[indexPath.item]
        let text = msg.text ?? ""
        
        let maxWidth = collectionView.frame.width * 0.7
        let font = UIFont.systemFont(ofSize: 16)
        let textHeight = text.heightWithConstrainedWidth(width: maxWidth - 24, font: font)
        let totalHeight = textHeight + 60
        
        return CGSize(width: collectionView.frame.width, height: max(totalHeight, 80))
    }
}

// MARK: - PHPicker Delegate
extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self, let image = object as? UIImage, let conversation = self.conversation else { return }
            
            let isSeeker = conversation.seekerId == self.currentUserId
            let receiverId = isSeeker ? conversation.providerId : conversation.seekerId
            let receiverName = isSeeker ? conversation.providerName : conversation.seekerName
            let senderName = isSeeker ? conversation.seekerName : conversation.providerName
            
            FirebaseManager.shared.sendImage(
                bookingId: conversation.bookingId,
                senderId: self.currentUserId,
                senderName: senderName,
                receiverId: receiverId,
                receiverName: receiverName,
                image: image
            ) { success in
                print("Image sent: \(success)")
            }
        }
    }
}

// MARK: - TextView Delegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText
        sendButton.tintColor = hasText ? .systemBlue : .systemGray
    }
}

// MARK: - String Extension
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
