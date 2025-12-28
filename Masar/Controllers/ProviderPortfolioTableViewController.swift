import UIKit
import PhotosUI
import UniformTypeIdentifiers
import QuickLook

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
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        return documents?.appendingPathComponent(fileName)
    }
}

// MARK: - View Controller

class ProviderPortfolioTableViewController: UITableViewController {

    // MARK: Properties

    let brandColor = UIColor(
        red: 0.35,
        green: 0.34,
        blue: 0.91,
        alpha: 1.0
    )

    var providerData: ServiceProviderModel?
    var uploadedMedia: [PortfolioMedia] = []

    /// Set to true when navigating from Seeker/Search
    var isReadOnlyMode: Bool = false

    private var currentPreviewURL: URL?

    // MARK: Storage Key

    private var storageKey: String {
        if let id = providerData?.id, !id.isEmpty {
            return "Portfolio_\(id)"
        }
        return "DefaultPortfolioStorage"
    }

    // MARK: Portfolio Sections

    private var portfolioSections: [PortfolioSection] {
        var sections: [PortfolioSection] = []

        if let provider = providerData {
            sections.append(
                PortfolioSection(
                    title: "About me",
                    content: provider.aboutMe,
                    type: .text
                )
            )

            sections.append(
                PortfolioSection(
                    title: "Experience",
                    content: "\(provider.experience) | \(provider.completedProjects) Projects Completed",
                    type: .text
                )
            )

            sections.append(
                PortfolioSection(
                    title: "Skills",
                    content: provider.skills.joined(separator: " • "),
                    type: .text
                )
            )
        } else {
            sections.append(
                PortfolioSection(
                    title: "About me",
                    content: "I'm a passionate developer with 5+ years of experience.",
                    type: .text
                )
            )

            sections.append(
                PortfolioSection(
                    title: "Skills",
                    content: "Swift • UIKit • SwiftUI",
                    type: .text
                )
            )
        }

        // Only show upload buttons if not read-only
        if !isReadOnlyMode {
            sections.append(
                PortfolioSection(
                    title: "Upload Portfolio",
                    content: nil,
                    type: .button
                )
            )
        }

        return sections
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedMedia()
    }

    // MARK: Persistence

    private func loadSavedMedia() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([PortfolioMedia].self, from: data) {
            uploadedMedia = decoded
        } else if let data = UserDefaults.standard.data(forKey: "DefaultPortfolioStorage"),
                  let decoded = try? JSONDecoder().decode([PortfolioMedia].self, from: data) {
            uploadedMedia = decoded
        }

        tableView.reloadData()
    }

    private func saveToMemory() {
        if let encoded = try? JSONEncoder().encode(uploadedMedia) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            UserDefaults.standard.set(encoded, forKey: "DefaultPortfolioStorage")
        }
    }

    // MARK: UI Setup

    private func setupUI() {
        title = providerData != nil
            ? "\(providerData!.name)'s Portfolio"
            : "Portfolio"

        tableView.backgroundColor = UIColor(
            red: 248 / 255,
            green: 248 / 255,
            blue: 252 / 255,
            alpha: 1.0
        )

        tableView.separatorStyle = .none

        tableView.register(
            PortfolioTextCell.self,
            forCellReuseIdentifier: "PortfolioTextCell"
        )

        tableView.register(
            PortfolioButtonsCell.self,
            forCellReuseIdentifier: "PortfolioButtonsCell"
        )

        tableView.register(
            PortfolioMediaCell.self,
            forCellReuseIdentifier: "PortfolioMediaCell"
        )
    }

    // MARK: Table View Data Source

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        portfolioSections.count + uploadedMedia.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        if indexPath.row < portfolioSections.count {
            let section = portfolioSections[indexPath.row]

            if section.type == .text {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PortfolioTextCell",
                    for: indexPath
                ) as! PortfolioTextCell

                cell.configure(
                    title: section.title,
                    content: section.content ?? ""
                )

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PortfolioButtonsCell",
                    for: indexPath
                ) as! PortfolioButtonsCell

                cell.onImageTapped = { [weak self] in self?.pickImage() }
                cell.onDocumentTapped = { [weak self] in self?.pickDocument() }
                cell.onVideoTapped = { [weak self] in self?.pickVideo() }

                return cell
            }
        }

        let mediaIndex = indexPath.row - portfolioSections.count
        let media = uploadedMedia[mediaIndex]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PortfolioMediaCell",
            for: indexPath
        ) as! PortfolioMediaCell

        cell.configure(
            with: media,
            brandColor: brandColor,
            isReadOnly: isReadOnlyMode
        )

        cell.onDeleteTapped = { [weak self] in
            self?.deleteMedia(at: mediaIndex)
        }

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if indexPath.row >= portfolioSections.count {
            let media = uploadedMedia[indexPath.row - portfolioSections.count]
            previewMedia(media)
        }
    }

    // MARK: Media Preview

    private func previewMedia(_ media: PortfolioMedia) {
        guard let url = media.url else { return }

        currentPreviewURL = url

        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true)
    }

    // MARK: Media Pickers

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
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .plainText]
        )
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: Media Storage

    func saveFile(from url: URL, type: PortfolioMediaType) {
        let fileName = "\(UUID().uuidString)_\(url.lastPathComponent)"

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let destURL = documentsURL.appendingPathComponent(fileName)

        do {
            try FileManager.default.copyItem(at: url, to: destURL)

            let media = PortfolioMedia(
                id: UUID().uuidString,
                type: type,
                fileName: fileName,
                name: url.lastPathComponent
            )

            uploadedMedia.append(media)
            saveToMemory()

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error saving file")
        }
    }

    private func deleteMedia(at index: Int) {
        let media = uploadedMedia[index]

        if let url = media.url {
            try? FileManager.default.removeItem(at: url)
        }

        uploadedMedia.remove(at: index)
        saveToMemory()
        tableView.reloadData()
    }
}

