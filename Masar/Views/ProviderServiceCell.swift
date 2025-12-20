import UIKit

class ProviderServiceCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let editButton = UIButton(type: .system)
    
    var onEditTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        nameLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.textColor = .systemGreen
        
        editButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func editTapped() {
        onEditTapped?()
    }
    
    func configure(with service: ServiceModel) {
        nameLabel.text = service.name
        priceLabel.text = "\(service.price) BHD"
    }
}
