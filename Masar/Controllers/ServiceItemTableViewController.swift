import UIKit

class ServiceItemTableViewController: UITableViewController {
    
    // MARK: - Variables
    var providerData: ServiceProviderModel?
    
    let services = [
        ("Website Starter", "BHD 85.000", "Includes responsive design, basic contact form, and fast delivery."),
        ("Business Website", "BHD 150.000", "Includes custom layout, database support, admin panel, and SEO.")
    ]
    
    // MARK: - Outlets
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
    
    func setupUI() {
        title = "IT Solutions"
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        if let imgView = headerImageView {
            imgView.layer.cornerRadius = imgView.frame.height / 2
            imgView.clipsToBounds = true
            imgView.layer.borderWidth = 3
            imgView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func populateHeaderData() {
        if let provider = providerData {
            headerNameLabel.text = provider.name
            headerRoleLabel.text = provider.role
            headerRatingLabel.text = "★ \(provider.rating)"
            headerRatingLabel.textColor = .systemOrange
            headerImageView.image = UIImage(named: provider.imageName) ?? UIImage(systemName: "person.circle.fill")
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
        cell.configure(name: service.0, price: service.1)
        
        // عند الضغط على الزر، ننتقل للصفحة التالية
        cell.onBookingTapped = { [weak self] in
            self?.performSegue(withIdentifier: "showDetails", sender: service)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    // MARK: - Navigation (هنا التعديل المهم!)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            
            // 👇 هنا التغيير: نستخدم الاسم الجديد ServiceInformationTableViewController
            if let destVC = segue.destination as? ServiceInformationTableViewController,
               let serviceData = sender as? (String, String, String) {
                
                destVC.receivedServiceName = serviceData.0
                destVC.receivedServicePrice = serviceData.1
                destVC.receivedServiceDetails = serviceData.2
                destVC.providerData = self.providerData
            }
        }
    }
}
