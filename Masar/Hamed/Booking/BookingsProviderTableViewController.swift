// ===================================================================================
// PROVIDER BOOKINGS VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows providers to manage their incoming and past bookings.
//
// OOD PRINCIPLE: Separation of Concerns - This controller acts as the "Glue"
// between the Firebase Data (Model) and the Custom Cells (View).
// ===================================================================================

import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookingsProviderTableViewController: UITableViewController {
    
    // MARK: - Properties
    /// brandColor: Centralizing the theme color for consistency (Encapsulation).
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // Data Sources
    var allBookings: [BookingModel] = []      // Stores ALL fetched bookings (The "Master" Model)
    var filteredBookings: [BookingModel] = [] // Stores ONLY what is currently shown (The "Active" Model)
    
    // UI Components
    // OOD Note: Using a closure to initialize the component ensures all styling is contained in one place.
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
        
        // Initial Data Fetch: Populating the model from the backend
        fetchDataFromFirebase()
    }
    
    // viewWillAppear: Ensuring the navigation bar appearance is consistent whenever we return to this screen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Firebase Fetching
    
    /// OOD Principle: Abstraction - We call ServiceManager.shared instead of writing Firebase queries here.
    /// This keeps the controller "Lean" and focused on the UI.
    private func fetchDataFromFirebase() {
        self.title = "Loading..."
        
        // Fetching bookings assigned to this provider
        ServiceManager.shared.fetchProviderBookings { [weak self] bookings in
            guard let self = self else { return }
            
            // Asynchronous update: Move back to the Main Thread for UI changes
            DispatchQueue.main.async {
                self.title = "Bookings"
                self.allBookings = bookings
                // Apply the current filter (Segment) to the freshly fetched data
                self.updateListForCurrentSegment()
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
        
        // Pull-to-Refresh: Enhancing UX by allowing manual data reloads.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        fetchDataFromFirebase()
        tableView.refreshControl?.endRefreshing()
    }
    
    /// Configures the large title and colorful background of the top bar.
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
        
        // Automatic Dimension: The table calculates cell height based on the content.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        // Registering the custom cell class for reuse (Memory efficiency)
        tableView.register(BookingProviderCell.self, forCellReuseIdentifier: "BookingProviderCell")
    }
    
    // MARK: - Header & Segmentation Logic
    
    /// Creates a header view to hold the Segmented Control (Filter).
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70))
        headerView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        headerView.addSubview(segmentedControl)
        
        // Constraints to keep the segment control centered and neat
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        tableView.tableHeaderView = headerView
    }
    
    /// Applying custom colors and fonts to the Segmented Control.
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
    
    /// Logic to determine which status to filter for.
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
    
    /// Uses Swift's high-order 'filter' function to quickly sort the master list.
    private func filterBookings(for status: BookingStatus) {
        filteredBookings = allBookings.filter { $0.status == status }
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    // OOD Principle: Protocol Implementation for UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBookings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingProviderCell", for: indexPath) as! BookingProviderCell
        
        let booking = filteredBookings[indexPath.row]
        // Injection: Providing the cell with the model it needs to display.
        cell.configure(with: booking, brandColor: brandColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110 // Fixed height for visual consistency
    }
    
    // MARK: - Swipe to Delete Action
    
    /// Enables swipe-to-delete for record management.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.showDeleteAlert(at: indexPath)
            completion(true)
        }
        
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// UX Best Practice: Confirming deletion with the user.
    func showDeleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Do you want delete this booking?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.deleteBooking(at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Handles the two-step deletion: Firebase first, then Local UI.
    func deleteBooking(at indexPath: IndexPath) {
        let bookingToDelete = filteredBookings[indexPath.row]
        
        guard let bookingId = bookingToDelete.id else {
            print("Error: Booking ID is missing")
            return
        }
        
        // 1. Database Deletion (Data Persistence)
        let db = Firestore.firestore()
        db.collection("bookings").document(bookingId).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed from Firebase!")
                
                // 2. Local Model & UI Synchronization
                DispatchQueue.main.async {
                    self.filteredBookings.remove(at: indexPath.row)
                    
                    if let index = self.allBookings.firstIndex(where: { $0.id == bookingId }) {
                        self.allBookings.remove(at: index)
                    }
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // User Interaction Polish: Subtle bounce animation on tap
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
    
    /// OOD Principle: Passing Data & Callbacks.
    /// We pass the model to the next screen AND provide a closure to handle updates coming back.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBookingDetails" {
            if let destinationVC = segue.destination as? BookingProviderDetailsTableViewController,
               let indexPath = sender as? IndexPath {
                
                if indexPath.row < filteredBookings.count {
                    let selectedBooking = filteredBookings[indexPath.row]
                    destinationVC.bookingData = selectedBooking
                    
                    // OOD Principle: Observer Pattern (Closure Callback)
                    // When the detail screen changes a status, it executes this block.
                    destinationVC.onStatusChanged = { [weak self] newStatus in
                        guard let self = self else { return }
                        
                        // Sync the change back into our master model
                        if let index = self.allBookings.firstIndex(where: { $0.id == selectedBooking.id }) {
                            self.allBookings[index].status = newStatus
                        }
                        
                        // Re-filter the view so the item moves to the correct "Tab"
                        self.updateListForCurrentSegment()
                    }
                }
            }
        }
    }
}
