import UIKit

class BookingHistoryTableViewController: UITableViewController {

    // MARK: - Outlets
    // Remove @IBOutlet - we'll create it programmatically
    // @IBOutlet weak var filterSegment: UISegmentedControl!
    
    // Create segment control programmatically
    private lazy var filterSegment: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Canceled"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    // MARK: - Data
    let allBookings: [BookingModel] = [
        BookingModel(serviceName: "Website Design", providerName: "Sayed Husain", date: "20 Dec 2025", price: "85 BHD", status: .upcoming),
        BookingModel(serviceName: "Math Tutoring", providerName: "Kashmala", date: "22 Dec 2025", price: "20 BHD", status: .upcoming),
        BookingModel(serviceName: "PC Repair", providerName: "Amin", date: "10 Nov 2025", price: "15 BHD", status: .completed),
        BookingModel(serviceName: "Logo Design", providerName: "Osama", date: "01 Nov 2025", price: "30 BHD", status: .canceled),
        BookingModel(serviceName: "Car Wash", providerName: "Quick Clean", date: "05 Dec 2025", price: "5 BHD", status: .completed)
    ]

    var filteredBookings: [BookingModel] = []
    var isAscending: Bool = true
    
    // MARK: - Colors
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IMPORTANT: Set title FIRST before anything
        title = "History"
        
        setupNavigationBar()
        setupUI()
        filterBookings()
        
        // Register custom cell
        tableView.register(ModernBookingHistoryCell.self, forCellReuseIdentifier: "ModernBookingHistoryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterBookings()
        tableView.reloadData()
    }

    // MARK: - Setup Navigation Bar
    func setupNavigationBar() {
        // Disable large titles - keep it compact like Search screen
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Purple navigation bar - SAME as Search screen
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Show "History" title in navigation bar (centered)
        title = "History"
        
        // Logout button (LEFT) - same as Search screen
        let logoutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = .white
        navigationItem.leftBarButtonItem = logoutButton
    }

    // MARK: - Setup UI
    func setupUI() {
        // Table view styling
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        // Setup segment control in purple header area
        setupSegmentHeader()
    }
    
    func setupSegmentHeader() {
        // Create container matching the gray background
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        headerContainer.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0) // Same as tableView background
        
        // Add segment to container
        headerContainer.addSubview(filterSegment)
        
        // Set constraints for segment control - centered like Search screen
        NSLayoutConstraint.activate([
            filterSegment.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            filterSegment.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 13),
            filterSegment.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Set as table header view
        tableView.tableHeaderView = headerContainer
        
        // Style the segment control
        styleSegmentControl(filterSegment)
        
        // Add action
        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func styleSegmentControl(_ segment: UISegmentedControl) {
        // Modern styling - gray background like Search screen
        segment.backgroundColor = UIColor(white: 0.95, alpha: 1)
        segment.selectedSegmentTintColor = .white
        
        // Normal state - gray text
        segment.setTitleTextAttributes([
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        // Selected state - purple text on white background
        segment.setTitleTextAttributes([
            .foregroundColor: brandColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        segment.layer.cornerRadius = 12
        segment.clipsToBounds = true
    }

    // MARK: - Actions
    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    func performLogout() {
        // Clear user session
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
        
        // Navigate to login screen
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Filtering Logic
    @objc func segmentChanged() {
        filterBookings()
        
        // Animate table reload
        UIView.transition(with: tableView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
    }

    func filterBookings() {
        let index = filterSegment.selectedSegmentIndex
        
        switch index {
        case 0: // Upcoming
            filteredBookings = allBookings.filter { $0.status == .upcoming }
        case 1: // Completed
            filteredBookings = allBookings.filter { $0.status == .completed }
        case 2: // Canceled
            filteredBookings = allBookings.filter { $0.status == .canceled }
        default:
            filteredBookings = allBookings
        }
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredBookings.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        return filteredBookings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Try modern cell first
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingHistoryCell") as? ModernBookingHistoryCell {
            let booking = filteredBookings[indexPath.row]
            cell.configure(with: booking)
            return cell
        }
        // Fallback to storyboard cell
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "BookingHistoryCell", for: indexPath) as? BookingHistoryCell {
            let booking = filteredBookings[indexPath.row]
            cell.configure(with: booking)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBooking = filteredBookings[indexPath.row]
        performSegue(withIdentifier: "showBookingDetails", sender: selectedBooking)
    }
    
    // MARK: - Empty State
    func showEmptyState() {
        let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        emptyLabel.text = "No bookings found"
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textColor = .gray
        emptyLabel.numberOfLines = 0
        tableView.backgroundView = emptyLabel
    }
    
    func hideEmptyState() {
        tableView.backgroundView = nil
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookingDetails" {
            if let destVC = segue.destination as? BookingHistoryDetailsViewController,
               let booking = sender as? BookingModel {
                destVC.bookingData = booking
            }
        }
    }
}

// MARK: - Modern Booking History Cell
class ModernBookingHistoryCell: UITableViewCell {
    
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
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(serviceNameLabel)
        containerView.addSubview(providerNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            serviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            providerNameLabel.trailingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = "Date: \(booking.date)"
        priceLabel.text = booking.price
        
        // Status styling
        statusLabel.text = booking.status.rawValue
        switch booking.status {
        case .upcoming:
            statusLabel.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .completed:
            statusLabel.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        case .canceled:
            statusLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        }
    }
}
