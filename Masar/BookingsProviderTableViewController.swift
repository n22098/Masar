//
//  BookingsProviderTableViewController.swift
//  Masar
//
//  Created by Moe Radhi on 22/12/2025.
//

import UIKit

// MARK: - Dummy Models
enum DummyBookingStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct DummyBookingModel {
    let id: String
    let seekerName: String
    let serviceName: String
    let date: String
    let status: DummyBookingStatus
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
        setupSegmentedControlStyle() // سيتم تطبيق التصميم الجديد هنا
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
    
    // 👇👇👇 هنا التعديل عشان يصير زي صفحة History بالضبط 👇👇👇
    func setupSegmentedControlStyle() {
        // اللون البنفسجي الخاص بتطبيقك
        let mainPurple = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
        
        // 1. خلفية الزر المختار تكون "أبيض" (مثل صفحة History)
        segmentedControl.selectedSegmentTintColor = .white
        
        // 2. النص المختار يكون "بنفسجي"
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: mainPurple,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        // 3. النص غير المختار يكون "أسود" (أو رمادي غامق)
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
        
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        
        // 4. خلفية الشريط كامل تكون رمادي فاتح
        segmentedControl.backgroundColor = UIColor.systemGray6
    }
    
    // MARK: - Data Fetching
    
    func fetchDummyData() {
        // البيانات بالترتيب: Seeker Name -> Service -> Date
        let b1 = DummyBookingModel(id: "1", seekerName: "Sayed Husain", serviceName: "Website Design", date: "22-12-2023", status: .upcoming)
        let b2 = DummyBookingModel(id: "2", seekerName: "Kashmala", serviceName: "Math Tutoring", date: "22-12-2023", status: .upcoming)
        let b3 = DummyBookingModel(id: "3", seekerName: "Ahmed Ali", serviceName: "AC Repair", date: "23-12-2023", status: .completed)
        let b4 = DummyBookingModel(id: "4", seekerName: "Sara Smith", serviceName: "Home Cleaning", date: "24-12-2023", status: .cancelled)
        let b5 = DummyBookingModel(id: "5", seekerName: "Mohamed Radhi", serviceName: "App Development", date: "26-12-2023", status: .upcoming)

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
        
        // ترتيب البيانات:
        // 1. Seeker Name (اسم الطالب)
        // 2. Service Name (اسم الخدمة)
        // 3. Date (التاريخ)
        
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
}
