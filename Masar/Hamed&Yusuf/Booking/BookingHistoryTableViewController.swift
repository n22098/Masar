import UIKit
import FirebaseFirestore

/// BookingHistoryTableViewController manages the display and filtering of user bookings.
/// OOD Principle: Encapsulation - This class encapsulates the logic for displaying booking history
/// and managing the user interface state.
class BookingHistoryTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// filterSegment: A lazy property that handles the UI for switching between booking statuses.
    /// OOD Note: Lazy loading ensures the segment is only created when it's first accessed, saving memory.
    private lazy var filterSegment: UISegmentedControl = {
        let items = ["Upcoming", "Completed", "Canceled"]
        let segment = UISegmentedControl(items: items)
        let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        // UI Styling for the segment control
        segment.backgroundColor = UIColor(white: 0.95, alpha: 1)
        segment.selectedSegmentTintColor = .white
        segment.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: brandColor, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        
        return segment
    }()
    
    // Data storage for the table view
    var allBookings: [BookingModel] = []       // Holds the full list from Firebase
    var filteredBookings: [BookingModel] = []  // Holds only the items the user currently sees based on the filter
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        
        // Initial setup routines
        setupNavigationBar()
        setupUI()
        
        // Registering the custom cell class for reuse
        tableView.register(ModernBookingHistoryCell.self, forCellReuseIdentifier: "ModernBookingHistoryCell")
        
        // Load initial data
        fetchBookingsFromFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data whenever the view appears to ensure accuracy
        fetchBookingsFromFirebase()
    }
    
    // MARK: - Firebase Fetching
    
    /// Fetches booking data from the remote server.
    /// OOD Principle: Abstraction - We use 'ServiceManager.shared' to hide the complexity of Firebase calls.
    func fetchBookingsFromFirebase() {
        ServiceManager.shared.fetchBookings { [weak self] bookings in
            guard let self = self else { return }
            
            // Update local data models
            self.allBookings = bookings
            self.filterBookings()
            
            // Ensure UI updates happen on the main thread to prevent crashes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UI Setup
    
    /// Configures the visual appearance of the Navigation Bar at the top of the screen.
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
    
    /// Sets up the general table view styles.
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        setupSegmentHeader()
    }
    
    /// Programmatically creates the header containing the segment filter.
    func setupSegmentHeader() {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        headerContainer.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        headerContainer.addSubview(filterSegment)
        
        // Autolayout constraints to keep the segment centered and padded
        NSLayoutConstraint.activate([
            filterSegment.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            filterSegment.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            filterSegment.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Adds target-action pattern to respond to user clicks
        filterSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        tableView.tableHeaderView = headerContainer
    }
    
    /// Triggered when the user switches between "Upcoming", "Completed", or "Canceled".
    @objc func segmentChanged() {
        filterBookings()
        tableView.reloadData()
    }
    
    /// Logic to decide which bookings to show based on the selected segment index.
    func filterBookings() {
        switch filterSegment.selectedSegmentIndex {
        case 0: filteredBookings = allBookings.filter { $0.status == .upcoming }
        case 1: filteredBookings = allBookings.filter { $0.status == .completed }
        case 2: filteredBookings = allBookings.filter { $0.status == .canceled }
        default: filteredBookings = allBookings
        }
        
        // Check if we need to show the "No History" message
        updateBackgroundView()
    }
    
    // MARK: - Empty State Logic
    
    /// Manages the background view of the table. Shows a message if no data is available.
    /// This improves User Experience (UX) by providing feedback when a list is empty.
    func updateBackgroundView() {
        if filteredBookings.isEmpty {
            let emptyView = UIView(frame: tableView.bounds)
            
            // StackView helps organize the image and text labels vertically
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Icon configuration
            let imageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
            imageView.image = UIImage(systemName: "face.frowning", withConfiguration: config)
            imageView.tintColor = brandColor
            imageView.contentMode = .scaleAspectFit
            
            // Primary message
            let titleLabel = UILabel()
            titleLabel.text = "No request history"
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            titleLabel.textColor = .black
            
            // Descriptive sub-message
            let messageLabel = UILabel()
            messageLabel.text = "No history of requests made on Masar"
            messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            messageLabel.textColor = .gray
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(messageLabel)
            
            emptyView.addSubview(stackView)
            
            // Center the message in the middle of the screen
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50)
            ])
            
            tableView.backgroundView = emptyView
        } else {
            // Remove the empty state view if there are items to show
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - TableView Data Source
    // OOD Principle: Protocol Implementation - Following the UITableViewDataSource protocol requirements.
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140 // Fixed height for a consistent, modern card look
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeuing cells for memory efficiency
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingHistoryCell", for: indexPath) as! ModernBookingHistoryCell
        let booking = filteredBookings[indexPath.row]
        
        // Pass the model to the cell to handle its own UI (Encapsulation)
        cell.configure(with: booking)
        
        // Closure handling for the "Rate" button inside the cell
        cell.didTapRateButton = { [weak self] in
            self?.performSegue(withIdentifier: "showRate", sender: booking)
        }
        
        return cell
    }
    
    // MARK: - Swipe to Delete Actions
    
    /// Enables the swipe-to-delete functionality.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            // Shows a confirmation alert before actual deletion
            self?.showDeleteAlert(at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// Displays a confirmation dialog to the user to avoid accidental deletions.
    func showDeleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Do you want delete this service?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.deleteBooking(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Logic to remove the booking from the local arrays and the table view.
    func deleteBooking(at indexPath: IndexPath) {
        // 1. Identify the specific object to delete
        let bookingToDelete = filteredBookings[indexPath.row]
        
        // 2. Remove from the currently displayed (filtered) list
        filteredBookings.remove(at: indexPath.row)
        
        // 3. Sync with the master list (allBookings) to maintain data consistency
        if let index = allBookings.firstIndex(where: { $0.id == bookingToDelete.id }) {
            allBookings.remove(at: index)
        }
        
        // 4. Animate the removal from the UI for a smooth experience
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // 5. Update background view if the list is now empty
        updateBackgroundView()
        
        // Note: Database deletion logic (Firebase) would be called here if persistence is required.
    }
    
    // MARK: - Navigation
    
    /// Handles what happens when a user taps on a specific row.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < filteredBookings.count {
            let selectedBooking = filteredBookings[indexPath.row]
            performSegue(withIdentifier: "showBookingDetails", sender: selectedBooking)
        }
    }
    
    /// Prepares the data before transitioning to a new screen.
    /// OOD Principle: Delegation/Callbacks - Using a closure (onStatusChanged) to update this controller when the detail screen changes something.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Case 1: Navigating to Booking Details
        if segue.identifier == "showBookingDetails",
           let destVC = segue.destination as? Bookinghistoryapp,
           let booking = sender as? BookingModel {
            destVC.bookingData = booking
            
            // Communication pattern: Closure to pass data back when status changes in the detail view
            destVC.onStatusChanged = { [weak self] newStatus in
                guard let self = self else { return }
                if let index = self.allBookings.firstIndex(where: { $0.id == booking.id }) {
                    self.allBookings[index].status = newStatus
                }
                self.filterBookings()
                self.tableView.reloadData()
            }
        }
        
        // Case 2: Navigating to the Rating Screen
        if segue.identifier == "showRate",
           let ratingVC = segue.destination as? RatingViewController,
           let booking = sender as? BookingModel {
            ratingVC.bookingName = booking.serviceName
            ratingVC.providerId = booking.providerId
            ratingVC.providerName = booking.providerName
        }
    }
}
