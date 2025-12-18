import UIKit

class ServiceInformationTableViewController: UITableViewController {
    
    // MARK: - Data Variables (المتغيرات لاستقبال البيانات)
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var providerData: ServiceProviderModel?
    
    // MARK: - Outlets
    // اربط هذه العناصر في الستوري بورد
    
    // القسم العلوي (بيانات الموظف)
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var providerRoleLabel: UILabel!
    @IBOutlet weak var providerSkillsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    // القسم السفلي (بيانات الخدمة)
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var packageDetailsLabel: UILabel! // تأكد أنه Label وليس TextView
    
    @IBOutlet weak var requestButton: UIButton!
    
    // الألوان
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        configureData()
    }
    
    // MARK: - Setup Design
    func setupDesign() {
        title = "Service Information" // الاسم الجديد
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // تجميل صورة الموظف
        if let img = providerImageView {
            img.layer.cornerRadius = img.frame.height / 2
            img.clipsToBounds = true
            img.layer.borderWidth = 2
            img.layer.borderColor = UIColor.white.cgColor
        }
        
        // تجميل زر الطلب
        if let btn = requestButton {
            btn.layer.cornerRadius = 8
            btn.backgroundColor = brandColor
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - Populate Data
    func configureData() {
        // 1. تعبئة بيانات الموظف
        if let provider = providerData {
            providerNameLabel?.text = provider.name
            providerRoleLabel?.text = provider.role
            providerSkillsLabel?.text = provider.skills.joined(separator: ", ")
            
            timeLabel?.text = provider.availability
            locationLabel?.text = provider.location
            phoneLabel?.text = provider.phone
            
            providerImageView?.image = UIImage(named: provider.imageName) ?? UIImage(systemName: "person.circle.fill")
        } else {
            // بيانات افتراضية
            providerNameLabel?.text = "Sayed Husain"
            providerRoleLabel?.text = "Software Engineer"
        }
        
        // 2. تعبئة بيانات الخدمة
        packageNameLabel?.text = receivedServiceName
        packagePriceLabel?.text = receivedServicePrice
        packageDetailsLabel?.text = receivedServiceDetails
    }
    
    // MARK: - Actions
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        // 👇 التعديل: الانتقال للصفحة الرابعة (Booking Form) بدلاً من إظهار Alert
        performSegue(withIdentifier: "showBookingForm", sender: nil)
    }
    
    // في ملف ServiceInformationTableViewController.swift
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookingForm" {
            if let destVC = segue.destination as? ServiceDetailsBookingTableViewController {
                
                // نقل البيانات
                destVC.receivedServiceName = self.receivedServiceName
                destVC.receivedServicePrice = self.receivedServicePrice
                
                // 👇 إضافة: إرسال موقع الموظف للصفحة الأخيرة
                destVC.receivedLocation = self.providerData?.location
            }
        }
    }
}
