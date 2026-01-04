import UIKit
import FirebaseFirestore
import FirebaseStorage

class ServicesController: UITableViewController {

    // MARK: - Properties
    var providerName: String?
    var providerID: String?
    // لا نحتاج providerImage هنا كمتغير استقبال، بل كمتغير للعرض من الـ ImageView
    
    // Model to hold service data
    struct ServiceModel {
        let id: String
        let name: String
        let price: String
        let description: String
    }
    
    var services: [ServiceModel] = []
    private let db = Firestore.firestore()
    
    // Store provider data for editing
    private var providerData: [String: Any] = [:]
    
    // Header UI Elements
    private let headerHeight: CGFloat = 300
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()
    private let companyLabel = UILabel()
    private let phoneLabel = UILabel()
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchProviderDetails()
        loadServices()
        setupEditButton()
    }
    
    // MARK: - Setup Edit Button
    private func setupEditButton() {
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(editProviderProfile)
        )
        navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: - Edit Provider Profile
    @objc private func editProviderProfile() {
        guard let pID = providerID else {
            showAlert(title: "Error", message: "Provider ID not found")
            return
        }
        
        let alert = UIAlertController(title: "Edit Provider Profile", message: "Update provider information", preferredStyle: .alert)
        
        // Name field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.text = self.nameLabel.text
        }
        
        // Category field
        alert.addTextField { textField in
            textField.placeholder = "Category/Role"
            textField.text = self.categoryLabel.text
        }
        
        // Company field
        alert.addTextField { textField in
            textField.placeholder = "Company Type"
            textField.text = self.companyLabel.text
        }
        
        // Phone field
        alert.addTextField { textField in
            textField.placeholder = "Phone"
            textField.keyboardType = .phonePad
            if let phoneLabel = self.tableView.tableHeaderView?.viewWithTag(999) as? UILabel {
                textField.text = phoneLabel.text
            }
        }
        
        // Profile Image URL field
        alert.addTextField { textField in
            textField.placeholder = "Profile Image URL (optional)"
            textField.text = self.providerData["profileImageURL"] as? String
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        // Update action
        alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let newName = alert.textFields?[0].text ?? ""
            let newCategory = alert.textFields?[1].text ?? ""
            let newCompany = alert.textFields?[2].text ?? ""
            let newPhone = alert.textFields?[3].text ?? ""
            let newImageURL = alert.textFields?[4].text ?? ""
            
            // Validate required fields
            if newName.isEmpty {
                self.showAlert(title: "Error", message: "Name cannot be empty")
                return
            }
            
            // Prepare update data
            var updateData: [String: Any] = [
                "name": newName,
                "category": newCategory,
                "phone": newPhone
            ]
            
            // Add image URL if provided and valid
            if !newImageURL.isEmpty {
                updateData["profileImageURL"] = newImageURL
            }
            
            // Update Firestore
            self.db.collection("provider_requests").document(pID).updateData(updateData) { error in
                if let error = error {
                    self.showAlert(title: "Update Failed", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "Success", message: "Provider profile updated successfully")
                    // Refresh the data
                    self.fetchProviderDetails()
                }
            }
        })
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Helper method to show alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupTableView() {
        self.title = "Services Admin"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // Register the custom card cell
        tableView.register(AdminServiceCell.self, forCellReuseIdentifier: "AdminServiceCell")
        
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
        headerView.backgroundColor = .clear
        
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 6
        cardView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(cardView)
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray5
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = customPurple.withAlphaComponent(0.3).cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        // Set a default placeholder image
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        profileImageView.tintColor = .systemGray3
        cardView.addSubview(profileImageView)
        
        nameLabel.text = providerName ?? "Provider"
        nameLabel.font = .boldSystemFont(ofSize: 22)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.text = "Loading..."
        categoryLabel.font = .systemFont(ofSize: 14, weight: .medium)
        categoryLabel.textColor = .darkGray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        companyLabel.text = "Freelancer"
        companyLabel.font = .systemFont(ofSize: 12)
        companyLabel.textColor = customPurple
        companyLabel.numberOfLines = 1
        companyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(nameLabel)
        cardView.addSubview(categoryLabel)
        cardView.addSubview(companyLabel)
        
        // Star Icon Container
        let starContainer = UIView()
        starContainer.backgroundColor = UIColor(red: 255/255, green: 249/255, blue: 235/255, alpha: 1.0)
        starContainer.layer.cornerRadius = 8
        starContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Enable Tap Interaction
        starContainer.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapStar))
        starContainer.addGestureRecognizer(tapGesture)
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .systemYellow
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starContainer.addSubview(starIcon)
        cardView.addSubview(starContainer)
        
        // Info Row
        let infoStack = UIStackView()
        infoStack.axis = .horizontal
        infoStack.distribution = .fillEqually
        infoStack.spacing = 10
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        let box1 = createInfoBox(icon: "clock.fill", text: "Available")
        let box2 = createInfoBox(icon: "info.circle.fill", text: "Online")
        let box3 = createInfoBox(icon: "phone.fill", text: "Loading...")
        if let stack = box3.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
           let label = stack.arrangedSubviews.last as? UILabel {
             label.tag = 999
        }
        
        infoStack.addArrangedSubview(box1)
        infoStack.addArrangedSubview(box2)
        infoStack.addArrangedSubview(box3)
        cardView.addSubview(infoStack)
        
        // Action Buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let portfolioBtn = createActionButton(title: "Portfolio", icon: "briefcase.fill", isFilled: true)
        portfolioBtn.addTarget(self, action: #selector(didTapPortfolio), for: .touchUpInside)
        
        let statsBtn = createActionButton(title: "Stats", icon: "chart.bar.fill", isFilled: false)
        statsBtn.addTarget(self, action: #selector(didTapStats), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(portfolioBtn)
        buttonStack.addArrangedSubview(statsBtn)
        cardView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10),
            
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: starContainer.leadingAnchor, constant: -8),
            
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            companyLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            companyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            companyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            starContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            starContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            starContainer.widthAnchor.constraint(equalToConstant: 40),
            starContainer.heightAnchor.constraint(equalToConstant: 40),
            starIcon.centerXAnchor.constraint(equalTo: starContainer.centerXAnchor),
            starIcon.centerYAnchor.constraint(equalTo: starContainer.centerYAnchor),
            
            infoStack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            infoStack.heightAnchor.constraint(equalToConstant: 50),
            
            buttonStack.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Button Actions
    
    // ⭐️ Navigation to ratings view
    @objc func didTapStar() {
        print("⭐️ Star tapped! Opening ratings view")
        
        let ratingsVC = AdminRatingsViewController()
        ratingsVC.providerID = self.providerID
        ratingsVC.providerName = self.providerName
        
        // ✅ تمرير الصورة الحالية
        ratingsVC.providerImage = self.profileImageView.image
        
        navigationController?.pushViewController(ratingsVC, animated: true)
    }
    
    // 💼 Navigation to Portfolio
    @objc func didTapPortfolio() {
        print("💼 Portfolio tapped! Opening portfolio view")
        
        let portfolioVC = AdminPortfolioViewController()
        portfolioVC.providerID = self.providerID
        portfolioVC.providerName = self.providerName
        navigationController?.pushViewController(portfolioVC, animated: true)
    }
    
    // 📊 Navigation to Stats
    @objc func didTapStats() {
        print("📊 Stats tapped! Opening stats view")
        
        let statsVC = AdminStatsViewController()
        statsVC.providerID = self.providerID
        statsVC.providerName = self.providerName
        statsVC.totalServices = services.count
        navigationController?.pushViewController(statsVC, animated: true)
    }
    
    private func createInfoBox(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 250/255, alpha: 1.0)
        container.layer.cornerRadius = 8
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = customPurple
        iv.contentMode = .scaleAspectFit
        iv.heightAnchor.constraint(equalToConstant: 16).isActive = true
        iv.widthAnchor.constraint(equalToConstant: 16).isActive = true
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = .darkGray
        stack.addArrangedSubview(iv)
        stack.addArrangedSubview(lbl)
        container.addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        return container
    }
    
    private func createActionButton(title: String, icon: String, isFilled: Bool) -> UIButton {
        var config = isFilled ? UIButton.Configuration.filled() : UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: icon)
        config.imagePadding = 6
        config.cornerStyle = .medium
        if isFilled {
            config.baseBackgroundColor = customPurple
            config.baseForegroundColor = .white
        } else {
            config.background.strokeColor = customPurple
            config.background.strokeWidth = 1
            config.baseForegroundColor = customPurple
        }
        return UIButton(configuration: config)
    }
    
    // MARK: - Fetch Data (Fixed & Cleaned)
    func fetchProviderDetails() {
        guard let pID = providerID else {
            print("❌ Error: providerID is nil")
            return
        }
        
        print("🔍 Fetching details for Provider ID: \(pID)")
        
        db.collection("provider_requests").document(pID).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            // 1. Check for Errors
            if let error = error {
                print("❌ Firestore Error: \(error.localizedDescription)")
                return
            }
            
            // 2. Check Document Existence
            guard let document = document, document.exists, let data = document.data() else {
                print("❌ Document does not exist or has no data")
                return
            }
            
            print("✅ Document Data Found: \(data)")
            
            // Store data for editing later
            self.providerData = data
            
            // ------------------------------------------
            // 🛠️ ENHANCED IMAGE LOADING - Try multiple fields and clean URLs
            // ------------------------------------------
            var imageURLString: String? = nil
            
            // Try all possible image field names
            let imageKeys = ["profileImageURL", "imageURL", "image", "photoURL", "photo", "profileImage", "avatar"]
            
            for key in imageKeys {
                if let rawURL = data[key] as? String, !rawURL.isEmpty {
                    // Clean the URL thoroughly
                    var cleanString = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Remove brackets, quotes, and other problematic characters
                    cleanString = cleanString.replacingOccurrences(of: "[", with: "")
                    cleanString = cleanString.replacingOccurrences(of: "]", with: "")
                    cleanString = cleanString.replacingOccurrences(of: "\"", with: "")
                    cleanString = cleanString.replacingOccurrences(of: "'", with: "")
                    cleanString = cleanString.replacingOccurrences(of: " ", with: "")
                    
                    if !cleanString.isEmpty {
                        imageURLString = cleanString
                        print("🧹 Found image URL in '\(key)': \(imageURLString!)")
                        break
                    }
                }
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Name
                if let name = data["name"] as? String {
                    self.nameLabel.text = name
                }
                
                // Category Logic
                if let category = data["category"] as? String, !category.isEmpty {
                    self.categoryLabel.text = category
                } else if let role = data["role"] as? String, !role.isEmpty {
                    self.categoryLabel.text = role.capitalized
                } else {
                    self.categoryLabel.text = "Freelancer"
                }
                
                // Phone
                if let phone = data["phone"] as? String,
                   let phoneLabel = self.tableView.tableHeaderView?.viewWithTag(999) as? UILabel {
                    phoneLabel.text = phone
                }
            }
            
            // Load the image if a valid string was found
            if let urlString = imageURLString {
                // Check if it's a full HTTP/HTTPS URL or Firebase Storage path
                if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                    if let url = URL(string: urlString) {
                        print("🔄 Loading image from direct URL: \(url)")
                        self.downloadImage(from: url)
                    } else {
                        print("⚠️ Invalid URL format: \(urlString)")
                        self.setPlaceholderImage()
                    }
                } else {
                    // Assume it's a Firebase Storage path
                    print("🔄 Loading image from Firebase Storage path: \(urlString)")
                    self.loadImageFromFirebaseStorage(path: urlString)
                }
            } else {
                print("⚠️ No image URL found in any field")
                self.setPlaceholderImage()
            }
        }
    }
    
    // Helper to set placeholder image
    private func setPlaceholderImage() {
        DispatchQueue.main.async {
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            self.profileImageView.tintColor = .systemGray3
            self.profileImageView.contentMode = .scaleAspectFit
        }
    }
    
    // Load image from Firebase Storage
    private func loadImageFromFirebaseStorage(path: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(path)
        
        print("📦 Fetching from Firebase Storage: \(path)")
        
        // Download URL
        imageRef.downloadURL { [weak self] url, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Firebase Storage error: \(error.localizedDescription)")
                self.setPlaceholderImage()
                return
            }
            
            if let url = url {
                print("✅ Got download URL from Firebase Storage: \(url.absoluteString)")
                self.downloadImage(from: url)
            } else {
                self.setPlaceholderImage()
            }
        }
    }
    
    // Helper to download image from URL
    private func downloadImage(from url: URL) {
        print("🔄 Downloading image from: \(url.absoluteString)")
        
        // Show loading state
        DispatchQueue.main.async {
            self.profileImageView.image = UIImage(systemName: "photo.circle.fill")
            self.profileImageView.tintColor = .systemGray4
            self.profileImageView.contentMode = .scaleAspectFit
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Download failed: \(error.localizedDescription)")
                self.setPlaceholderImage()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ HTTP error: \(httpResponse.statusCode)")
                    self.setPlaceholderImage()
                    return
                }
            }
            
            guard let data = data, !data.isEmpty else {
                print("❌ No data received")
                self.setPlaceholderImage()
                return
            }
            
            print("📦 Received \(data.count) bytes")
            
            guard let image = UIImage(data: data) else {
                print("❌ Cannot create image from data")
                self.setPlaceholderImage()
                return
            }
            
            DispatchQueue.main.async {
                print("✅ Image loaded successfully! Size: \(image.size)")
                self.profileImageView.image = image
                self.profileImageView.contentMode = .scaleAspectFill
                self.profileImageView.tintColor = nil
            }
        }.resume()
    }
    
    func loadServices() {
        guard let pID = providerID else { return }
        
        db.collection("services")
            .whereField("providerId", isEqualTo: pID)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let err = error {
                    print("❌ Error fetching services: \(err.localizedDescription)")
                    return
                }
                
                self.services = []
                
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        
                        let name = data["title"] as? String ?? data["name"] as? String ?? "No Name"
                        var priceString = "0.000"
                        if let priceNum = data["price"] as? NSNumber {
                            priceString = String(format: "%.3f", priceNum.doubleValue)
                        } else if let priceStr = data["price"] as? String {
                            priceString = priceStr
                        }
                        
                        let desc = data["description"] as? String ?? "No description available."
                        
                        let service = ServiceModel(id: doc.documentID, name: name, price: priceString, description: desc)
                        self.services.append(service)
                    }
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminServiceCell", for: indexPath) as? AdminServiceCell else {
            return UITableViewCell()
        }
        
        let service = services[indexPath.row]
        cell.configure(model: service)
        
        cell.editAction = { [weak self] in
            self?.showEditServiceAlert(for: indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: - Admin Edit Logic
    func showEditServiceAlert(for index: Int) {
        let service = services[index]
        let alert = UIAlertController(title: "Edit Service", message: nil, preferredStyle: .alert)
        
        alert.addTextField { $0.text = service.name; $0.placeholder = "Service Title" }
        alert.addTextField { $0.text = service.price; $0.placeholder = "Price" }
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let newName = alert.textFields?[0].text ?? service.name
            let newPriceString = alert.textFields?[1].text ?? service.price
            let newPriceNumber = Double(newPriceString) ?? 0.0
            
            self.db.collection("services").document(service.id).updateData([
                "title": newName,
                "price": newPriceNumber
            ])
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.db.collection("services").document(service.id).delete()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Admin Portfolio View Controller
class AdminPortfolioViewController: UIViewController {
    
    var providerID: String?
    var providerName: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    private var portfolioData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Portfolio"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        setupUI()
        fetchPortfolioFromFirebase()
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func fetchPortfolioFromFirebase() {
        guard let pID = providerID else {
            print("❌ No provider ID")
            displayEmptyState()
            return
        }
        
        print("🔍 Fetching portfolio for provider: \(pID)")
        
        // Try multiple possible collections
        let possibleCollections = ["portfolios", "portfolio", "provider_portfolios"]
        
        fetchFromCollection(collections: possibleCollections, providerID: pID, index: 0)
    }
    
    private func fetchFromCollection(collections: [String], providerID: String, index: Int) {
        guard index < collections.count else {
            print("⚠️ No portfolio found in any collection")
            displayEmptyState()
            return
        }
        
        let collectionName = collections[index]
        print("🔍 Trying collection: \(collectionName)")
        
        db.collection(collectionName).document(providerID).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error in \(collectionName): \(error.localizedDescription)")
                self.fetchFromCollection(collections: collections, providerID: providerID, index: index + 1)
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                print("✅ Found portfolio in '\(collectionName)': \(data.keys.sorted())")
                self.portfolioData = data
                DispatchQueue.main.async {
                    self.displayPortfolio()
                }
            } else {
                print("⚠️ No document in \(collectionName), trying next...")
                self.fetchFromCollection(collections: collections, providerID: providerID, index: index + 1)
            }
        }
    }
    
    private func displayPortfolio() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var lastView: UIView?
        
        // About Me Section
        let aboutMe = portfolioData["aboutMe"] as? String ?? portfolioData["about"] as? String ?? ""
        if !aboutMe.isEmpty {
            let aboutSection = createSection(title: "About me", content: aboutMe, topAnchor: contentView.topAnchor)
            contentView.addSubview(aboutSection)
            lastView = aboutSection
        }
        
        // Skills Section
        let skills = portfolioData["skills"] as? String ?? portfolioData["skill"] as? String ?? ""
        if !skills.isEmpty {
            let skillsSection = createSection(
                title: "Skills",
                content: skills,
                topAnchor: lastView?.bottomAnchor ?? contentView.topAnchor,
                topConstant: lastView != nil ? 20 : 20
            )
            contentView.addSubview(skillsSection)
            lastView = skillsSection
        }
        
        // Portfolio Items / Images
        var portfolioItems: [[String: Any]] = []
        
        // Try different field names
        if let items = portfolioData["items"] as? [[String: Any]] {
            portfolioItems = items
        } else if let images = portfolioData["images"] as? [[String: Any]] {
            portfolioItems = images
        } else if let files = portfolioData["files"] as? [[String: Any]] {
            portfolioItems = files
        } else if let uploads = portfolioData["uploads"] as? [[String: Any]] {
            portfolioItems = uploads
        }
        
        if !portfolioItems.isEmpty {
            let itemsLabel = UILabel()
            itemsLabel.text = "Portfolio Items"
            itemsLabel.font = .boldSystemFont(ofSize: 20)
            itemsLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(itemsLabel)
            
            NSLayoutConstraint.activate([
                itemsLabel.topAnchor.constraint(equalTo: (lastView?.bottomAnchor ?? contentView.topAnchor), constant: 30),
                itemsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
            ])
            lastView = itemsLabel
            
            for item in portfolioItems {
                let itemView = createPortfolioItemView(item: item)
                contentView.addSubview(itemView)
                
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: lastView!.bottomAnchor, constant: 12),
                    itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
                ])
                
                lastView = itemView
            }
        }
        
        if lastView != nil {
            lastView!.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        } else {
            displayEmptyState()
        }
    }
    
    private func createSection(title: String, content: String, topAnchor: NSLayoutYAxisAnchor, topConstant: CGFloat = 20) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func createPortfolioItemView(item: [String: Any]) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Try to get item details
        let name = item["name"] as? String ?? item["fileName"] as? String ?? item["title"] as? String ?? "Portfolio Item"
        let type = item["type"] as? String ?? item["fileType"] as? String ?? "file"
        let urlString = item["url"] as? String ?? item["imageUrl"] as? String ?? item["downloadURL"] as? String
        
        // Check if it's an image type
        let isImage = type.lowercased().contains("image") ||
                     name.lowercased().hasSuffix(".jpg") ||
                     name.lowercased().hasSuffix(".jpeg") ||
                     name.lowercased().hasSuffix(".png")
        
        if isImage, let urlString = urlString {
            // Create image view for portfolio item
            return createImagePortfolioCard(name: name, urlString: urlString)
        } else {
            // Create file card
            return createFilePortfolioCard(name: name, type: type)
        }
    }
    
    private func createImagePortfolioCard(name: String, urlString: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 14)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(imageView)
        card.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 220),
            
            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 160),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
        
        // Load image
        loadPortfolioImage(urlString: urlString, into: imageView)
        
        return card
    }
    
    private func createFilePortfolioCard(name: String, type: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 4
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        switch type.lowercased() {
        case "image":
            iconView.image = UIImage(systemName: "photo.fill")
            iconView.tintColor = customPurple
        case "video":
            iconView.image = UIImage(systemName: "video.fill")
            iconView.tintColor = .systemPurple
        case "document", "doc", "pdf":
            iconView.image = UIImage(systemName: "doc.fill")
            iconView.tintColor = .systemIndigo
        default:
            iconView.image = UIImage(systemName: "paperclip")
            iconView.tintColor = .systemGray
        }
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let typeLabel = UILabel()
        typeLabel.text = type.capitalized
        typeLabel.font = .systemFont(ofSize: 13)
        typeLabel.textColor = .gray
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(nameLabel)
        card.addSubview(typeLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 70),
            
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            typeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4)
        ])
        
        return card
    }
    
    private func loadPortfolioImage(urlString: String, into imageView: UIImageView) {
        print("🖼️ Loading portfolio image: \(urlString)")
        
        // Check if it's HTTP URL or Firebase Storage path
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            // Direct URL
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("❌ Image load error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Invalid image data")
                    return
                }
                
                DispatchQueue.main.async {
                    imageView.image = image
                    print("✅ Portfolio image loaded")
                }
            }.resume()
        } else {
            // Firebase Storage path
            let storageRef = storage.reference().child(urlString)
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Firebase Storage error: \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else { return }
                
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        imageView.image = image
                        print("✅ Portfolio image loaded from Firebase Storage")
                    }
                }.resume()
            }
        }
    }
    
    private func displayEmptyState() {
        DispatchQueue.main.async {
            let label = UILabel()
            label.text = "📁 No portfolio data found\n\nThe provider hasn't uploaded any portfolio information yet."
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 40),
                label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -40),
                label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
            ])
        }
    }
}

