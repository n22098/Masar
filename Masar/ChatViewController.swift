//
//  ChatViewController.swift
//  Masar
//
//  Created by BP-36-212-19 on 07/12/2025.
//

import UIKit

final class ChatViewController: UIViewController,
                               UITextFieldDelegate,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {


    private let user: User
    private var messages: [Message]
    private var inputBottomConstraint: NSLayoutConstraint!
    private var currentUserId: String {
        AuthService.shared.currentUserId ?? ""
    }




    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleStack = UIStackView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let inputContainer = UIView()
    private let attachButton = UIButton(type: .system)
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)


    init(user: User, messages: [Message]) {
        self.user = user
        self.messages = messages
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textField.becomeFirstResponder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupTableView()
        setupInputBar()
        scrollToBottom(animated: false)
        
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


// keyboard - inpout
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

//generakl layout
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1.0)
        view.addSubview(headerView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        headerView.addSubview(backButton)
        

        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.text = user.profileImageUrl
        avatarLabel.font = UIFont.systemFont(ofSize: 32)
        
        headerView.addSubview(avatarLabel)

        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 2
        headerView.addSubview(titleStack)
        

        nameLabel.text = user.name
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
         

        subtitleLabel.text = "@\(user.username)"
        subtitleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)

        
        
        titleStack.addArrangedSubview(nameLabel)
        titleStack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 72),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            avatarLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            avatarLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            
            
            titleStack.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8),
            titleStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleStack.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16)
        ])
    }

   //sets table spacing and view
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        view.addSubview(tableView)
        tableView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
   

    private func setupInputBar() {
        
        
        textField.returnKeyType = .send

        textField.delegate = self
        textField.isUserInteractionEnabled = true
        //keyboard;
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusTextField))
        tap.cancelsTouchesInView = false
        inputContainer.addGestureRecognizer(tap)

        inputContainer.isUserInteractionEnabled = true

        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = .white
        inputContainer.layer.borderColor = UIColor.systemGray4.cgColor
        inputContainer.layer.borderWidth = 1
        view.addSubview(inputContainer)

        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachButton.tintColor = .systemGray2
        inputContainer.addSubview(attachButton)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Message"
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        inputContainer.addSubview(textField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        sendButton.setTitleColor(UIColor(red: 112/255, green: 79/255, blue: 217/255, alpha: 1), for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        inputContainer.addSubview(sendButton)

        inputBottomConstraint = inputContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        )
        inputBottomConstraint.isActive = true
        attachButton.addTarget(
            self,
            action: #selector(didTapAttach),
            for: .touchUpInside
        )


        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 52),

            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor),

            attachButton.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            attachButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 24),
            attachButton.heightAnchor.constraint(equalToConstant: 24),
            

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),

            textField.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

//make it so enter key sends message
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func focusTextField() {
        textField.becomeFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }



    //send keyboard input to chat
    @objc private func didTapSend() {
        guard
            let text = textField.text,
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !currentUserId.isEmpty
        else {
            return
        }

        ChatService.shared.sendMessage(
            text: text,
            from: currentUserId,
            to: user.id
        )

        textField.text = nil
    }


    private func scrollToBottom(animated: Bool) {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }



//keyboard
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
            }
        )
    }

}

 //delegates and funcs
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.reuseIdentifier,
            for: indexPath
        ) as! MessageCell
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
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        guard !currentUserId.isEmpty else { return }

        ChatService.shared.sendImageUsingCloudinary(
            image: image,
            from: currentUserId,
            to: user.id
        )
    }



    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.delegate = self
        present(picker, animated: true)
    }
    @objc private func didTapAttach() {
        let alert = UIAlertController(
            title: "Attachments",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.openPhotoLibrary()
            }
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }


}
