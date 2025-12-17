import UIKit

class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Properties
    var providerData: ServiceProviderModel?
    
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // بيانات الخدمات
    let services = [
        ("Website Starter", "BHD 85.000", "Responsive pages\nBasic contact form\nFast delivery\nFree minor edits"),
        ("Business Website", "BHD 150.000", "Professional design\nAdvanced features\nSEO optimization\nOngoing support")
    ]
    
    // MARK: - IBOutlets (للـ Header)
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerRoleLabel: UILabel!
    @IBOutlet weak var headerRatingLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateHeaderData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "IT Solutions"
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
        
        // Header image
        headerImageView?.layer.cornerRadius = headerImageView?.frame.height ?? 50 / 2
        headerImageView?.clipsToBounds = true
        headerImageView?.layer.borderWidth = 2
        headerImageView?.layer.borderColor = UIColor.white.cgColor
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func populateHeaderData() {
        if let provider = providerData {
            headerNameLabel?.text = provider.name
            headerRoleLabel?.text = provider.role
            headerRatingLabel?.text = "★ \(provider.rating)"
            headerRatingLabel?.textColor = .systemOrange
            
            if let image = UIImage(named: provider.imageName) {
                headerImageView?.image = image
            } else {
                headerImageView?.image = UIImage(systemName: "person.circle.fill")
                headerImageView?.tintColor = .lightGray
            }
        } else {
            // بيانات افتراضية
            headerNameLabel?.text = "Sayed Husain"
            headerRoleLabel?.text = "Software Engineer"
            headerRatingLabel?.text = "★ 4.9"
            headerRatingLabel?.textColor = .systemOrange
            headerImageView?.image = UIImage(systemName: "person.circle.fill")
            headerImageView?.tintColor = .systemOrange
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
        
        let service = services[indexPath.row]
        cell.configure(
            name: service.0,
            price: service.1,
            imageName: nil,
            buttonColor: brandColor
        )
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // التفاعل عند الضغط
        cell.onBookingTapped = { [weak self] in
            self?.handleBooking(at: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: - Actions
    private func handleBooking(at indexPath: IndexPath) {
        let service = services[indexPath.row]
        
        print("📦 Booking service: \(service.0)")
        
        // الانتقال للصفحة الثانية
        performSegue(withIdentifier: "showDetails", sender: service)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let destVC = segue.destination as? ServiceDetailsTableViewController,
               let service = sender as? (String, String, String) {
                destVC.receivedServiceName = service.0
                destVC.receivedServicePrice = service.1
                destVC.receivedServiceDetails = service.2
            }
        }
    }
}
