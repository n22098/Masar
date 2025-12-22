import UIKit

class BookingsProviderTableViewController: UITableViewController {

    var allBookings: [BookingModel] = []
    var filteredBookings: [BookingModel] = []

    let segmentedControl: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Cancelled"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        self.title = ""

        setupHeaderView()
        setupSegmentedControlStyle()
        fetchData()
    }

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
        let mainPurple = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)

        segmentedControl.selectedSegmentTintColor = .white

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: mainPurple,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]

        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray6
    }

    func fetchData() {

        let b1 = BookingModel(
            id: "1",
            seekerName: "Sayed Husain",
            serviceName: "Website Design",
            date: "22-12-2023",
            status: .upcoming,
            providerName: "Provider",
            email: "sayed@example.com",
            phoneNumber: "33991122",
            price: "50.000",
            instructions: "I need a portfolio website with 3 pages.",
            descriptionText: "Portfolio website (Home, About, Projects)."
        )

        let b2 = BookingModel(
            id: "2",
            seekerName: "Kashmala",
            serviceName: "Math Tutoring",
            date: "22-12-2023",
            status: .upcoming,
            providerName: "Provider",
            email: "kashmala@example.com",
            phoneNumber: "33445566",
            price: "15.000",
            instructions: "Focus on Calculus chapter 4 please.",
            descriptionText: "1 hour tutoring session covering Calculus Ch.4."
        )

        let b3 = BookingModel(
            id: "3",
            seekerName: "Ahmed Ali",
            serviceName: "AC Repair",
            date: "23-12-2023",
            status: .completed,
            providerName: "Provider",
            email: "ahmed@example.com",
            phoneNumber: "33123123",
            price: "25.000",
            instructions: "AC is leaking water indoors.",
            descriptionText: "Fix AC leakage and test cooling performance."
        )

        let b4 = BookingModel(
            id: "4",
            seekerName: "Sara Smith",
            serviceName: "Home Cleaning",
            date: "24-12-2023",
            status: .canceled,
            providerName: "Provider",
            email: "sara@example.com",
            phoneNumber: "36667777",
            price: "12.000",
            instructions: "Please bring your own cleaning supplies.",
            descriptionText: "Apartment cleaning: living room + kitchen + bathroom."
        )

        let b5 = BookingModel(
            id: "5",
            seekerName: "Mohamed Radhi",
            serviceName: "App Development",
            date: "26-12-2023",
            status: .upcoming,
            providerName: "Provider",
            email: "mohamed@example.com",
            phoneNumber: "39998888",
            price: "120.000",
            instructions: "Need to fix bugs in the login screen.",
            descriptionText: "Fix login issues + improve validation and error handling."
        )

        allBookings = [b1, b2, b3, b4, b5]
        filterBookings(for: .upcoming)
    }


    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let selectedStatus: BookingStatus

        switch sender.selectedSegmentIndex {
        case 0: selectedStatus = .upcoming
        case 1: selectedStatus = .completed
        case 2: selectedStatus = .canceled
        default: selectedStatus = .upcoming
        }

        filterBookings(for: selectedStatus)
    }

    func filterBookings(for status: BookingStatus) {
        filteredBookings = allBookings.filter { $0.status == status }
        tableView.reloadData()
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBookingDetails" {
            if let destinationVC = segue.destination as? BookingProviderDetailsTableViewController,
               let indexPath = tableView.indexPathForSelectedRow {

                destinationVC.bookingData = filteredBookings[indexPath.row]
            }
        }
    }
}
