//
//  RatingsReviewsViewController.swift
//  Masar
//
//  Created by Guest User on 23/12/2025.
//

import UIKit

// MARK: - RatingsReviewsViewController
class RatingsReviewsViewController: UIViewController {
    
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var ratings: [Rating] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadRatings()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ratingsUpdated),
            name: NSNotification.Name("RatingAdded"),
            object: nil
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
    }
    
    @objc private func ratingsUpdated() {
        loadRatings()
    }
    
    private func loadRatings() {
        guard let data = UserDefaults.standard.data(forKey: "SavedRatings"),
              let loadedRatings = try? JSONDecoder().decode([Rating].self, from: data) else {
            ratings = []
            updateHeader()
            tableView.reloadData()
            return
        }
        
        ratings = loadedRatings.sorted { $0.date > $1.date }
        updateHeader()
        tableView.reloadData()
    }
    
    private func updateHeader() {
        let totalCount = ratings.count
        totalRatingsLabel.text = "\(totalCount)+ ratings"
        
        if totalCount > 0 {
            let average = ratings.reduce(0.0) { $0 + $1.stars } / Double(totalCount)
            averageRatingLabel.text = String(format: "%.1f", average)
        } else {
            averageRatingLabel.text = "0.0"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - TableView DataSource & Delegate
extension RatingsReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingTableViewCell
        cell.configure(with: ratings[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
