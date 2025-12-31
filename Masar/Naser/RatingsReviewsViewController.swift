import UIKit

class RatingsReviewsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var averageRatingLabel: UILabel?
    @IBOutlet weak var totalRatingsLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    
    // MARK: - Properties
    private var ratings: [Rating] = []
    var providerId: String?
    var providerName: String = "Provider"
    private let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchRatingsData),
            name: NSNotification.Name("RatingAdded"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔍 viewWillAppear - providerId: \(providerId ?? "nil"), providerName: \(providerName)")
        fetchRatingsData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Rating and Reviews"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // Navigation bar
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
        guard let tableView = tableView else { return }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    }
    
    @objc private func fetchRatingsData() {
        guard let providerId = providerId else {
            print("⚠️ Provider ID is missing")
            updateHeader()
            return
        }
        
        print("🔍 Fetching ratings for provider: \(providerId)")
        
        RatingService.shared.fetchRatingsForProvider(providerId: providerId) { [weak self] (fetchedRatings, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching ratings: \(error.localizedDescription)")
                    return
                }
                
                print("✅ Fetched \(fetchedRatings.count) ratings for provider: \(self.providerName)")
                self.ratings = fetchedRatings
                self.updateHeader()
                self.tableView?.reloadData()
            }
        }
    }
    
    private func updateHeader() {
        let totalCount = ratings.count
        
        print("📊 Updating header - Provider: \(providerName), Total ratings: \(totalCount)")
        
        // Update provider name in title or add a label
        title = "\(providerName) - Reviews"
        
        // Update total count
        totalRatingsLabel?.text = "\(totalCount) ratings"
        
        // Calculate and update average
        if totalCount > 0 {
            let totalStars = ratings.reduce(0.0) { $0 + $1.stars }
            let average = totalStars / Double(totalCount)
            averageRatingLabel?.text = String(format: "%.1f", average)
            print("⭐ Average rating: \(average)")
        } else {
            averageRatingLabel?.text = "0.0"
            print("⭐ No ratings yet")
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension RatingsReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ratings.isEmpty {
            // Show empty state
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
            emptyLabel.text = "No reviews yet\nBe the first to review!"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .gray
            emptyLabel.numberOfLines = 2
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            tableView.backgroundView = emptyLabel
        } else {
            tableView.backgroundView = nil
        }
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingTableViewCell
        cell.configure(with: ratings[indexPath.row])
        return cell
    }
}
