// ===================================================================================
// PROVIDER SERVICES VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows a Service Provider to manage (Add, Edit, Delete) their services.
//
// KEY FEATURES:
// 1. CRUD Operations: Full capability to Create, Read, Update, and Delete services.
// 2. Real-Time Fetching: Pulls the latest service list from Firestore.
// 3. Swipe Actions: Supports "Swipe to Delete" and "Swipe to Edit" gestures.
// 4. Custom Animations: Adds a subtle bounce animation when selecting a row.
// ===================================================================================

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProviderServicesTableViewController: UITableViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    let db = Firestore.firestore()
    
    // Data Source
    var myServices: [ServiceModel] = []
    var selectedServiceIndex: Int?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // Reload data every time the view appears to reflect recent edits/adds
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        fetchServicesFromFirebase()
    }
    
    // MARK: - Firebase Fetching
    // Retrieves services specifically created by the currently logged-in Provider
    func fetchServicesFromFirebase() {
        self.title = "Updating..."
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ServiceManager.shared.fetchServicesForProvider(providerId: uid) { [weak self] services in
            DispatchQueue.main.async {
                self?.title = "Services"
                self?.myServices = services
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        
        // Add "Pull to Refresh" functionality
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
        
        // Add Button (+)
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
        
        // Register the custom cell class
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
    
    // MARK: - Interaction Handling
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Custom Bounce Animation on selection
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
    
    // MARK: - Swipe Actions (Delete & Edit)
    // Standard delete implementation
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteService(at: indexPath)
        }
    }
    
    // Custom Swipe Actions configuration
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.deleteService(at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        // Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            self?.performSegue(withIdentifier: "editService", sender: indexPath)
            completionHandler(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = self.brandColor
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // MARK: - Delete Logic
    private func deleteService(at indexPath: IndexPath) {
        let service = myServices[indexPath.row]
        
        // Confirmation Alert
        let alert = UIAlertController(
            title: "Delete Service",
            message: "Do you want to delete this service?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Show Loading
            let loadingAlert = UIAlertController(title: nil, message: "Deleting service...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            loadingAlert.view.addSubview(loadingIndicator)
            self.present(loadingAlert, animated: true)
            
            // Perform Delete via API
            self.deleteServiceFromFirebase(service: service, at: indexPath, loadingAlert: loadingAlert)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteServiceFromFirebase(service: ServiceModel, at indexPath: IndexPath, loadingAlert: UIAlertController) {
        
        // Scenario 1: Service has a valid ID (Standard Case)
        if let serviceId = service.id, !serviceId.isEmpty {
            print("Deleting service with ID: \(serviceId)")
            
            db.collection("services").document(serviceId).delete { [weak self] error in
                guard let self = self else { return }
                
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        print("Delete error: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to delete: \(error.localizedDescription)")
                    } else {
                        print("Service deleted successfully!")
                        self.myServices.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        } else {
            // Scenario 2: ID missing, fallback to search by Name (Legacy Support)
            print("No ID found, searching by name: \(service.name)")
            
            db.collection("services")
                .whereField("title", isEqualTo: service.name)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        loadingAlert.dismiss(animated: true) {
                            print("Search error: \(error.localizedDescription)")
                            self.showAlert(title: "Error", message: "Failed to find service: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        loadingAlert.dismiss(animated: true) {
                            print("Service not found in Firebase")
                            self.showAlert(title: "Error", message: "Service not found")
                        }
                        return
                    }
                    
                    // Delete the found document
                    document.reference.delete { error in
                        loadingAlert.dismiss(animated: true) {
                            if let error = error {
                                print("Delete error: \(error.localizedDescription)")
                                self.showAlert(title: "Error", message: "Failed to delete: \(error.localizedDescription)")
                            } else {
                                print("Service deleted successfully!")
                                self.myServices.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: - Navigation / Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editService" {
            if let destVC = segue.destination as? EditServiceTableViewController {
                
                // Pass existing data if editing, or nil if adding new
                if let indexPath = sender as? IndexPath {
                    let selectedService = myServices[indexPath.row]
                    destVC.serviceToEdit = selectedService
                    selectedServiceIndex = indexPath.row
                } else {
                    destVC.serviceToEdit = nil
                    selectedServiceIndex = nil
                }
                
                // Define Save Callback
                destVC.onSaveComplete = { [weak self] updatedService in
                    guard let self = self else { return }
                    
                    if let _ = updatedService.id {
                        // Update Existing
                        ServiceManager.shared.updateService(updatedService) { error in
                            if let error = error { print("Error updating: \(error)") }
                            else { self.fetchServicesFromFirebase() }
                        }
                    } else {
                        // Create New
                        ServiceManager.shared.addService(updatedService) { error in
                            if let error = error { print("Error adding: \(error)") }
                            else { self.fetchServicesFromFirebase() }
                        }
                    }
                }
                
                // Define Delete Callback (from Edit Screen)
                destVC.onDeleteComplete = { [weak self] in
                    self?.fetchServicesFromFirebase()
                }
            }
        }
    }
    
    @objc private func addServiceTapped() {
        performSegue(withIdentifier: "editService", sender: nil)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Service Cell (Programmatic Layout)
class ServiceCell: UITableViewCell {
    
    // Container card for shadow and corner radius
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
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Layout Setup
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
    
    // MARK: - Configuration
    func configure(with service: ServiceModel, brandColor: UIColor) {
        nameLabel.text = service.name
        priceLabel.text = service.formattedPrice
        priceLabel.textColor = brandColor
        descriptionLabel.text = service.description
        
        let iconName = service.icon ?? "briefcase.fill"
        iconImageView.image = UIImage(systemName: iconName)
        
        // Apply Brand Color with transparency to the icon background
        iconBackgroundView.backgroundColor = brandColor.withAlphaComponent(0.15)
        iconImageView.tintColor = brandColor
    }
}
