import UIKit
import PhotosUI
import UniformTypeIdentifiers
import QuickLook
import AVFoundation

// MARK: - Models
struct PortfolioSection {
    let title: String
    let content: String?
    let type: SectionType
}

enum SectionType {
    case text
    case button
}

enum PortfolioMediaType: String, Codable {
    case image
    case document
    case video
}

struct PortfolioMedia: Codable {
    let id: String
    let type: PortfolioMediaType
    let fileName: String
    let name: String
    
    var url: URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents?.appendingPathComponent(fileName)
    }
}

class ProviderPortfolioTableViewController: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    var providerData: ServiceProviderModel? // Assuming this model exists in your project
    var uploadedMedia: [PortfolioMedia] = []
    
    // MARK: - FIX: Store the URL to be previewed here
    private var currentPreviewURL: URL?
    
    private let storageKey = "PermanentPortfolioStorage"
    private let portfolioSections = [
        PortfolioSection(
            title: "About me",
            content: "I'm a passionate developer with 5+ years of experience in web and mobile development. I specialize in creating beautiful and functional iOS applications.",
            type: .text
        ),
        PortfolioSection(
            title: "Skills",
            content: "Swift • iOS Development • UIKit • SwiftUI • Firebase • REST APIs • Git",
            type: .text
        ),
        PortfolioSection(
            title: "Upload Portfolio",
            content: nil,
            type: .button
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedMedia()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Persistence Logic
    private func saveToMemory() {
        if let encoded = try? JSONEncoder().encode(uploadedMedia) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadSavedMedia() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([PortfolioMedia].self, from: data) {
            self.uploadedMedia = decoded
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Portfolio"
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 20, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.register(PortfolioTextCell.self, forCellReuseIdentifier: "PortfolioTextCell")
        tableView.register(PortfolioButtonsCell.self, forCellReuseIdentifier: "PortfolioButtonsCell")
        tableView.register(PortfolioMediaCell.self, forCellReuseIdentifier: "PortfolioMediaCell")
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolioSections.count + uploadedMedia.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < portfolioSections.count {
            let section = portfolioSections[indexPath.row]
            
            switch section.type {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioTextCell", for: indexPath) as! PortfolioTextCell
                cell.configure(title: section.title, content: section.content ?? "")
                return cell
                
            case .button:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioButtonsCell", for: indexPath) as! PortfolioButtonsCell
                cell.configure(title: section.title)
                cell.onImageTapped = { [weak self] in
                    self?.pickImage()
                }
                cell.onDocumentTapped = { [weak self] in
                    self?.pickDocument()
                }
                cell.onVideoTapped = { [weak self] in
                    self?.pickVideo()
                }
                return cell
            }
        } else {
            let mediaIndex = indexPath.row - portfolioSections.count
            let media = uploadedMedia[mediaIndex]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioMediaCell", for: indexPath) as! PortfolioMediaCell
            cell.configure(with: media, brandColor: brandColor)
            cell.onDeleteTapped = { [weak self] in
                self?.deleteMedia(at: mediaIndex)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row >= portfolioSections.count {
            let mediaIndex = indexPath.row - portfolioSections.count
            let media = uploadedMedia[mediaIndex]
            
            // FIX: Set the variable before calling preview
            self.currentPreviewURL = media.url
            previewMedia(media)
        }
    }
    
    // MARK: - Upload Logic
    private func showUploadOptions() {
        let alert = UIAlertController(title: "Upload Media", message: "Choose media type", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "📷 Photo", style: .default) { [weak self] _ in
            self?.pickImage()
        })
        
        alert.addAction(UIAlertAction(title: "📄 Document", style: .default) { [weak self] _ in
            self?.pickDocument()
        })
        
        alert.addAction(UIAlertAction(title: "🎥 Video", style: .default) { [weak self] _ in
            self?.pickVideo()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func pickImage() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func pickVideo() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func pickDocument() {
        let types: [UTType] = [.pdf, .png, .jpeg, .heic, .plainText, .rtf, .data]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        present(picker, animated: true)
    }
    
    private func saveFile(from url: URL, type: PortfolioMediaType) {
        let fileName = "\(UUID().uuidString)_\(url.lastPathComponent)"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            let accessed = url.startAccessingSecurityScopedResource()
            
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            
            try FileManager.default.copyItem(at: url, to: destURL)
            
            let media = PortfolioMedia(
                id: UUID().uuidString,
                type: type,
                fileName: fileName,
                name: url.lastPathComponent
            )
            
            uploadedMedia.append(media)
            saveToMemory()
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.showSuccessMessage(message: "✅ File uploaded successfully!")
            }
            
        } catch {
            print("Error saving file: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.showErrorMessage(message: "Failed to upload file: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteMedia(at index: Int) {
        let media = uploadedMedia[index]
        
        let alert = UIAlertController(
            title: "Delete File",
            message: "Are you sure you want to delete '\(media.name)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            if let url = media.url {
                try? FileManager.default.removeItem(at: url)
            }
            
            self?.uploadedMedia.remove(at: index)
            self?.saveToMemory()
            self?.tableView.reloadData()
            
            self?.showSuccessMessage(message: "🗑️ File deleted")
        })
        
        present(alert, animated: true)
    }
    
    private func previewMedia(_ media: PortfolioMedia) {
        guard let url = media.url, FileManager.default.fileExists(atPath: url.path) else {
            showErrorMessage(message: "File not found")
            return
        }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = 0
        navigationController?.pushViewController(previewController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showSuccessMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showErrorMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ProviderPortfolioTableViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    DispatchQueue.main.async {
                        self?.showErrorMessage(message: "Failed to load image")
                    }
                    return
                }
                guard let url = url else { return }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self?.saveFile(from: tempURL, type: .image)
                    }
                } catch {
                    print("Error copying file: \(error)")
                }
            }
        } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                if let error = error {
                    print("Error loading video: \(error)")
                    DispatchQueue.main.async {
                        self?.showErrorMessage(message: "Failed to load video")
                    }
                    return
                }
                guard let url = url else { return }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: url, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self?.saveFile(from: tempURL, type: .video)
                    }
                } catch {
                    print("Error copying file: \(error)")
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension ProviderPortfolioTableViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        saveFile(from: url, type: .document)
    }
}
// MARK: - QLPreviewControllerDataSource
extension ProviderPortfolioTableViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // FIX: Cast currentPreviewURL to NSURL explicitly.
        // This ensures both sides of '??' are NSURL, resolving the ambiguity.
        return (currentPreviewURL as NSURL?) ?? NSURL()
    }
}

