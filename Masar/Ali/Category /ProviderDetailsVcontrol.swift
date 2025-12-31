import UIKit
import FirebaseFirestore

class ProviderDetailsVcontrol: UIViewController {

    // MARK: - Properties
    var providerID: String = ""
    var providerName: String = ""
    var providerPhone: String = ""
    var providerEmail: String = ""
    var categoryName: String = ""
    
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        title = "Provider Details"
        
        setupNavigationBar()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupUI() {
        // ScrollView setup
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
        
        // Profile Card
        let profileCard = createProfileCard()
        contentView.addSubview(profileCard)
        
        // Info Section
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
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Profile Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "person.circle.fill")
        iconView.tintColor = brandColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Name Label
        let nameLabel = UILabel()
        nameLabel.text = providerName
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Category Badge
        let categoryBadge = UIView()
        categoryBadge.backgroundColor = brandColor.withAlphaComponent(0.1)
        categoryBadge.layer.cornerRadius = 12
        categoryBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let categoryLabel = UILabel()
        categoryLabel.text = categoryName
        categoryLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        categoryLabel.textColor = brandColor
        categoryLabel.textAlignment = .center
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryBadge.addSubview(categoryLabel)
        
        card.addSubview(iconView)
        card.addSubview(nameLabel)
        card.addSubview(categoryBadge)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 200),
            
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            categoryBadge.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            categoryBadge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            categoryBadge.heightAnchor.constraint(equalToConstant: 32),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryBadge.topAnchor, constant: 6),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryBadge.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryBadge.trailingAnchor, constant: -16),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: -6)
        ])
        
        return card
    }
    
    private func createInfoSection() -> UIView {
        let section = UIView()
        section.translatesAutoresizingMaskIntoConstraints = false
        
        // Section Title
        let titleLabel = UILabel()
        titleLabel.text = "Contact Information"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Info Card
        let infoCard = UIView()
        infoCard.backgroundColor = .white
        infoCard.layer.cornerRadius = 16
        infoCard.layer.shadowColor = UIColor.black.cgColor
        infoCard.layer.shadowOpacity = 0.05
        infoCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoCard.layer.shadowRadius = 8
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Phone Row
        let phoneRow = createInfoRow(icon: "phone.fill", title: "Phone", value: providerPhone)
        
        // Email Row
        let emailRow = createInfoRow(icon: "envelope.fill", title: "Email", value: providerEmail)
        
        // ID Row
        let idRow = createInfoRow(icon: "person.text.rectangle.fill", title: "Provider ID", value: providerID)
        
        // Separator lines
        let separator1 = createSeparator()
        let separator2 = createSeparator()
        
        infoCard.addSubview(phoneRow)
        infoCard.addSubview(separator1)
        infoCard.addSubview(emailRow)
        infoCard.addSubview(separator2)
        infoCard.addSubview(idRow)
        
        section.addSubview(titleLabel)
        section.addSubview(infoCard)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: section.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 4),
            
            infoCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            infoCard.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            infoCard.bottomAnchor.constraint(equalTo: section.bottomAnchor),
            
            phoneRow.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            phoneRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            phoneRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            phoneRow.heightAnchor.constraint(equalToConstant: 50),
            
            separator1.topAnchor.constraint(equalTo: phoneRow.bottomAnchor, constant: 8),
            separator1.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            separator1.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            separator1.heightAnchor.constraint(equalToConstant: 1),
            
            emailRow.topAnchor.constraint(equalTo: separator1.bottomAnchor, constant: 8),
            emailRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            emailRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            emailRow.heightAnchor.constraint(equalToConstant: 50),
            
            separator2.topAnchor.constraint(equalTo: emailRow.bottomAnchor, constant: 8),
            separator2.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            separator2.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            separator2.heightAnchor.constraint(equalToConstant: 1),
            
            idRow.topAnchor.constraint(equalTo: separator2.bottomAnchor, constant: 8),
            idRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            idRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            idRow.heightAnchor.constraint(equalToConstant: 50),
            idRow.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -16)
        ])
        
        return section
    }
    
    private func createInfoRow(icon: String, title: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = brandColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .black
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(iconView)
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
        
        return row
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }
}
