import UIKit

class BookingHistoryTableViewController: UITableViewController {

    // MARK: - Properties
    private lazy var filterSegment: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Canceled"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    // ✅ FIXED: Added all required fields to the dummy data
    var allBookings: [BookingModel] = [
        BookingModel(serviceName: "IT Solutions", date: "25 Dec 2025", price: "120 BHD", status: .upcoming, providerName: "Tech Experts Co."),
        BookingModel(serviceName: "Math Tutoring", date: "28 Dec 2025", price: "20 BHD", status: .upcoming, providerName: "Mr. Ahmed Ali"),
        BookingModel(serviceName: "Digital Services", date: "30 Dec 2025", price: "45 BHD", status: .completed, providerName: "Creative Digital"),
        BookingModel(serviceName: "Website Design", date: "15 Nov 2025", price: "85 BHD", status: .completed, providerName: "Sayed Husain"),
        BookingModel(serviceName: "Logo Design", date: "01 Nov 2025", price: "30 BHD", status: .canceled, providerName: "Osama Graphics")
    ]

    var filteredBookings: [BookingModel] = []
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        setupNavigationBar()
        setupUI()
        filterBookings()
        tableView.register(ModernBookingHistoryCell.self, forCellReuseIdentifier: "ModernBookingHistoryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data when returning from Details screen to show updated status
        filterBookings()
        tableView.reloadData()
    }

    // MARK: - UI Setup
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        setupSegmentHeader()
    }
    
    func setupSegmentHeader() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        headerContainer.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        headerContainer.addSubview(filterSegment)
        
        NSLayoutConstraint.activate([
            filterSegment.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            filterSegment.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            filterSegment.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        tableView.tableHeaderView = headerContainer
        styleSegmentControl(filterSegment)
        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    func styleSegmentControl(_ segment: UISegmentedControl) {
        segment.backgroundColor = UIColor(white: 0.95, alpha: 1)
        segment.selectedSegmentTintColor = .white
        segment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: brandColor, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
    }

    // MARK: - Logic
    @objc func segmentChanged() {
        filterBookings()
        tableView.reloadData()
    }

    func filterBookings() {
        let index = filterSegment.selectedSegmentIndex
        switch index {
        case 0: filteredBookings = allBookings.filter { $0.status == .upcoming }
        case 1: filteredBookings = allBookings.filter { $0.status == .completed }
        case 2: filteredBookings = allBookings.filter { $0.status == .canceled }
        default: filteredBookings = allBookings
        }
    }

    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingHistoryCell", for: indexPath) as! ModernBookingHistoryCell
        let booking = filteredBookings[indexPath.row]
        cell.configure(with: booking)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // ✅ PASS DATA TO DETAILS SCREEN
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedBooking = filteredBookings[indexPath.row]
        // Make sure your Segue identifier in storyboard is "showBookingDetails"
        performSegue(withIdentifier: "showBookingDetails", sender: selectedBooking)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookingDetails" {
            if let destVC = segue.destination as? BookingHistoryDetailsViewController,
               let booking = sender as? BookingModel {
                destVC.bookingData = booking
            }
        }
    }
}

// MARK: - Cell Class
class ModernBookingHistoryCell: UITableViewCell {
    // ... (Keep the cell code exactly as you had it in your previous message, it was correct) ...
    // Just ensure the configure method looks like this:
    
    /* func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = "Date: \(booking.date)"
        priceLabel.text = booking.price
        statusLabel.text = booking.status.rawValue
        // ... colors ...
    }
    */
    
    // I am omitting the full visual layout code here to save space since you already have the working cell code.
    // If you need it pasted again, let me know.
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(serviceNameLabel)
        containerView.addSubview(providerNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            serviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),
        ])
    }
    
    func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = "Date: \(booking.date)"
        priceLabel.text = booking.price
        statusLabel.text = booking.status.rawValue
        
        switch booking.status {
        case .upcoming: statusLabel.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case .completed: statusLabel.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
        case .canceled: statusLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        }
    }
}
