/*import UIKit
import FirebaseFirestore

// MARK: - ServiceItemTableViewController
class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Properties
    var providerData: ServiceProviderModel?
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    private var isFavorite: Bool = false
    let db = Firestore.firestore()
    
    var services: [ServiceModel] {
        if let realServices = providerData?.services, !realServices.isEmpty {
            return realServices
        }
        return [
            ServiceModel(name: "Website Starter", price: 85.0, description: "Includes responsive design, basic contact form."),
            ServiceModel(name: "Business Website", price: 150.0, description: "Includes custom layout, database support.")
        ]
    }
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 350))
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        return view
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let skillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // تقييم
    private let ratingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.90, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor(red: 1.0, green: 0.70, blue: 0.0, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(red: 1.0, green: 0.70, blue: 0.0, alpha: 1.0)
        label.text = "0.0"
        return label
    }()
    
    // Label جديد لعدد التقييمات
    private let ratingsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor.darkGray
        label.text = "0 ratings"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Stack عمودي يحتوي على التقييم وعدد التقييمات
    private lazy var ratingVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingStackView, ratingsCountLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // --- الأزرار الثلاثة ---
    
    private lazy var viewPortfolioButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Portfolio", for: .normal)
        btn.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = brandColor
        btn.layer.cornerRadius = 12
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(viewPortfolioTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var viewStatisticsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stats", for: .normal)
        btn.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        btn.tintColor = brandColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(brandColor, for: .normal)
        btn.backgroundColor = brandColor.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 12
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(fetchRealStatsAndShow), for: .touchUpInside)
        return btn
    }()
    
    private lazy var chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chat", for: .normal)
        btn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        btn.tintColor = brandColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(brandColor, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [viewPortfolioButton, viewStatisticsButton, chatButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeaderView()
        populateData()
        setupRatingTapGesture()
        
        // جلب متوسط التقييم تلقائياً عند التحميل
        fetchAverageRating()
        
        tableView.register(ModernBookingCell.self, forCellReuseIdentifier: "ModernBookingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // تحديث التقييم في كل مرة تظهر فيها الصفحة
        fetchAverageRating()
    }
    
    // MARK: - Fetch Data Logic
    
    // دالة محدثة لحساب متوسط التقييم وعدد التقييمات
    private func fetchAverageRating() {
        guard let providerId = providerData?.id else { return }
        
        // ⚠️ تأكد أن اسم الكولكشن هنا يطابق ما لديك في فايربيس (ratings أو reviews)
        db.collection("ratings")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching ratings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    // إذا لم تكن هناك تقييمات
                    DispatchQueue.main.async {
                        self.ratingsCountLabel.text = "0 ratings"
                    }
                    return
                }
                
                var totalStars = 0.0
                for doc in documents {
                    if let stars = doc.data()["stars"] as? Double {
                        totalStars += stars
                    }
                }
                
                let average = totalStars / Double(documents.count)
                let count = documents.count
                
                DispatchQueue.main.async {
                    self.ratingLabel.text = String(format: "%.1f", average)
                    self.ratingsCountLabel.text = "\(count) rating\(count == 1 ? "" : "s")"
                }
            }
    }
    
    private func populateData() {
        guard let provider = providerData else { return }
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        skillsLabel.text = provider.skills.joined(separator: " • ")
        // القيمة المبدئية حتى يتم تحميل المتوسط الحقيقي
        ratingLabel.text = String(format: "%.1f", provider.rating)
        
        if let image = UIImage(named: provider.imageName) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = brandColor
        }
    }
    
    // MARK: - Setup UI
    private func setupRatingTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ratingTapped))
        ratingContainerView.addGestureRecognizer(tap)
        ratingContainerView.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        title = providerData?.role ?? "Services"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(menuTapped))
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
    }
    
    private func setupHeaderView() {
        headerView.addSubview(cardView)
        
        [profileImageView, nameLabel, roleLabel, skillsLabel, ratingContainerView, infoStackView, buttonsStackView].forEach { cardView.addSubview($0) }
        ratingContainerView.addSubview(ratingVerticalStack)
        
        let availabilityView = createInfoItem(icon: "clock.fill", text: providerData?.availability ?? "Sat-Thu")
        let locationView = createInfoItem(icon: "mappin.circle.fill", text: providerData?.location ?? "Online")
        let phoneView = createInfoItem(icon: "phone.fill", text: providerData?.phone ?? "Contact")
        
        [availabilityView, locationView, phoneView].forEach { infoStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            // البطاقة
            cardView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // الصورة
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // النصوص
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: -8),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            skillsLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 6),
            skillsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            skillsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // التقييم - محدث ليستوعب الـ stack العمودي
            ratingContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            ratingContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            ratingContainerView.widthAnchor.constraint(equalToConstant: 60),
            ratingContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            ratingVerticalStack.centerXAnchor.constraint(equalTo: ratingContainerView.centerXAnchor),
            ratingVerticalStack.centerYAnchor.constraint(equalTo: ratingContainerView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),
            
            // شريط المعلومات
            infoStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // الأزرار
            buttonsStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44),
            buttonsStackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createInfoItem(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        container.layer.cornerRadius = 8
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -6)
        ])
        return container
    }
    
    // MARK: - Actions
    @objc private func ratingTapped() {
        performSegue(withIdentifier: "showReviews", sender: providerData)
    }
    
    @objc private func menuTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share Provider", style: .default, handler: { _ in self.shareProvider() }))
        
        let favTitle = isFavorite ? "Remove from Favorites" : "Add to Favorites"
        alert.addAction(UIAlertAction(title: favTitle, style: .default, handler: { _ in self.toggleFavorite() }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    @objc private func chatTapped() {
        print("Opening chat...")
    }
    
    @objc private func viewPortfolioTapped() {
        performSegue(withIdentifier: "showPortfolio", sender: providerData)
    }
    
    private func shareProvider() {
        guard let provider = providerData else { return }
        let text = "Check out \(provider.name) on Masar!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        let message = isFavorite ? "✅ Added to Favorites!" : "❌ Removed from Favorites"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { alert.dismiss(animated: true) }
    }
    
    @objc private func fetchRealStatsAndShow() {
        let loadingAlert = UIAlertController(title: nil, message: "Fetching Stats...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        let providerId = providerData?.id ?? ""
        
        db.collection("bookings")
            .whereField("providerId", isEqualTo: providerId)
            .whereField("status", isEqualTo: "completed")
            .getDocuments { [weak self] (snapshot, error) in
                loadingAlert.dismiss(animated: true) {
                    let completedJobs = snapshot?.documents.count ?? 0
                    self?.showStatistics(jobs: completedJobs, rate: 95, repeatC: 40, time: 1)
                }
            }
    }
    
    private func showStatistics(jobs: Int, rate: Int, repeatC: Int, time: Int) {
        let statsVC = UIViewController()
        statsVC.modalPresentationStyle = .pageSheet
        if let sheet = statsVC.sheetPresentationController { sheet.detents = [.medium()] }
        
        let container = UIView()
        container.backgroundColor = .white
        statsVC.view = container
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: container.frame.width, height: 30))
        titleLabel.text = "📊 Provider Statistics (Live)"
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.autoresizingMask = [.flexibleWidth]
        container.addSubview(titleLabel)
        
        let info = "Jobs Done: \(jobs)\nSuccess Rate: \(rate)%\nResponse Time: \(time)h"
        let infoLabel = UILabel(frame: CGRect(x: 20, y: 70, width: 300, height: 100))
        infoLabel.text = info
        infoLabel.numberOfLines = 0
        container.addSubview(infoLabel)
        
        present(statsVC, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { services.count }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 120 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingCell", for: indexPath) as! ModernBookingCell
        let service = services[indexPath.row]
        cell.configure(title: service.name, price: service.price, description: service.description, icon: "briefcase.fill")
        cell.onBookingTapped = { [weak self] in
            self?.performSegue(withIdentifier: "showDetails", sender: service)
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails", let destVC = segue.destination as? ServiceInformationTableViewController, let service = sender as? ServiceModel {
            destVC.receivedServiceName = service.name
            destVC.receivedServicePrice = String(format: "BHD %.3f", service.price)
            destVC.receivedServiceDetails = service.description
            destVC.receivedServiceItems = service.addOns
            destVC.providerData = self.providerData
        } else if segue.identifier == "showPortfolio", let destVC = segue.destination as? ProviderPortfolioTableViewController {
            destVC.providerData = self.providerData
            destVC.isReadOnlyMode = true
        } else if segue.identifier == "showReviews", let destVC = segue.destination as? RatingsReviewsViewController {
            // إذا كنت تحتاج تمرير بيانات للتحقق من التقييمات
             // destVC.providerData = self.providerData
        }
    }
}
*/
import UIKit
import FirebaseFirestore