// MARK: - Admin Stats View Controller
class AdminStatsViewController: UIViewController {
    
    var providerID: String?
    var providerName: String?
    var totalServices: Int = 0
    
    private let db = Firestore.firestore()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    private var statsData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        setupUI()
        setupEditButton()
        fetchStats()
    }
    
    private func setupEditButton() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editStats))
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func editStats() {
        let alert = UIAlertController(title: "Edit Statistics", message: "Update provider statistics", preferredStyle: .alert)
        
        alert.addTextField { $0.placeholder = "Average Rating (0-5)"; $0.keyboardType = .decimalPad; $0.text = self.statsData["averageRating"] as? String ?? "0.0" }
        alert.addTextField { $0.placeholder = "Response Time (e.g., 2 hrs)"; $0.text = self.statsData["responseTime"] as? String ?? "N/A" }
        alert.addTextField { $0.placeholder = "Completed Jobs"; $0.keyboardType = .numberPad; $0.text = "\(self.statsData["completedJobs"] as? Int ?? 0)" }
        alert.addTextField { $0.placeholder = "Total Earnings (BHD)"; $0.keyboardType = .decimalPad; $0.text = self.statsData["totalEarnings"] as? String ?? "0.000" }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let pID = self.providerID else { return }
            
            let rating = alert.textFields?[0].text ?? "0.0"
            let responseTime = alert.textFields?[1].text ?? "N/A"
            let completed = Int(alert.textFields?[2].text ?? "0") ?? 0
            let earnings = alert.textFields?[3].text ?? "0.000"
            
            let updateData: [String: Any] = [
                "averageRating": rating,
                "responseTime": responseTime,
                "completedJobs": completed,
                "totalEarnings": earnings,
                "totalServices": self.totalServices
            ]
            
            self.db.collection("provider_stats").document(pID).setData(updateData, merge: true) { error in
                if let error = error {
                    print("❌ Error updating stats: \(error.localizedDescription)")
                } else {
                    print("✅ Stats updated successfully")
                    self.fetchStats()
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func fetchStats() {
        guard let pID = providerID else { return }
        
        db.collection("provider_stats").document(pID).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists, let data = document.data() {
                self.statsData = data
            } else {
                // Set default stats
                self.statsData = [
                    "averageRating": "0.0",
                    "responseTime": "N/A",
                    "completedJobs": 0,
                    "totalEarnings": "0.000",
                    "totalServices": self.totalServices
                ]
            }
            
            DispatchQueue.main.async {
                self.displayStats()
            }
        }
    }
    
    private func displayStats() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let rating = statsData["averageRating"] as? String ?? "0.0"
        let responseTime = statsData["responseTime"] as? String ?? "N/A"
        let completed = statsData["completedJobs"] as? Int ?? 0
        let earnings = statsData["totalEarnings"] as? String ?? "0.000"
        
        let statsArray = [
            ("briefcase.fill", "Total Services", "\(totalServices)", customPurple),
            ("star.fill", "Average Rating", rating, UIColor.systemYellow),
            ("clock.fill", "Response Time", responseTime, UIColor.systemGreen),
            ("checkmark.circle.fill", "Completed", "\(completed)", UIColor.systemPurple),
            ("dollarsign.circle.fill", "Total Earnings", "BHD \(earnings)", UIColor.systemOrange)
        ]
        
        var lastCard: UIView?
        
        for (icon, title, value, color) in statsArray {
            let card = createStatCard(icon: icon, title: title, value: value, color: color)
            contentView.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                card.heightAnchor.constraint(equalToConstant: 100)
            ])
            
            if let previous = lastCard {
                card.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 16).isActive = true
            } else {
                card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            }
            
            lastCard = card
        }
        
        if let lastCard = lastCard {
            lastCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    private func createStatCard(icon: String, title: String, value: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .boldSystemFont(ofSize: 28)
        valueLabel.textColor = .black
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 25),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        
        return card
    }
}

