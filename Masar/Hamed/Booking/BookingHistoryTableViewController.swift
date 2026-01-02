import UIKit
import FirebaseFirestore

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
    
    var allBookings: [BookingModel] = []
    var filteredBookings: [BookingModel] = []
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        setupNavigationBar()
        setupUI()
        
        // Ensure this matches the class name in your separate file
        tableView.register(ModernBookingHistoryCell.self, forCellReuseIdentifier: "ModernBookingHistoryCell")
        
        fetchBookingsFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBookingsFromFirebase()
    }
    
    // MARK: - Firebase Fetching
    func fetchBookingsFromFirebase() {
        ServiceManager.shared.fetchAllBookings { [weak self] bookings in
            guard let self = self else { return }
            self.allBookings = bookings
            self.filterBookings()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        
        updateBackgroundView()
    }
    
    // MARK: - 🔥 Empty State Logic 🔥
    func updateBackgroundView() {
        if filteredBookings.isEmpty {
            let emptyView = UIView(frame: tableView.bounds)
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
            imageView.image = UIImage(systemName: "face.frowning", withConfiguration: config)
            imageView.tintColor = brandColor
            imageView.contentMode = .scaleAspectFit
            
            let titleLabel = UILabel()
            titleLabel.text = "No request history"
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .center
            
            let messageLabel = UILabel()
            messageLabel.text = "No history of requests made on Masar"
            messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            messageLabel.textColor = .gray
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(messageLabel)
            
            emptyView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50),
                stackView.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 40),
                stackView.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -40)
            ])
            
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - TableView Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingHistoryCell", for: indexPath) as! ModernBookingHistoryCell
        let booking = filteredBookings[indexPath.row]
        
        cell.configure(with: booking)
        
        // 🔥 HANDLE RATE BUTTON TAP HERE
        // This closure is called when the user taps "Rate" in the cell
        cell.didTapRateButton = { [weak self] in
            // Perform the segue to the Rating screen
            self?.performSegue(withIdentifier: "showRate", sender: booking)
        }
        
        return cell
    }
    
    // MARK: - Delete Feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.confirmDeletion(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func confirmDeletion(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Booking", message: "Are you sure you want to delete this booking history?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteBooking(at: indexPath)
        }))
        
        present(alert, animated: true)
    }
    
    func deleteBooking(at indexPath: IndexPath) {
        guard indexPath.row < filteredBookings.count else { return }
        
        let bookingToDelete = filteredBookings[indexPath.row]
        guard let bookingId = bookingToDelete.id else { return }
        
        // 1. Remove from Local Data
        filteredBookings.remove(at: indexPath.row)
        
        if let index = allBookings.firstIndex(where: { $0.id == bookingId }) {
            allBookings.remove(at: index)
        }
        
        // 2. Update Screen
        tableView.deleteRows(at: [indexPath], with: .left)
        updateBackgroundView()
        
        // 3. Delete from Database
        Firestore.firestore().collection("bookings").document(bookingId).delete { error in
            if let error = error {
                print("Error removing from Firestore: \(error)")
            } else {
                print("Successfully deleted from Firestore")
            }
        }
    }
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < filteredBookings.count {
            let selectedBooking = filteredBookings[indexPath.row]
            performSegue(withIdentifier: "showBookingDetails", sender: selectedBooking)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Segue to Booking Details (Existing)
        if segue.identifier == "showBookingDetails",
           let destVC = segue.destination as? Bookinghistoryapp,
           let booking = sender as? BookingModel {
            destVC.bookingData = booking
            
            destVC.onStatusChanged = { [weak self] newStatus in
                guard let self = self else { return }
                
                if let index = self.allBookings.firstIndex(where: { $0.id == booking.id }) {
                    self.allBookings[index].status = newStatus
                }
                self.filterBookings()
                self.tableView.reloadData()
            }
        }
        
        // 2. 🔥 Segue to Rating Screen (FIXED)
        if segue.identifier == "showRate",
           let ratingVC = segue.destination as? RatingViewController,
           let booking = sender as? BookingModel {
            ratingVC.bookingName = booking.serviceName
            ratingVC.providerId = booking.providerId
            ratingVC.providerName = booking.providerName
        }
    }
}
