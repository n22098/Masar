import UIKit
import FirebaseAuth // 🔥 ضروري جداً لجلب رقم المزود

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
        
        // جلب البيانات عند فتح التطبيق
        fetchDataFromFirebase()
    }
    
    // تحديث البيانات في كل مرة تظهر الشاشة (لضمان المزامنة)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        // fetchDataFromFirebase() // يمكنك تفعيلها هنا أيضاً إذا أردت تحديثاً مستمراً
    }
    
    // MARK: - Firebase Fetching 📡
    private func fetchDataFromFirebase() {
        // إضافة مؤشر تحميل بسيط في العنوان
        self.title = "Loading..."
        
        // 🔥 تم الإصلاح هنا: نستخدم دالة المزود الخاصة التي تعرض طلباته هو فقط
        ServiceManager.shared.fetchProviderBookings { [weak self] bookings in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.title = "Bookings"
                self.allBookings = bookings
                self.updateListForCurrentSegment() // تحديث القائمة بناءً على الفلتر الحالي
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Bookings"
        setupNavigationBar()
        setupTableView()
        setupHeaderView()
        setupSegmentedControlStyle()
        
        // إضافة Refresh Control (سحب للتحديث)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        fetchDataFromFirebase()
        tableView.refreshControl?.endRefreshing()
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
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateListForCurrentSegment()
    }
    
    private func updateListForCurrentSegment() {
        let selectedStatus: BookingStatus
        switch segmentedControl.selectedSegmentIndex {
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
                
                let selectedBooking = filteredBookings[indexPath.row]
                destinationVC.bookingData = selectedBooking
                
                destinationVC.onStatusChanged = { [weak self] newStatus in
                    guard let self = self else { return }
                    
                    // تحديث العنصر في المصفوفة المحلية فوراً لسرعة الاستجابة
                    if let index = self.allBookings.firstIndex(where: { $0.id == selectedBooking.id }) {
                        self.allBookings[index].status = newStatus
                    }
                    
                    self.updateListForCurrentSegment()
                }
            }
        }
    }
}
