import UIKit

class BookingHistoryTableViewController: UITableViewController {
    
    // MARK: - Outlets
    // اربط هذا بالـ Segmented Control اللي فوق
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    // MARK: - Properties
    // بيانات وهمية للتجربة
    let allBookings: [BookingModel] = [
        BookingModel(serviceName: "Website Design", providerName: "Sayed Husain", date: "20 Dec 2025", price: "85 BHD", status: .upcoming),
        BookingModel(serviceName: "Math Tutoring", providerName: "Kashmala", date: "22 Dec 2025", price: "20 BHD", status: .upcoming),
        BookingModel(serviceName: "PC Repair", providerName: "Amin", date: "10 Nov 2025", price: "15 BHD", status: .completed),
        BookingModel(serviceName: "Logo Design", providerName: "Osama", date: "01 Nov 2025", price: "30 BHD", status: .canceled)
    ]
    
    var filteredBookings: [BookingModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filterBookings() // فلترة مبدئية
    }
    
    func setupUI() {
        title = "My Bookings"
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = 120 // ارتفاع الخلية
        
        // إعداد السيجمنت
        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    // MARK: - Filtering Logic
    @objc func segmentChanged() {
        filterBookings()
        tableView.reloadData()
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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // تأكد أن Identifier في الستوري بورد هو: BookingHistoryCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingHistoryCell", for: indexPath) as! BookingHistoryCell
        
        let booking = filteredBookings[indexPath.row]
        cell.configure(with: booking)
        
        return cell
    }
}
