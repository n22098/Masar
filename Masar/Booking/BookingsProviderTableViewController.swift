import UIKit

class BookingsProviderTableViewController: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    var allBookings: [BookingModel] = []
    var filteredBookings: [BookingModel] = []
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Cancelled"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Bookings"
        setupNavigationBar()
        setupTableView()
        setupHeaderView()
        setupSegmentedControlStyle()
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        // تسجيل الخلية المخصصة
        tableView.register(BookingProviderCell.self, forCellReuseIdentifier: "BookingProviderCell")
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        headerView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        tableView.tableHeaderView = headerView
    }
    
    private func setupSegmentedControlStyle() {
        segmentedControl.selectedSegmentTintColor = .white
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: brandColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.backgroundColor = .white
        segmentedControl.layer.cornerRadius = 10
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    // MARK: - Data
    private func fetchData() {
        let b1 = BookingModel(
            id: "1",
            seekerName: "Sayed Husain",
            serviceName: "Website Design",
            date: "25 Dec 2025",
            status: .upcoming,
            providerName: "Provider",
            email: "sayed@example.com",
            phoneNumber: "33991122",
            price: "BHD 50.000",
            instructions: "I need a portfolio website with 3 pages.",
            descriptionText: "Portfolio website (Home, About, Projects)."
        )
        
        let b2 = BookingModel(
            id: "2",
            seekerName: "Kashmala",
            serviceName: "Math Tutoring",
            date: "26 Dec 2025",
            status: .upcoming,
            providerName: "Provider",
            email: "kashmala@example.com",
            phoneNumber: "33445566",
            price: "BHD 15.000",
            instructions: "Focus on Calculus chapter 4 please.",
            descriptionText: "1 hour tutoring session covering Calculus Ch.4."
        )
        
        let b3 = BookingModel(
            id: "3",
            seekerName: "Ahmed Ali",
            serviceName: "AC Repair",
            date: "20 Dec 2025",
            status: .completed,
            providerName: "Provider",
            email: "ahmed@example.com",
            phoneNumber: "33123123",
            price: "BHD 25.000",
            instructions: "AC is leaking water indoors.",
            descriptionText: "Fix AC leakage and test cooling performance."
        )
        
        let b4 = BookingModel(
            id: "4",
            seekerName: "Sara Smith",
            serviceName: "Home Cleaning",
            date: "18 Dec 2025",
            status: .canceled,
            providerName: "Provider",
            email: "sara@example.com",
            phoneNumber: "36667777",
            price: "BHD 12.000",
            instructions: "Please bring your own cleaning supplies.",
            descriptionText: "Apartment cleaning: living room + kitchen + bathroom."
        )
        
        let b5 = BookingModel(
            id: "5",
            seekerName: "Mohamed Radhi",
            serviceName: "App Development",
            date: "28 Dec 2025",
            status: .upcoming,
            providerName: "Provider",
            email: "mohamed@example.com",
            phoneNumber: "39998888",
            price: "BHD 120.000",
            instructions: "Need to fix bugs in the login screen.",
            descriptionText: "Fix login issues + improve validation and error handling."
        )
        
        allBookings = [b1, b2, b3, b4, b5]
        filterBookings(for: .upcoming)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let selectedStatus: BookingStatus
        switch sender.selectedSegmentIndex {
        case 0: selectedStatus = .upcoming
        case 1: selectedStatus = .completed
        case 2: selectedStatus = .canceled
        default: selectedStatus = .upcoming
        }
        filterBookings(for: selectedStatus)
    }
    
    private func filterBookings(for status: BookingStatus) {
        filteredBookings = allBookings.filter { $0.status == status }
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingProviderCell", for: indexPath) as! BookingProviderCell
        
        let booking = filteredBookings[indexPath.row]
        cell.configure(with: booking, brandColor: brandColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Animation
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }
        
        performSegue(withIdentifier: "ShowBookingDetails", sender: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBookingDetails" {
            if let destinationVC = segue.destination as? BookingProviderDetailsTableViewController,
               let indexPath = sender as? IndexPath {
                destinationVC.bookingData = filteredBookings[indexPath.row]
            }
        }
    }
}

// MARK: - Custom Booking Cell
class BookingProviderCell: UITableViewCell {
    
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
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seekerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        containerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        containerView.addSubview(seekerNameLabel)
        containerView.addSubview(serviceNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusBadge)
        containerView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            seekerNameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            seekerNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            seekerNameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            serviceNameLabel.leadingAnchor.constraint(equalTo: seekerNameLabel.leadingAnchor),
            serviceNameLabel.topAnchor.constraint(equalTo: seekerNameLabel.bottomAnchor, constant: 4),
            serviceNameLabel.trailingAnchor.constraint(equalTo: seekerNameLabel.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: seekerNameLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14),
            
            priceLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            priceLabel.centerYAnchor.constraint(equalTo: seekerNameLabel.centerYAnchor),
            priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            statusBadge.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            statusBadge.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with booking: BookingModel, brandColor: UIColor) {
        // Avatar (أول حرفين من الاسم)
        let initials = booking.seekerName.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
        avatarLabel.text = initials.uppercased()
        
        // Labels
        seekerNameLabel.text = booking.seekerName
        serviceNameLabel.text = booking.serviceName
        dateLabel.text = "📅 \(booking.date)"
        priceLabel.text = booking.price
        priceLabel.textColor = brandColor
        
        // Status badge
        switch booking.status {
        case .upcoming:
            statusBadge.text = "Upcoming"
            statusBadge.backgroundColor = brandColor.withAlphaComponent(0.15)
            statusBadge.textColor = brandColor
        case .completed:
            statusBadge.text = "Completed"
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusBadge.textColor = .systemGreen
        case .canceled:
            statusBadge.text = "Cancelled"
            statusBadge.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            statusBadge.textColor = .systemRed
        }
    }
}
