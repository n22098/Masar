import UIKit

class RatingsReviewsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var ratings: [Rating] = []
    
    // 🔥 الآيدي فقط (بدون اسم)
    var providerId: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 🔥 تم حذف كود تغيير العنوان (Title)
        
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
        guard let tableView = tableView else {
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
    }
    
    @objc private func fetchRatingsData() {
        guard let pId = providerId else { return }
        
        RatingService.shared.fetchRatings(for: pId) { [weak self] (fetchedRatings, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching: \(error.localizedDescription)")
                return
            }
            
            self.ratings = fetchedRatings
            self.updateHeader()
            self.tableView?.reloadData()
        }
    }
    
    private func updateHeader() {
        let totalCount = ratings.count
        totalRatingsLabel?.text = "\(totalCount) ratings"
        
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
extension RatingsReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingTableViewCell
        cell.configure(with: ratings[indexPath.row])
        return cell
    }
}