// MARK: - Delegates

extension ProviderPortfolioTableViewController:
    PHPickerViewControllerDelegate,
    UIDocumentPickerDelegate,
    QLPreviewControllerDataSource {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        // Determine if it's a video or image
        let isVideo = result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
        let typeIdentifier = isVideo ? UTType.movie.identifier : UTType.item.identifier
        let mediaType: PortfolioMediaType = isVideo ? .video : .image

        result.itemProvider.loadFileRepresentation(
            forTypeIdentifier: typeIdentifier
        ) { url, _ in
            if let url = url {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(url.lastPathComponent)

                try? FileManager.default.copyItem(at: url, to: tempURL)

                DispatchQueue.main.async {
                    self.saveFile(from: tempURL, type: mediaType)
                }
            }
        }
    }

    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        if let url = urls.first {
            saveFile(from: url, type: .document)
        }
    }

    func numberOfPreviewItems(
        in controller: QLPreviewController
    ) -> Int {
        1
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {
        (currentPreviewURL as NSURL?) ?? NSURL()
    }
}

// MARK: - Cells

class PortfolioTextCell: UITableViewCell {

    private let container = UIView()
    private let titleLbl = UILabel()
    private let contentLbl = UILabel()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)

        titleLbl.font = .boldSystemFont(ofSize: 18)
        contentLbl.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLbl, contentLbl])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }

    func configure(title: String, content: String) {
        titleLbl.text = title
        contentLbl.text = content
    }
}

class PortfolioButtonsCell: UITableViewCell {

    var onImageTapped: (() -> Void)?
    var onDocumentTapped: (() -> Void)?
    var onVideoTapped: (() -> Void)?

    private let container = UIView()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)

        let titleLabel = UILabel()
        titleLabel.text = "Upload Portfolio"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)

        let b1 = createBtn(t: "Images", i: "photo.fill")
        let b2 = createBtn(t: "Docs", i: "doc.fill")
        let b3 = createBtn(t: "Videos", i: "video.fill")

        b1.addTarget(self, action: #selector(img), for: .touchUpInside)
        b2.addTarget(self, action: #selector(doc), for: .touchUpInside)
        b3.addTarget(self, action: #selector(vid), for: .touchUpInside)

        [b1, b2, b3].forEach { stack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            stack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func createBtn(t: String, i: String) -> UIButton {
        let b = UIButton(type: .system)
        
        // Create vertical stack for icon and text
        let iconView = UIImageView(image: UIImage(systemName: i))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = t
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        b.addSubview(stack)
        
        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            
            stack.centerXAnchor.constraint(equalTo: b.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: b.centerYAnchor)
        ])
        
        b.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        b.layer.borderWidth = 0
        b.layer.cornerRadius = 12
        
        return b
    }

    @objc func img() { onImageTapped?() }
    @objc func doc() { onDocumentTapped?() }
    @objc func vid() { onVideoTapped?() }
}

class PortfolioMediaCell: UITableViewCell {

    var onDeleteTapped: (() -> Void)?

    private let container = UIView()
    private let iconView = UIImageView()
    private let nameLbl = UILabel()
    private let typeLbl = UILabel()
    private let delBtn = UIButton(type: .system)

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.layer.shadowOpacity = 0.06
        container.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)

        // Icon background
        let iconBackground = UIView()
        iconBackground.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iconBackground.layer.cornerRadius = 10
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconBackground.addSubview(iconView)
        container.addSubview(iconBackground)

        // Name label
        nameLbl.font = .systemFont(ofSize: 15, weight: .medium)
        nameLbl.textColor = .black
        nameLbl.translatesAutoresizingMaskIntoConstraints = false

        // Type label
        typeLbl.font = .systemFont(ofSize: 13, weight: .regular)
        typeLbl.textColor = .systemGray
        typeLbl.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [nameLbl, typeLbl])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(textStack)

        // Delete button
        delBtn.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        delBtn.tintColor = .systemRed
        delBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        delBtn.layer.cornerRadius = 18
        delBtn.translatesAutoresizingMaskIntoConstraints = false
        delBtn.addTarget(self, action: #selector(del), for: .touchUpInside)

        container.addSubview(delBtn)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            container.heightAnchor.constraint(equalToConstant: 72),

            iconBackground.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: 48),
            iconBackground.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: delBtn.leadingAnchor, constant: -12),

            delBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            delBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            delBtn.widthAnchor.constraint(equalToConstant: 36),
            delBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func configure(
        with m: PortfolioMedia,
        brandColor: UIColor,
        isReadOnly: Bool
    ) {
        nameLbl.text = m.name
        delBtn.isHidden = isReadOnly
        
        // Set icon and type based on media type
        switch m.type {
        case .image:
            iconView.image = UIImage(systemName: "photo.fill")
            typeLbl.text = "Image"
        case .document:
            iconView.image = UIImage(systemName: "doc.fill")
            typeLbl.text = "Document"
        case .video:
            iconView.image = UIImage(systemName: "video.fill")
            typeLbl.text = "Video"
        }
    }

    @objc func del() {
        onDeleteTapped?()
    }
}

