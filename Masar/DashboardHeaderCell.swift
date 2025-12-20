import UIKit

class DashboardHeaderCell: UITableViewCell {
    
    private let containerView = UIView()
    private let avatarView = UIView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let companyLabel = UILabel()
    private let ratingLabel = UILabel()
    private let bookingsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarView.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.2)
        avatarView.layer.cornerRadius = 35
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let avatarIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        avatarIcon.tintColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        avatarIcon.contentMode = .scaleAspectFit
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        roleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        roleLabel.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        companyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        companyLabel.textColor = .gray
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bookingsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        bookingsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        avatarView.addSubview(avatarIcon)
        containerView.addSubview(nameLabel)
        containerView.addSubview(roleLabel)
        containerView.addSubview(companyLabel)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(bookingsLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 70),
            avatarView.heightAnchor.constraint(equalToConstant: 70),
            
            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 35),
            avatarIcon.heightAnchor.constraint(equalToConstant: 35),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            companyLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 2),
            companyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            ratingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            bookingsLabel.topAnchor.constraint(equalTo: ratingLabel.topAnchor),
            bookingsLabel.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 24)
        ])
    }
    
    func configure(name: String, role: String, company: String, rating: Double, totalBookings: Int) {
        nameLabel.text = name
        roleLabel.text = role
        companyLabel.text = company
        ratingLabel.text = "⭐ \(String(format: "%.1f", rating))"
        bookingsLabel.text = "📅 \(totalBookings) bookings"
    }
}