// MARK: - ServiceItemTableViewController
class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Properties
    var providerData: ServiceProviderModel?
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    private var isFavorite: Bool = false
    let db = Firestore.firestore()
    
    var services: [ServiceModel] {
        if let realServices = providerData?.services, !realServices.isEmpty {
            return realServices
        }
        return [
            ServiceModel(name: "Website Starter", price: 85.0, description: "Includes responsive design, basic contact form."),
            ServiceModel(name: "Business Website", price: 150.0, description: "Includes custom layout, database support.")
        ]
    }
    
    // MARK: - UI Components
    
    private lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 350))
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        return view
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 0.1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let skillsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // تقييم
    private let ratingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.90, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor(red: 1.0, green: 0.70, blue: 0.0, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(red: 1.0, green: 0.70, blue: 0.0, alpha: 1.0)
        label.text = "0.0"
        return label
    }()
    
    // Label جديد لعدد التقييمات
    private let ratingsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor.darkGray
        label.text = "0 ratings"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Stack عمودي يحتوي على التقييم وعدد التقييمات
    private lazy var ratingVerticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ratingStackView, ratingsCountLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // --- الأزرار الثلاثة ---
    
    private lazy var viewPortfolioButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Portfolio", for: .normal)
        btn.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = brandColor
        btn.layer.cornerRadius = 12
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(viewPortfolioTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var viewStatisticsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stats", for: .normal)
        btn.setImage(UIImage(systemName: "chart.bar.xaxis"), for: .normal)
        btn.tintColor = brandColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(brandColor, for: .normal)
        btn.backgroundColor = brandColor.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 12
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(fetchRealStatsAndShow), for: .touchUpInside)
        return btn
    }()
    
    private lazy var chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Chat", for: .normal)
        btn.setImage(UIImage(systemName: "message.fill"), for: .normal)
        btn.tintColor = brandColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(brandColor, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = brandColor.withAlphaComponent(0.3).cgColor
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [viewPortfolioButton, viewStatisticsButton, chatButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeaderView()
        populateData()
        setupRatingTapGesture()
        
        // جلب متوسط التقييم تلقائياً عند التحميل
        fetchAverageRating()
        
        tableView.register(ModernBookingCell.self, forCellReuseIdentifier: "ModernBookingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // تحديث التقييم في كل مرة تظهر فيها الصفحة
        fetchAverageRating()
    }
    
    // MARK: - Fetch Data Logic
    
    private func fetchAverageRating() {
        guard let providerId = providerData?.id else { return }
        
        // ⚠️ تأكد أن اسم الكولكشن هنا يطابق ما لديك في فايربيس (ratings أو reviews)
        db.collection("ratings")
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching ratings: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    // إذا لم تكن هناك تقييمات
                    DispatchQueue.main.async {
                        self.ratingsCountLabel.text = "0 ratings"
                    }
                    return
                }
                
                var totalStars = 0.0
                for doc in documents {
                    if let stars = doc.data()["stars"] as? Double {
                        totalStars += stars
                    }
                }
                
                let average = totalStars / Double(documents.count)
                let count = documents.count
                
                DispatchQueue.main.async {
                    self.ratingLabel.text = String(format: "%.1f", average)
                    self.ratingsCountLabel.text = "\(count) rating\(count == 1 ? "" : "s")"
                }
            }
    }
    
    private func populateData() {
        guard let provider = providerData else { return }
        nameLabel.text = provider.name
        roleLabel.text = provider.role
        skillsLabel.text = provider.skills.joined(separator: " • ")
        // القيمة المبدئية حتى يتم تحميل المتوسط الحقيقي
        ratingLabel.text = String(format: "%.1f", provider.rating)
        
        if let image = UIImage(named: provider.imageName) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = brandColor
        }
    }
    
    // MARK: - Setup UI
    private func setupRatingTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ratingTapped))
        ratingContainerView.addGestureRecognizer(tap)
        ratingContainerView.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        title = providerData?.role ?? "Services"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(menuTapped))
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
    }
    
    private func setupHeaderView() {
        headerView.addSubview(cardView)
        
        [profileImageView, nameLabel, roleLabel, skillsLabel, ratingContainerView, infoStackView, buttonsStackView].forEach { cardView.addSubview($0) }
        ratingContainerView.addSubview(ratingVerticalStack)
        
        let availabilityView = createInfoItem(icon: "clock.fill", text: providerData?.availability ?? "Sat-Thu")
        let locationView = createInfoItem(icon: "mappin.circle.fill", text: providerData?.location ?? "Online")
        let phoneView = createInfoItem(icon: "phone.fill", text: providerData?.phone ?? "Contact")
        
        [availabilityView, locationView, phoneView].forEach { infoStackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            // البطاقة
            cardView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // الصورة
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // النصوص
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: -8),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            skillsLabel.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 6),
            skillsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            skillsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // التقييم - محدث ليستوعب الـ stack العمودي
            ratingContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            ratingContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            ratingContainerView.widthAnchor.constraint(equalToConstant: 60),
            ratingContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            ratingVerticalStack.centerXAnchor.constraint(equalTo: ratingContainerView.centerXAnchor),
            ratingVerticalStack.centerYAnchor.constraint(equalTo: ratingContainerView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),
            
            // شريط المعلومات
            infoStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            infoStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // الأزرار
            buttonsStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            buttonsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44),
            buttonsStackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createInfoItem(icon: String, text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        container.layer.cornerRadius = 8
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = brandColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -6)
        ])
        return container
    }
    
    // MARK: - Actions
    @objc private func ratingTapped() {
        performSegue(withIdentifier: "showReviews", sender: providerData)
    }
    
    @objc private func menuTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Share Provider", style: .default, handler: { _ in self.shareProvider() }))
        
        let favTitle = isFavorite ? "Remove from Favorites" : "Add to Favorites"
        alert.addAction(UIAlertAction(title: favTitle, style: .default, handler: { _ in self.toggleFavorite() }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
    
    // 🔥 هذا هو التعديل الأساسي: الانتقال لصفحة الشات مع تمرير بيانات المزود 🔥
    @objc private func chatTapped() {
        // التحقق من وجود بيانات المزود
        guard let provider = providerData else { return }
        
        // 1. تحويل بيانات المزود (ServiceProviderModel) إلى بيانات مستخدم (User)
        // لأن شاشة الشات تتوقع كائن من نوع User
        let chatUser = User(
            id: provider.id,
            name: provider.name,
            email: "", // يمكن تركه فارغاً أو إضافته إذا كان متوفراً في بيانات المزود
            phone: provider.phone,
            profileImageName: provider.imageName
        )
        
        // 2. إنشاء كائن محادثة مؤقت
        let conversation = Conversation(
            id: provider.id, // استخدام معرف المزود كمعرف للمحادثة (لأنها محادثة خاصة)
            user: chatUser,
            lastMessage: "",
            lastUpdated: Date()
        )
        
        // 3. الانتقال إلى شاشة الشات
        let chatVC = ChatViewController(conversation: conversation)
        chatVC.hidesBottomBarWhenPushed = true // إخفاء الشريط السفلي أثناء الشات
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func viewPortfolioTapped() {
        performSegue(withIdentifier: "showPortfolio", sender: providerData)
    }
    
    private func shareProvider() {
        guard let provider = providerData else { return }
        let text = "Check out \(provider.name) on Masar!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        let message = isFavorite ? "✅ Added to Favorites!" : "❌ Removed from Favorites"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { alert.dismiss(animated: true) }
    }
    
    @objc private func fetchRealStatsAndShow() {
        let loadingAlert = UIAlertController(title: nil, message: "Fetching Stats...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        let providerId = providerData?.id ?? ""
        
        db.collection("bookings")
            .whereField("providerId", isEqualTo: providerId)
            .whereField("status", isEqualTo: "completed")
            .getDocuments { [weak self] (snapshot, error) in
                loadingAlert.dismiss(animated: true) {
                    let completedJobs = snapshot?.documents.count ?? 0
                    self?.showStatistics(jobs: completedJobs, rate: 95, repeatC: 40, time: 1)
                }
            }
    }
    
    private func showStatistics(jobs: Int, rate: Int, repeatC: Int, time: Int) {
        let statsVC = UIViewController()
        statsVC.modalPresentationStyle = .pageSheet
        if let sheet = statsVC.sheetPresentationController { sheet.detents = [.medium()] }
        
        let container = UIView()
        container.backgroundColor = .white
        statsVC.view = container
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: container.frame.width, height: 30))
        titleLabel.text = "📊 Provider Statistics (Live)"
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.autoresizingMask = [.flexibleWidth]
        container.addSubview(titleLabel)
        
        let info = "Jobs Done: \(jobs)\nSuccess Rate: \(rate)%\nResponse Time: \(time)h"
        let infoLabel = UILabel(frame: CGRect(x: 20, y: 70, width: 300, height: 100))
        infoLabel.text = info
        infoLabel.numberOfLines = 0
        container.addSubview(infoLabel)
        
        present(statsVC, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { services.count }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 120 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModernBookingCell", for: indexPath) as! ModernBookingCell
        let service = services[indexPath.row]
        cell.configure(title: service.name, price: service.price, description: service.description, icon: "briefcase.fill")
        cell.onBookingTapped = { [weak self] in
            self?.performSegue(withIdentifier: "showDetails", sender: service)
        }
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails", let destVC = segue.destination as? ServiceInformationTableViewController, let service = sender as? ServiceModel {
            destVC.receivedServiceName = service.name
            destVC.receivedServicePrice = String(format: "BHD %.3f", service.price)
            destVC.receivedServiceDetails = service.description
            destVC.receivedServiceItems = service.addOns
            destVC.providerData = self.providerData
        } else if segue.identifier == "showPortfolio", let destVC = segue.destination as? ProviderPortfolioTableViewController {
            destVC.providerData = self.providerData
            destVC.isReadOnlyMode = true
        } else if segue.identifier == "showReviews", let destVC = segue.destination as? RatingsReviewsViewController {
            // إذا كنت تحتاج تمرير بيانات للتحقق من التقييمات
            // destVC.providerData = self.providerData
        }
    }
}
