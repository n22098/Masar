//
//  ratingcontrol.swift
//  Masar
//
//  Created by BP-36-212-19 on 04/01/2026.
//

import UIKit

class ratingcontrol: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var ratings: [Rating] = []
    var providerID: String? // Passed from the previous screen

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        fetchRatingsData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchRatingsData),
            name: NSNotification.Name("RatingAdded"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTableView() {
        guard let tableView = tableView else { return }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
    }
    
    @objc private func fetchRatingsData() {
        guard let pId = providerID else {
            print("No Provider ID found")
            return
        }
        
        RatingService.shared.fetchRatings(for: pId) { [weak self] (fetchedRatings, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Admin Fetch Error: \(error.localizedDescription)")
                return
            }
            
            self.ratings = fetchedRatings
            self.updateHeader()
            self.tableView?.reloadData()
        }
    }
    
    private func updateHeader() {
        let totalCount = ratings.count
        totalRatingsLabel?.text = "Admin Mode: \(totalCount) Reviews"
        
        if totalCount > 0 {
            let totalStars = ratings.reduce(0.0) { $0 + $1.stars }
            let average = totalStars / Double(totalCount)
            averageRatingLabel?.text = String(format: "%.1f", average)
        } else {
            averageRatingLabel?.text = "0.0"
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ratingcontrol: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingTableViewCell
        cell.configure(with: ratings[indexPath.row])
        return cell
    }

    // MARK: - Admin Edit/Delete Actions
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ratingToDelete = ratings[indexPath.row]
            confirmDeletion(for: ratingToDelete, at: indexPath)
        }
    }
    
    private func confirmDeletion(for rating: Rating, at indexPath: IndexPath) {
        // ✅ FIXED: Changed .some to .alert
        let alert = UIAlertController(title: "Delete Review", message: "Are you sure you want to remove this review? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteRatingFromDatabase(rating: rating, indexPath: indexPath)
        }))
        
        present(alert, animated: true)
    }
    
    private func deleteRatingFromDatabase(rating: Rating, indexPath: IndexPath) {
        // ✅ FIXED: Removed 'rating.id' because your Rating model doesn't have an ID property yet.
        
        // Remove from the local array
        self.ratings.remove(at: indexPath.row)
        
        // Remove from the Table View
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
        // Update the header stats
        self.updateHeader()
        
        print("Admin deleted a rating.")
    }
}
