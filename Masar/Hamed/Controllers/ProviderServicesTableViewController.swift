import UIKit

class ProviderServicesTableViewController: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    var myServices: [ServiceModel] = []
    
    var selectedServiceIndex: Int?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        // جلب البيانات من Firebase في كل مرة تظهر الشاشة
        fetchServicesFromFirebase()
    }
    
    // MARK: - Firebase Fetching ✅ تم تحديثه
    func fetchServicesFromFirebase() {
        // إضافة مؤشر تحميل بسيط في العنوان
        self.title = "Updating..."
        
        // ✅ جلب Provider ID من المستخدم الحالي
        guard let currentUser = UserManager.shared.currentUser else {
            print("❌ No current user found")
            self.title = "Services"
            showNoProviderAlert()
            return
        }
        
        let providerId = currentUser.id
        
        guard !providerId.isEmpty else {
            print("❌ Provider ID is empty")
            self.title = "Services"
            showNoProviderAlert()
            return
        }
        
        print("🔍 Fetching services for provider: \(providerId)")
        
        // ✅ استخدام fetchServicesForProvider بدلاً من fetchAllServices
        ServiceManager.shared.fetchServicesForProvider(providerId: providerId) { [weak self] services in
            DispatchQueue.main.async {
                self?.title = "Services"
                self?.myServices = services
                print("📋 Loaded \(services.count) services")
                self?.tableView.reloadData()
            }
        }
    }
    
    private func showNoProviderAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Provider ID not found. Please make sure you are logged in as a provider.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        
        // إضافة Refresh Control لسحب الشاشة وتحديث البيانات
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        fetchServicesFromFirebase()
        tableView.refreshControl?.endRefreshing()
    }
    
    private func setupNavigationBar() {
        title = "Services"
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
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addServiceTapped)
        )
        addButton.tintColor = .white
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        tableView.register(ServiceCell.self, forCellReuseIdentifier: "ServiceCell")
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myServices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        let service = myServices[indexPath.row]
        cell.configure(with: service, brandColor: brandColor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                }
            }
        }
        
        performSegue(withIdentifier: "editService", sender: indexPath)
    }
    
    // MARK: - Delete & Navigation
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteService(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteService(at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            self?.performSegue(withIdentifier: "editService", sender: indexPath)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = self.brandColor
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func deleteService(at indexPath: IndexPath) {
        let service = myServices[indexPath.row]
        let serviceName = service.name
        
        // يجب التأكد من وجود ID للحذف
        guard let serviceId = service.id else { return }
        
        let alert = UIAlertController(
            title: "Delete Service",
            message: "Are you sure you want to delete '\(serviceName)'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            
            // الاتصال بـ Firebase للحذف
            ServiceManager.shared.deleteService(serviceId: serviceId) { error in
                if let error = error {
                    print("Error deleting service: \(error.localizedDescription)")
                    return
                }
                
                // التحديث في الواجهة بعد نجاح الحذف
                DispatchQueue.main.async {
                    self?.myServices.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation / Segue (Save & Update)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editService" {
            if let destVC = segue.destination as? EditServiceTableViewController {
                
                // تمرير البيانات للشاشة التالية
                if let indexPath = sender as? IndexPath {
                    let selectedService = myServices[indexPath.row]
                    destVC.serviceToEdit = selectedService
                    selectedServiceIndex = indexPath.row
                } else {
                    destVC.serviceToEdit = nil
                    selectedServiceIndex = nil
                }
                
                destVC.onSaveComplete = { [weak self] updatedService in
                    guard let self = self else { return }
                    
                    // إذا كان هناك ID، فهذا يعني تحديث
                    if let _ = updatedService.id {
                        ServiceManager.shared.updateService(updatedService) { error in
                            if let error = error {
                                print("Error updating: \(error)")
                            } else {
                                print("✅ Successfully updated service")
                                self.fetchServicesFromFirebase()
                            }
                        }
                    } else {
                        // إذا لم يكن هناك ID، فهذه إضافة جديدة
                        ServiceManager.shared.addService(updatedService) { error in
                            if let error = error {
                                print("Error adding: \(error)")
                            } else {
                                print("✅ Successfully added service")
                                self.fetchServicesFromFirebase()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func addServiceTapped() {
        performSegue(withIdentifier: "editService", sender: nil)
    }
}

// MARK: - Service Cell Class
class ServiceCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            iconBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconBackgroundView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 48),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),
            descriptionLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14),
            
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with service: ServiceModel, brandColor: UIColor) {
        nameLabel.text = service.name
        priceLabel.text = service.formattedPrice
        priceLabel.textColor = brandColor
        descriptionLabel.text = service.description
        
        let iconName = service.icon ?? "briefcase.fill"
        iconImageView.image = UIImage(systemName: iconName)
        
        iconBackgroundView.backgroundColor = brandColor.withAlphaComponent(0.15)
        iconImageView.tintColor = brandColor
    }
}