// MARK: - Admin Ratings View Controller
class AdminRatingsViewController: UIViewController {
    
    var providerID: String?
    var providerName: String?
    
    // ✅ 1. متغير لاستقبال الصورة
    var providerImage: UIImage?
    
    private let db = Firestore.firestore()
    private var ratings: [(id: String, data: [String: Any])] = []
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    private let tableView = UITableView()
    private let headerView = UIView()
    private let profileIconView = UIImageView()
    private let averageRatingLabel = UILabel()
    private let totalRatingsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rating and Reviews"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        setupHeaderView()
        setupTableView()
        fetchRatings()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // ✅ 2. استخدام الصورة المستلمة
        if let image = providerImage {
            profileIconView.image = image
            profileIconView.contentMode = .scaleAspectFill
        } else {
            profileIconView.image = UIImage(systemName: "person.circle.fill")
            profileIconView.contentMode = .scaleAspectFit
        }
        
        profileIconView.tintColor = customPurple
        profileIconView.clipsToBounds = true
        profileIconView.layer.cornerRadius = 40
        profileIconView.layer.borderWidth = 3
        profileIconView.layer.borderColor = customPurple.cgColor
        profileIconView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(profileIconView)
        
        // Average rating
        averageRatingLabel.text = "0.0"
        averageRatingLabel.font = .boldSystemFont(ofSize: 32)
        averageRatingLabel.textAlignment = .left
        averageRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(averageRatingLabel)
        
