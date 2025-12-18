import UIKit

class BookingHistoryTableViewController: UITableViewController {

    @IBOutlet weak var filterSegment: UISegmentedControl!

    let allBookings: [BookingModel] = [
        BookingModel(serviceName: "Website Design", providerName: "Sayed Husain", date: "20 Dec 2025", price: "85 BHD", status: .upcoming),
        BookingModel(serviceName: "Math Tutoring", providerName: "Kashmala", date: "22 Dec 2025", price: "20 BHD", status: .upcoming),
        BookingModel(serviceName: "PC Repair", providerName: "Amin", date: "10 Nov 2025", price: "15 BHD", status: .completed),
        BookingModel(serviceName: "Logo Design", providerName: "Osama", date: "01 Nov 2025", price: "30 BHD", status: .canceled)
    ]

    var filteredBookings: [BookingModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filterBookings()
    }

    func setupUI() {
        title = "My Bookings"
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 120

        // حماية بسيطة لو outlet مو موجود لأي سبب
        guard filterSegment != nil else {
            print("❌ filterSegment outlet is nil (check storyboard wiring)")
            return
        }

        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    @objc func segmentChanged() {
        filterBookings()
        tableView.reloadData()
    }

    func filterBookings() {
        let index = filterSegment?.selectedSegmentIndex ?? 0
        switch index {
        case 0:
            filteredBookings = allBookings.filter { $0.status == .upcoming }
        case 1:
            filteredBookings = allBookings.filter { $0.status == .completed }
        case 2:
            filteredBookings = allBookings.filter { $0.status == .canceled }
        default:
            filteredBookings = allBookings
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredBookings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingHistoryCell", for: indexPath) as! BookingHistoryCell
        cell.configure(with: filteredBookings[indexPath.row])
        return cell
    }
}
