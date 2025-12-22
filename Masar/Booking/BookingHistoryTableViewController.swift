import UIKit

class BookingHistoryTableViewController: UITableViewController {

    // MARK: - Properties
    private lazy var filterSegment: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Canceled"]
        let segment = UISegmentedControl(items: items)
        let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        segment.backgroundColor = UIColor(white: 0.95, alpha: 1)
        segment.selectedSegmentTintColor = .white
        segment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: brandColor, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        
        return segment
    }()

    // بيانات وهمية
    var allBookings: [BookingModel] = [
        BookingModel(id: "H1", seekerName: "You", serviceName: "IT Solutions", date: "25 Dec 2025", status: .upcoming, providerName: "Tech Experts Co.", email: "you@example.com", phoneNumber: "00000000", price: "120 BHD", instructions: "Please contact me before arriving.", descriptionText: "General IT support and troubleshooting."),
        BookingModel(id: "H2", seekerName: "You", serviceName: "Math Tutoring", date: "28 Dec 2025", status: .upcoming, providerName: "Mr. Ahmed Ali", email: "you@example.com", phoneNumber: "00000000", price: "20 BHD", instructions: "Focus on calculus chapter 4.", descriptionText: "1 hour tutoring session."),
        BookingModel(id: "H3", seekerName: "You", serviceName: "Digital Services", date: "30 Dec 2025", status: .completed, providerName: "Creative Digital", email: "you@example.com", phoneNumber: "00000000", price: "45 BHD", instructions: "Share logo assets and brand colors.", descriptionText: "Digital marketing + design services."),
        BookingModel(id: "H4", seekerName: "You", serviceName: "Website Design", date: "15 Nov 2025", status: .completed, providerName: "Sayed Husain", email: "you@example.com", phoneNumber: "00000000", price: "85 BHD", instructions: "Portfolio website with 3 pages.", descriptionText: "Website design + basic implementation."),
        BookingModel(id: "H5", seekerName: "You", serviceName: "Logo Design", date: "01 Nov 2025", status: .canceled, providerName: "Osama Graphics", email: "you@example.com", phoneNumber: "00000000", price: "30 BHD", instructions: "Send sample logos you like.", descriptionText: "Logo concepts + revisions.")
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
        
        // ✅ هذا السطر يسجل الخلية لكي يتعرف عليها الجدول
        tableView.register(ModernBookingHistoryCell.self, forCellReuseIdentifier: "ModernBookingHistoryCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterBookings()
        tableView.reloadData()
    }

    // MARK: - UI Setup & Logic
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
        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        tableView.tableHeaderView = headerContainer
    }

    @objc func segmentChanged() {
        filterBookings()
        tableView.reloadData()
    }

    func filterBookings() {
        switch filterSegment.selectedSegmentIndex {
        case 0: filteredBookings = allBookings.filter { $0.status == .upcoming }
        case 1: filteredBookings = allBookings.filter { $0.status == .completed }
        case 2: filteredBookings = allBookings.filter { $0.status == .canceled }
        default: filteredBookings = allBookings
        }
    }

    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return filteredBookings.count }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 140 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ✅ استخدام الخلية التي سنعرفها في الأسفل
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingHistoryCell", for: indexPath) as! ModernBookingHistoryCell
        let booking = filteredBookings[indexPath.row]
        cell.configure(with: booking)
        return cell
    }

    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedBooking = filteredBookings[indexPath.row]
        // الانتقال
        performSegue(withIdentifier: "showBookingDetails", sender: selectedBooking) // تأكد أن الاسم في الستوري بورد "showBookingDetails"
    }

    // ✅ الربط مع ملف التفاصيل الخاص بك (BookinghistoryappTableViewController)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // تأكد من الستوري بورد أن الـ Segue Identifier هو "showBookingDetails" أو "Show" وغيره هنا ليطابق
        if let destVC = segue.destination as? Bookinghistoryapp,
           let booking = sender as? BookingModel {
            destVC.bookingData = booking
        }
    }
}

// MARK: - ✅ ModernBookingHistoryCell Class (تمت إضافته هنا ليختفي الخطأ)
class ModernBookingHistoryCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        label.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
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
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            serviceNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            serviceNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),

            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),

            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }

    func configure(with booking: BookingModel) {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = booking.providerName
        dateLabel.text = "📅 \(booking.date)"
        priceLabel.text = booking.price
        statusLabel.text = "  \(booking.status.rawValue)  "

        switch booking.status {
        case .upcoming:
            statusLabel.textColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.1)
        case .completed:
            statusLabel.textColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.1)
        case .canceled:
            statusLabel.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
            statusLabel.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.1)
        }
    }
}
