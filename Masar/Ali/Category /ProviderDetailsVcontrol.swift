import UIKit
import FirebaseFirestore

class ProviderDetailsVcontrol: UIViewController {

    // MARK: - Properties
    var providerID: String = ""
    var providerName: String = ""
    var providerPhone: String = ""
    var providerEmail: String = ""
    var categoryName: String = ""
    var providerImageURL: String = "" // ✅ Added property to receive the URL
    
    var providerUsername: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.usernameValueLabel.text = self.providerUsername
            }
        }
    }
    
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let usernameValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        title = "Provider Details"
        usernameValueLabel.text = providerUsername
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let profileCard = createProfileCard()
        contentView.addSubview(profileCard)
        let infoSection = createInfoSection()
        contentView.addSubview(infoSection)
        
        NSLayoutConstraint.activate([
            profileCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoSection.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 20),
            infoSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createProfileCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white; card.layer.cornerRadius = 20
        card.layer.shadowOpacity = 0.08; card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup UIImageView for profile picture
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 40 // Make it a circle
        iconView.tintColor = brandColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // ✅ LOGIC TO LOAD IMAGE FROM URL
        if let url = URL(string: providerImageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        iconView.image = image
                    }
                }
            }.resume()
        } else {
            iconView.image = UIImage(systemName: "person.circle.fill")
        }
        
        let nameLabel = UILabel()
        nameLabel.text = providerName; nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center; nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let categoryBadge = UIView()
        categoryBadge.backgroundColor = brandColor.withAlphaComponent(0.1)
        categoryBadge.layer.cornerRadius = 12; categoryBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let categoryLabel = UILabel()
        categoryLabel.text = categoryName; categoryLabel.textColor = brandColor
        categoryLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryBadge.addSubview(categoryLabel)
        [iconView, nameLabel, categoryBadge].forEach { card.addSubview($0) }
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 200),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 80), iconView.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            categoryBadge.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            categoryBadge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            categoryLabel.centerXAnchor.constraint(equalTo: categoryBadge.centerXAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryBadge.centerYAnchor),
            categoryBadge.widthAnchor.constraint(equalTo: categoryLabel.widthAnchor, constant: 32),
            categoryBadge.heightAnchor.constraint(equalToConstant: 32)
        ])
        return card
    }
    
    private func createInfoSection() -> UIView {
        let section = UIView(); section.translatesAutoresizingMaskIntoConstraints = false
        let infoCard = UIView(); infoCard.backgroundColor = .white; infoCard.layer.cornerRadius = 16
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        
        let phoneRow = createInfoRow(icon: "phone.fill", title: "Phone", value: providerPhone)
        let emailRow = createInfoRow(icon: "envelope.fill", title: "Email", value: providerEmail)
        
        let usernameRow = UIView(); usernameRow.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "person.text.rectangle.fill"))
        icon.tintColor = brandColor; icon.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel(); title.text = "Username"; title.textColor = .gray; title.font = .systemFont(ofSize: 14)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        [icon, title, usernameValueLabel].forEach { usernameRow.addSubview($0) }
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: usernameRow.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: usernameRow.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24), icon.heightAnchor.constraint(equalToConstant: 24),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.centerYAnchor.constraint(equalTo: usernameRow.centerYAnchor),
            usernameValueLabel.trailingAnchor.constraint(equalTo: usernameRow.trailingAnchor),
            usernameValueLabel.centerYAnchor.constraint(equalTo: usernameRow.centerYAnchor)
        ])
        
        let sep1 = createSeparator(), sep2 = createSeparator()
        [phoneRow, sep1, emailRow, sep2, usernameRow].forEach { infoCard.addSubview($0) }
        section.addSubview(infoCard)
        
        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: section.topAnchor),
            infoCard.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            infoCard.bottomAnchor.constraint(equalTo: section.bottomAnchor),
            phoneRow.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            phoneRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            phoneRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            phoneRow.heightAnchor.constraint(equalToConstant: 50),
            sep1.topAnchor.constraint(equalTo: phoneRow.bottomAnchor, constant: 8),
            sep1.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            sep1.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            sep1.heightAnchor.constraint(equalToConstant: 1),
            emailRow.topAnchor.constraint(equalTo: sep1.bottomAnchor, constant: 8),
            emailRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            emailRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            emailRow.heightAnchor.constraint(equalToConstant: 50),
            sep2.topAnchor.constraint(equalTo: emailRow.bottomAnchor, constant: 8),
            sep2.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            sep2.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            sep2.heightAnchor.constraint(equalToConstant: 1),
            usernameRow.topAnchor.constraint(equalTo: sep2.bottomAnchor, constant: 8),
            usernameRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            usernameRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            usernameRow.heightAnchor.constraint(equalToConstant: 50),
            usernameRow.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16)
        ])
        return section
    }
    
    private func createInfoRow(icon: String, title: String, value: String) -> UIView {
        let row = UIView(); row.translatesAutoresizingMaskIntoConstraints = false
        let iconV = UIImageView(image: UIImage(systemName: icon))
        iconV.tintColor = brandColor; iconV.translatesAutoresizingMaskIntoConstraints = false
        let titleL = UILabel(); titleL.text = title; titleL.textColor = .gray; titleL.font = .systemFont(ofSize: 14)
        titleL.translatesAutoresizingMaskIntoConstraints = false
        let valueL = UILabel(); valueL.text = value; valueL.font = .boldSystemFont(ofSize: 16)
        valueL.textAlignment = .right; valueL.translatesAutoresizingMaskIntoConstraints = false
        [iconV, titleL, valueL].forEach { row.addSubview($0) }
        NSLayoutConstraint.activate([
            iconV.leadingAnchor.constraint(equalTo: row.leadingAnchor), iconV.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconV.widthAnchor.constraint(equalToConstant: 24), iconV.heightAnchor.constraint(equalToConstant: 24),
            titleL.leadingAnchor.constraint(equalTo: iconV.trailingAnchor, constant: 12), titleL.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueL.trailingAnchor.constraint(equalTo: row.trailingAnchor), valueL.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }
    
    private func createSeparator() -> UIView {
        let sep = UIView(); sep.backgroundColor = .systemGray5
        sep.translatesAutoresizingMaskIntoConstraints = false
        return sep
    }
}
