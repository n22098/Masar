import UIKit

class RatingsReviewsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        return tv
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let averageRatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        label.text = "0.0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let totalRatingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        label.text = "0 ratings"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private var ratings: [Rating] = []
    var providerId: String?
    var providerName: String = "Provider"
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupHeaderStars()
        fetchRatingsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRatingsData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Rating and Reviews"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // Navigation Bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 240))
        containerView.backgroundColor = .clear
        
        containerView.addSubview(headerView)
        headerView.addSubview(profileImageView)
        headerView.addSubview(providerNameLabel)
        headerView.addSubview(averageRatingLabel)
        headerView.addSubview(starsStackView)
        headerView.addSubview(totalRatingsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            providerNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            providerNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            averageRatingLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 12),
            averageRatingLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: averageRatingLabel.bottomAnchor, constant: 8),
            starsStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 24),
            
            totalRatingsLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 8),
            totalRatingsLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            totalRatingsLabel.bottomAnchor.constraint(lessThanOrEqualTo: headerView.bottomAnchor, constant: -20)
        ])
        
        tableView.tableHeaderView = containerView
        providerNameLabel.text = providerName
    }
    
    private func setupHeaderStars() {
        for _ in 0..<5 {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "star.fill")
            imageView.tintColor = .systemGray4
            imageView.contentMode = .scaleAspectFit
            starsStackView.addArrangedSubview(imageView)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "RatingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    // MARK: - Data Fetching
    @objc private func fetchRatingsData() {
        guard let providerId = providerId else {
            print("⚠️ [RatingsReviewsVC] Provider ID is missing")
            updateHeader()
            return
        }
        
        print("🔍 [RatingsReviewsVC] Fetching ratings for provider: \(providerId)")
        
        RatingService.shared.fetchRatingsForProvider(providerId: providerId) { [weak self] (fetchedRatings, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ [RatingsReviewsVC] Error: \(error.localizedDescription)")
                    return
                }
                
                print("✅ [RatingsReviewsVC] Fetched \(fetchedRatings.count) ratings")
                self.ratings = fetchedRatings
                self.updateHeader()
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateHeader() {
        let totalCount = ratings.count
        totalRatingsLabel.text = "\(totalCount) rating\(totalCount == 1 ? "" : "s")"
        
        if totalCount > 0 {
            let totalStars = ratings.reduce(0.0) { $0 + $1.stars }
            let average = totalStars / Double(totalCount)
            averageRatingLabel.text = String(format: "%.1f", average)
            updateHeaderStars(rating: average)
        } else {
            averageRatingLabel.text = "0.0"
            updateHeaderStars(rating: 0.0)
        }
    }
    
    private func updateHeaderStars(rating: Double) {
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let imageView = view as? UIImageView else { continue }
            let starValue = Double(index) + 1.0
            
            if rating >= starValue {
                imageView.image = UIImage(systemName: "star.fill")
                imageView.tintColor = .systemYellow
            } else if rating >= starValue - 0.5 {
                imageView.image = UIImage(systemName: "star.leadinghalf.filled")
                imageView.tintColor = .systemYellow
            } else {
                imageView.image = UIImage(systemName: "star.fill")
                imageView.tintColor = .systemGray4
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension RatingsReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ratings.isEmpty {
            let emptyView = createEmptyView()
            tableView.backgroundView = emptyView
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
    
    private func createEmptyView() -> UIView {
        let emptyView = UIView(frame: tableView.bounds)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        imageView.image = UIImage(systemName: "star.circle", withConfiguration: config)
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "No Reviews Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .darkGray
        
        let messageLabel = UILabel()
        messageLabel.text = "Be the first to review this provider!"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        emptyView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -50),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: emptyView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: emptyView.trailingAnchor, constant: -40)
        ])
        
        return emptyView
    }
}
