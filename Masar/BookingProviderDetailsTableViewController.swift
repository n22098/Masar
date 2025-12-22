import UIKit

class BookingProviderDetailsTableViewController: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    var bookingData: BookingModel?
    
    // MARK: - IBOutlets
    @IBOutlet weak var seekerNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusInfoLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Booking Details"
        
        setupNavigationBar()
        setupTableView()
        setupButtons()
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
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    private func setupButtons() {
        // Complete Button
        completeButton?.layer.cornerRadius = 12
        completeButton?.backgroundColor = .systemGreen
        completeButton?.setTitleColor(.white, for: .normal)
        completeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Cancel Button
        cancelButton?.layer.cornerRadius = 12
        cancelButton?.backgroundColor = .systemRed
        cancelButton?.setTitleColor(.white, for: .normal)
        cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    // MARK: - Populate Data
    private func populateData() {
        guard let data = bookingData else { return }
        
        seekerNameLabel?.text = data.seekerName
        emailLabel?.text = data.email
        phoneLabel?.text = data.phoneNumber
        dateLabel?.text = data.date
        serviceNameLabel?.text = data.serviceName
        priceLabel?.text = data.price
        priceLabel?.textColor = brandColor
        instructionsLabel?.text = data.instructions
        descriptionLabel?.text = data.descriptionText
        
        updateUIBasedOnStatus(status: data.status)
    }
    
    private func updateUIBasedOnStatus(status: BookingStatus) {
        switch status {
        case .upcoming:
            completeButton?.isHidden = false
            cancelButton?.isHidden = false
            
            statusInfoLabel?.text = "Booking Info"
            statusInfoLabel?.textColor = .darkGray
            statusInfoLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            
        case .completed:
            completeButton?.isHidden = true
            cancelButton?.isHidden = true
            
            statusInfoLabel?.text = "APPOINTMENT COMPLETED!"
            statusInfoLabel?.textColor = .systemGreen
            statusInfoLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            
        case .canceled:
            completeButton?.isHidden = true
            cancelButton?.isHidden = true
            
            statusInfoLabel?.text = "APPOINTMENT CANCELED!"
            statusInfoLabel?.textColor = .systemRed
            statusInfoLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Customization
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .darkGray
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    // MARK: - Actions
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        let alert = UIAlertController(
            title: "Complete Booking",
            message: "Are you sure you want to mark this booking as completed?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.bookingData?.status = .completed
            if let status = self?.bookingData?.status {
                self?.updateUIBasedOnStatus(status: status)
            }
            
            // Success message
            self?.showSuccessMessage(message: "Booking marked as completed! ✅")
        })
        
        present(alert, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        let alert = UIAlertController(
            title: "Cancel Booking",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.bookingData?.status = .canceled
            if let status = self?.bookingData?.status {
                self?.updateUIBasedOnStatus(status: status)
            }
            
            // Cancellation message
            self?.showSuccessMessage(message: "Booking has been cancelled.")
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showSuccessMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}
