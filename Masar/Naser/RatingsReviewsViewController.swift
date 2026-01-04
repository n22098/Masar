import UIKit
import FirebaseFirestore

class RatingsReviewsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var totalRatingsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // 🔥 Ensure this is connected to your UIImageView in Storyboard
    @IBOutlet weak var providerImageView: UIImageView!
    
    // MARK: - Properties
    private var ratings: [Rating] = []
    var providerId: String?
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialUI()
        setupTableView()
        fetchProviderData()
        fetchRatingsData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchRatingsData),
            name: NSNotification.Name("RatingAdded"),
            object: nil
        )
    }
    
    /// 🔥 CRITICAL: This method ensures the image becomes round AFTER the layout is set
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyRoundCornerRadius()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    
    private func setupInitialUI() {
        // Matches the styling of your ServiceItemTableViewController
        providerImageView?.contentMode = .scaleAspectFill
        providerImageView?.clipsToBounds = true
        providerImageView?.layer.borderWidth = 2
        providerImageView?.layer.borderColor = UIColor.white.cgColor
        
        // Background color while loading (same as your reference code)
        providerImageView?.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        
        // Default placeholder
        providerImageView?.image = UIImage(systemName: "person.circle.fill")
        
        // 🔥 Set size constraints to match the second screenshot
        providerImageView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            providerImageView!.widthAnchor.constraint(equalToConstant: 100),
            providerImageView!.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func applyRoundCornerRadius() {
        if let iv = providerImageView {
            // Perfect circle: Corner radius must be half of the frame height
            iv.layer.cornerRadius = iv.frame.height / 2
        }
    }
    
    private func setupTableView() {
        guard let tableView = tableView else { return }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }
    
    // MARK: - Data Management
    
    private func fetchProviderData() {
        guard let pId = providerId else { return }
        
        db.collection("users").document(pId).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else { return }
            
            if let urlString = data["profileImageURL"] as? String, let url = URL(string: urlString) {
                self.loadProviderImage(from: url)
            }
        }
    }
    
    private func loadProviderImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.providerImageView?.image = image
                }
            }
        }.resume()
    }
    
    @objc private func fetchRatingsData() {
        guard let pId = providerId else { return }
        
        RatingService.shared.fetchRatings(for: pId) { [weak self] (fetchedRatings, error) in
            guard let self = self else { return }
            if let error = error { return }
            
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
