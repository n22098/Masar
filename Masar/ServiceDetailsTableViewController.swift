import UIKit

class ServiceDetailsTableViewController: UITableViewController {
    
    // MARK: - Received Data
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    
    // MARK: - IBOutlets (اربطهم من الستوري بورد)
    // Section 0 - Provider Info
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var providerRoleLabel: UILabel!
    @IBOutlet weak var providerSkillsLabel: UILabel!
    @IBOutlet weak var providerSolutionsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    // Section 1 - Package Info
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var packageDetailsLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
        
        print("✅ Service Name: \(receivedServiceName ?? "N/A")")
        print("✅ Service Price: \(receivedServicePrice ?? "N/A")")
        print("✅ Service Details: \(receivedServiceDetails ?? "N/A")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "IT Solutions"
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        // Provider image
        providerImageView?.layer.cornerRadius = 30
        providerImageView?.clipsToBounds = true
        providerImageView?.backgroundColor = .systemOrange
        providerImageView?.image = UIImage(systemName: "person.circle.fill")
        providerImageView?.tintColor = .white
        
        // Request button
        requestButton?.layer.cornerRadius = 8
        requestButton?.layer.borderWidth = 1.5
        requestButton?.layer.borderColor = brandColor.cgColor
        requestButton?.setTitleColor(brandColor, for: .normal)
        requestButton?.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureData() {
        // Provider data (ثابتة)
        providerNameLabel?.text = "Sayed Husain"
        providerRoleLabel?.text = "Software Engineer"
        providerSkillsLabel?.text = "HTML, CSS, JS, PHP, MySQL"
        providerSolutionsLabel?.text = "Frontend & backend solutions"
        timeLabel?.text = "Sat-Thu"
        locationLabel?.text = "Online"
        phoneLabel?.text = "36666222"
        
        // Package data (من الشاشة السابقة)
        packageNameLabel?.text = receivedServiceName ?? "Website Starter"
        packagePriceLabel?.text = receivedServicePrice ?? "BHD 85.000"
        packagePriceLabel?.textColor = brandColor
        
        let details = receivedServiceDetails ?? "Responsive pages\nBasic contact form\nFast delivery\nFree minor edits"
        packageDetailsLabel?.text = details
        packageDetailsLabel?.numberOfLines = 0
    }
    
    // MARK: - Actions
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        print("❌ Remove button tapped!")
        
        let alert = UIAlertController(
            title: "Remove Service",
            message: "Are you sure you want to remove '\(receivedServiceName ?? "this service")'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        print("🎯 Request button tapped!")
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        // إظهار Alert للتأكيد
        let alert = UIAlertController(
            title: "Confirm Booking",
            message: "Do you want to request '\(receivedServiceName ?? "this service")'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.confirmBooking()
        })
        
        present(alert, animated: true)
    }
    
    private func confirmBooking() {
        print("✅ Booking confirmed!")
        
        // إظهار رسالة نجاح
        let successAlert = UIAlertController(
            title: "Success! 🎉",
            message: "Your booking request for '\(receivedServiceName ?? "service")' has been sent successfully.",
            preferredStyle: .alert
        )
        
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(successAlert, animated: true)
    }
}