        // Total ratings count
        totalRatingsLabel.text = "0 ratings"
        totalRatingsLabel.font = .systemFont(ofSize: 16)
        totalRatingsLabel.textColor = .gray
        totalRatingsLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(totalRatingsLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            profileIconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            profileIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileIconView.widthAnchor.constraint(equalToConstant: 80),
            profileIconView.heightAnchor.constraint(equalToConstant: 80),
            
            averageRatingLabel.leadingAnchor.constraint(equalTo: profileIconView.trailingAnchor, constant: 20),
            averageRatingLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            
            totalRatingsLabel.leadingAnchor.constraint(equalTo: averageRatingLabel.leadingAnchor),
            totalRatingsLabel.topAnchor.constraint(equalTo: averageRatingLabel.bottomAnchor, constant: 4)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchRatings() {
        guard let pID = providerID else {
            print("❌ providerID is nil")
            return
        }
        
        print("🔍 Fetching ratings for provider: \(pID) from 'Rating' collection")
        
        db.collection("Rating")
            .whereField("providerId", isEqualTo: pID)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching ratings: \(error.localizedDescription)")
                    return
                }
                
                print("📊 Found \(snapshot?.documents.count ?? 0) ratings")
                
                self.ratings = snapshot?.documents.map { doc in
                    print("📝 Rating document: \(doc.documentID) - Data: \(doc.data())")
                    return (id: doc.documentID, data: doc.data())
                } ?? []
                
                DispatchQueue.main.async {
                    self.updateHeaderStats()
                    self.tableView.reloadData()
                    print("✅ Table view reloaded with \(self.ratings.count) ratings")
                }
            }
    }
    
    private func updateHeaderStats() {
        let count = ratings.count
        
        if count == 0 {
            averageRatingLabel.text = "0.0"
            totalRatingsLabel.text = "0 ratings"
        } else {
            let sum = ratings.reduce(0.0) { result, rating in
                let ratingValue = rating.data["stars"] as? Double ?? Double(rating.data["stars"] as? Int ?? 0)
                return result + ratingValue
            }
            let average = sum / Double(count)
            
            averageRatingLabel.text = String(format: "%.1f", average)
            totalRatingsLabel.text = "\(count) rating\(count == 1 ? "" : "s")"
        }
    }
    
    private func showRatingEditDialog(ratingID: String, existingData: [String: Any]) {
        let alert = UIAlertController(title: "Edit Rating", message: "Update rating details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "User Name"
            textField.text = existingData["username"] as? String ?? ""
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Rating (1-5)"
            textField.keyboardType = .numberPad
            let ratingValue = existingData["stars"] as? Int ?? 0
            textField.text = "\(ratingValue)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Comment"
            textField.text = existingData["feedback"] as? String ?? ""
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Booking Name"
            textField.text = existingData["bookingName"] as? String ?? ""
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let pID = self.providerID else { return }
            
            let userName = alert.textFields?[0].text ?? "Anonymous"
            let ratingText = alert.textFields?[1].text ?? "0"
            let ratingValue = Int(ratingText) ?? 0
            let comment = alert.textFields?[2].text ?? ""
            let bookingName = alert.textFields?[3].text ?? ""
            
            let validRating = max(1, min(5, ratingValue))
            
            var ratingData: [String: Any] = [
                "providerId": pID,
                "username": userName,
                "stars": validRating,
                "feedback": comment,
                "bookingName": bookingName,
                "date": existingData["date"] ?? Timestamp(date: Date())
            ]
            
            self.db.collection("Rating").document(ratingID).updateData(ratingData) { error in
                if let error = error {
                    print("❌ Error updating rating: \(error.localizedDescription)")
                } else {
                    print("✅ Rating updated successfully")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.db.collection("Rating").document(ratingID).delete() { error in
                if let error = error {
                    print("❌ Error deleting rating: \(error.localizedDescription)")
                } else {
                    print("✅ Rating deleted successfully")
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - Table View Delegate & Data Source
extension AdminRatingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            return UITableViewCell()
        }
        
        let rating = ratings[indexPath.row]
        cell.configure(with: rating.data)
        
        cell.editAction = { [weak self] in
            guard let self = self else { return }
            let ratingData = self.ratings[indexPath.row]
            self.showRatingEditDialog(ratingID: ratingData.id, existingData: ratingData.data)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - Custom Review Cell
class ReviewCell: UITableViewCell {
    
    var editAction: (() -> Void)?
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let starIconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let ratingValueLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let userNameLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var bookingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = customPurple
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .lightGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let commentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .darkGray
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var editButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Edit"
        config.image = UIImage(systemName: "pencil")
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.baseForegroundColor = customPurple
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        
        let btn = UIButton(configuration: config)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = customPurple.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapEdit() {
        editAction?()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(starIconLabel)
        containerView.addSubview(ratingValueLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(bookingLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(commentLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            starIconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            starIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            ratingValueLabel.centerYAnchor.constraint(equalTo: starIconLabel.centerYAnchor),
            ratingValueLabel.leadingAnchor.constraint(equalTo: starIconLabel.trailingAnchor, constant: 8),
            
            editButton.centerYAnchor.constraint(equalTo: starIconLabel.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            editButton.heightAnchor.constraint(equalToConstant: 32),
            
            userNameLabel.topAnchor.constraint(equalTo: starIconLabel.bottomAnchor, constant: 12),
            userNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            bookingLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            bookingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bookingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: bookingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            commentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with data: [String: Any]) {
        let ratingValue = data["stars"] as? Int ?? 0
        
        starIconLabel.text = "⭐"
        ratingValueLabel.text = "\(ratingValue).0"
        
        userNameLabel.text = data["username"] as? String ?? "Anonymous"
        
        if let bookingName = data["bookingName"] as? String, !bookingName.isEmpty {
            bookingLabel.text = "Booking: \(bookingName)"
            bookingLabel.isHidden = false
        } else {
            bookingLabel.isHidden = true
        }
        
        if let timestamp = data["date"] as? Timestamp {
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "Just now"
        }
        
        commentLabel.text = data["feedback"] as? String ?? "No comment"
    }
}

// MARK: - Custom Admin Cell
class AdminServiceCell: UITableViewCell {
    
    var editAction: (() -> Void)?
    
    // Custom purple color #6257E3
    private let customPurple = UIColor(red: 98/255, green: 87/255, blue: 227/255, alpha: 1.0)
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var iconBox: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 240/255, green: 242/255, blue: 255/255, alpha: 1.0)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "briefcase.fill")
        iv.tintColor = customPurple
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .black
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 15)
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let descLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .gray
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private lazy var editButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Edit"
        config.baseForegroundColor = customPurple
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        let btn = UIButton(configuration: config)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = customPurple.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func didTapEdit() {
        editAction?()
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconBox)
        iconBox.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconBox.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconBox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconBox.widthAnchor.constraint(equalToConstant: 48),
            iconBox.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconBox.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBox.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            descLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            editButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            editButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            editButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func configure(model: ServicesController.ServiceModel) {
        titleLabel.text = model.name
        priceLabel.text = "BHD \(model.price)"
        descLabel.text = model.description
    }
}