// MARK: - Custom Cells
// (Kept exactly the same as your code below)

class PortfolioTextCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}

class PortfolioButtonsCell: UITableViewCell {
    var onImageTapped: (() -> Void)?
    var onDocumentTapped: (() -> Void)?
    var onVideoTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var imageButton: UIButton = {
        let button = createUploadButton(icon: "📷", title: "Images")
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var documentButton: UIButton = {
        let button = createUploadButton(icon: "📄", title: "Docs")
        button.addTarget(self, action: #selector(documentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoButton: UIButton = {
        let button = createUploadButton(icon: "🎥", title: "Videos")
        button.addTarget(self, action: #selector(videoTapped), for: .touchUpInside)
        return button
    }()
    
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(imageButton)
        stackView.addArrangedSubview(documentButton)
        stackView.addArrangedSubview(videoButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func createUploadButton(icon: String, title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.15)
        iconContainer.layer.cornerRadius = 20
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if title == "Images" {
            iconImageView.image = UIImage(systemName: "photo.fill")
        } else if title == "Docs" {
            iconImageView.image = UIImage(systemName: "doc.text.fill")
        } else if title == "Videos" {
            iconImageView.image = UIImage(systemName: "video.fill")
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        button.addSubview(iconContainer)
        button.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconContainer.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -10)
        ])
        
        return button
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    @objc private func imageTapped() {
        onImageTapped?()
    }
    
    @objc private func documentTapped() {
        onDocumentTapped?()
    }
    
    @objc private func videoTapped() {
        onVideoTapped?()
    }
}

class PortfolioMediaCell: UITableViewCell {
    var onDeleteTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(deleteButton)
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 48),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12),
            
            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            typeLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with media: PortfolioMedia, brandColor: UIColor) {
        nameLabel.text = media.name
        
        switch media.type {
        case .image:
            iconImageView.image = UIImage(systemName: "photo")
            typeLabel.text = "Image"
            iconBackgroundView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            iconImageView.tintColor = .systemBlue
        case .document:
            iconImageView.image = UIImage(systemName: "doc.fill")
            typeLabel.text = "Document"
            iconBackgroundView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            iconImageView.tintColor = .systemOrange
        case .video:
            iconImageView.image = UIImage(systemName: "video.fill")
            typeLabel.text = "Video"
            iconBackgroundView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
            iconImageView.tintColor = .systemPurple
        }
    }
    
    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
