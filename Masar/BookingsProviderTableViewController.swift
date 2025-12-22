import UIKit

// MARK: - Dummy Models
enum DummyBookingStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// Replace your old struct with this one
struct DummyBookingModel {
    let id: String
    let seekerName: String
    let serviceName: String
    let date: String
    let status: DummyBookingStatus
    
    // 👇 You were missing these lines:
    let email: String
    let phoneNumber: String
    let price: String
    let instructions: String
}

class BookingsProviderTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var allBookings: [DummyBookingModel] = []
    var filteredBookings: [DummyBookingModel] = []
    
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
        
        navigationItem.largeTitleDisplayMode = .never
        self.title = ""
        
        setupHeaderView()
        setupSegmentedControlStyle()
        fetchDummyData()
    }
    
    // MARK: - Setup
    
    func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
        headerView.backgroundColor = .systemBackground
        
        headerView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        tableView.tableHeaderView = headerView
    }
    
    func setupSegmentedControlStyle() {
        // Your App's Purple Color
        let mainPurple = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        
        // 1. Selected background is white
        segmentedControl.selectedSegmentTintColor = .white
        
        // 2. Selected text is Purple
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: mainPurple,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        // 3. Normal text is Black
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        
        // 4. Background bar is light gray
        segmentedControl.backgroundColor = UIColor.systemGray6
    }
    
    // MARK: - Data Fetching
    
    func fetchDummyData() {
        // ✅ UPDATED: Added dummy data for email, phone, price, and instructions
        
        let b1 = DummyBookingModel(
            id: "1",
            seekerName: "Sayed Husain",
            serviceName: "Website Design",
            date: "22-12-2023",
            status: .upcoming,
            email: "sayed@example.com",
            phoneNumber: "33991122",
            price: "50.000",
            instructions: "I need a portfolio website with 3 pages."
        )
        
        let b2 = DummyBookingModel(
            id: "2",
            seekerName: "Kashmala",
            serviceName: "Math Tutoring",
            date: "22-12-2023",
            status: .upcoming,
            email: "kashmala@example.com",
            phoneNumber: "33445566",
            price: "15.000",
            instructions: "Focus on Calculus chapter 4 please."
        )
        
        let b3 = DummyBookingModel(
            id: "3",
            seekerName: "Ahmed Ali",
            serviceName: "AC Repair",
            date: "23-12-2023",
            status: .completed,
            email: "ahmed@example.com",
            phoneNumber: "33123123",
            price: "25.000",
            instructions: "AC is leaking water indoors."
        )
        
        let b4 = DummyBookingModel(
            id: "4",
            seekerName: "Sara Smith",
            serviceName: "Home Cleaning",
            date: "24-12-2023",
            status: .cancelled,
            email: "sara@example.com",
            phoneNumber: "36667777",
            price: "12.000",
            instructions: "Please bring your own cleaning supplies."
        )
        
        let b5 = DummyBookingModel(
            id: "5",
            seekerName: "Mohamed Radhi",
            serviceName: "App Development",
            date: "26-12-2023",
            status: .upcoming,
            email: "mohamed@example.com",
            phoneNumber: "39998888",
            price: "120.000",
            instructions: "Need to fix bugs in the login screen."
        )
        
        self.allBookings = [b1, b2, b3, b4, b5]
        
        filterBookings(for: .upcoming)
    }
    
    // MARK: - Actions
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let selectedStatus: DummyBookingStatus
        
        switch sender.selectedSegmentIndex {
        case 0: selectedStatus = .upcoming
        case 1: selectedStatus = .completed
        case 2: selectedStatus = .cancelled
        default: selectedStatus = .upcoming
        }
        
        filterBookings(for: selectedStatus)
    }
    
    func filterBookings(for status: DummyBookingStatus) {
        filteredBookings = allBookings.filter { $0.status == status }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as? BookingCell else {
            return UITableViewCell()
        }
        
        let booking = filteredBookings[indexPath.row]
        
        cell.seekerLabel.text = booking.seekerName
        cell.serviceNameLabel.text = booking.serviceName
        cell.dateLabel.text = booking.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowBookingDetails" {
            
            if let destinationVC = segue.destination as? BookingProviderDetailsTableViewController {
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    
                    let selectedBooking = filteredBookings[indexPath.row]
                    
                    // This now passes the FULL model (including email, price, etc)
                    destinationVC.bookingData = selectedBooking
                }
            }
        }
    }
}
