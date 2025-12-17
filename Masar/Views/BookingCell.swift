import UIKit

class BookingCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    
    // MARK: - Properties
    var onBookingTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bookButton.addTarget(self, action: #selector(bookingButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Container view
        containerView?.layer.cornerRadius = 12
        containerView?.layer.shadowColor = UIColor.black.cgColor
        containerView?.layer.shadowOpacity = 0.1
        containerView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView?.layer.shadowRadius = 4
        containerView?.backgroundColor = .white
        
        // Image view
        serviceImageView?.layer.cornerRadius = 8
        serviceImageView?.clipsToBounds = true
        serviceImageView?.contentMode = .scaleAspectFill
        
        // Labels
        serviceNameLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        serviceNameLabel?.textColor = .black
        
        servicePriceLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        servicePriceLabel?.textColor = .darkGray
        
        // Button
        bookButton?.layer.cornerRadius = 8
        bookButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    // MARK: - Actions
    @objc private func bookingButtonTapped() {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.bookButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.bookButton.transform = .identity
            }
        }
        
        onBookingTapped?()
    }
    
    // MARK: - Configure
    func configure(name: String, price: String, imageName: String?, buttonColor: UIColor) {
        serviceNameLabel?.text = name
        servicePriceLabel?.text = price
        
        if let imageName = imageName, let image = UIImage(named: imageName) {
            serviceImageView?.image = image
        } else {
            serviceImageView?.image = UIImage(systemName: "photo")
            serviceImageView?.tintColor = .lightGray
        }
        
        bookButton?.setTitleColor(buttonColor, for: .normal)
        bookButton?.layer.borderWidth = 1.5
        bookButton?.layer.borderColor = buttonColor.cgColor
    }
}
