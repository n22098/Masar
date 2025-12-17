import UIKit

class ServiceItemTableViewController: UITableViewController {
    
    // متغير البيانات القادمة
    var providerData: ServiceProvider?
    
    // اللون البنفسجي الخاص بالتصميم (Figma Brand Color)
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // MARK: - Header Outlets
    // (تأكد أنها مربوطة في الستوري بورد)
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerRoleLabel: UILabel!
    @IBOutlet weak var headerRatingLabel: UILabel!
    // إذا كنت قد ربطت الـ View الأبيض الحاوي للكارت، يمكنك تجميله هنا، وإلا قم بذلك من الستوري بورد
    // @IBOutlet weak var headerCardContainerView: UIView!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Service Item"
        
        // إعداد خلفية الجدول لتكون رمادية فاتحة مثل التصميم
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none // إخفاء خطوط الفصل
        
        setupHeaderDesign()
        populateHeaderData()
    }
    
    // دالة لضبط تصميم الهيدر (تدوير الصورة والألوان)
    func setupHeaderDesign() {
        // جعل الصورة الشخصية دائرية تماماً
        // (تأكد أن الصورة في الستوري بورد مربعة، مثلاً 60x60)
        headerImageView.layer.cornerRadius = headerImageView.frame.height / 2
        headerImageView.clipsToBounds = true
        headerImageView.layer.borderWidth = 2
        headerImageView.layer.borderColor = UIColor.white.cgColor // إطار أبيض حول الصورة
        
        // إذا كان لديك زر في الهيدر (مثل Book Now)، يمكنك ربطه وتجميله هنا:
        // headerBookButton.backgroundColor = brandColor
        // headerBookButton.layer.cornerRadius = 8
    }
    
    // دالة تعبئة بيانات الهيدر
    func populateHeaderData() {
        if let provider = providerData {
            headerNameLabel.text = provider.name
            headerRoleLabel.text = provider.role
            // تأكد أن لديك أيقونة النجمة في النص أو في الستوري بورد
            headerRatingLabel.text = "★ \(provider.rating)"
            headerRatingLabel.textColor = .systemOrange
            
            if let image = UIImage(named: provider.imageName) {
                headerImageView.image = image
            } else {
                headerImageView.image = UIImage(systemName: "person.circle.fill")
                headerImageView.tintColor = .lightGray
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // تلوين النافيجيشن بار العلوي باللون البنفسجي
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear // إزالة الخط الفاصل تحت البار
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // عدد صفوف الباكيجات
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
        
        // --- تعبئة البيانات ---
        if indexPath.row == 0 {
            cell.serviceNameLabel.text = "Website Starter"
            cell.servicePriceLabel.text = "BHD 85.000"
        } else {
            cell.serviceNameLabel.text = "Business Website"
            cell.servicePriceLabel.text = "BHD 150.000"
        }
        
        // --- تجميل تصميم الخلية لتطابق الفجما ---
        
        // 1. جعل خلفية الخلية شفافة ليظهر لون الجدول الرمادي خلفها
        cell.backgroundColor = .clear
        // ملاحظة: للحصول على تأثير "الكارت" لكل سطر، يجب أن يكون لديك UIView حاوي داخل الخلية في الستوري بورد وتجعل لونه أبيض.
        
        // 2. تصميم زر "Request" (خلفية بيضاء، إطار بنفسجي، نص بنفسجي)
        cell.bookButton.setTitle("Request", for: .normal)
        cell.bookButton.backgroundColor = .white
        cell.bookButton.setTitleColor(brandColor, for: .normal)
        cell.bookButton.layer.borderWidth = 1.5
        cell.bookButton.layer.borderColor = brandColor.cgColor
        cell.bookButton.layer.cornerRadius = 8 // تدوير حواف الزر
        cell.bookButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        // 3. تجميل صورة الخدمة (اختياري)
        cell.serviceImageView.layer.cornerRadius = 8
        cell.serviceImageView.clipsToBounds = true
        
        return cell
    }
    
    // تحديد ارتفاع الخلايا السفلية
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // اجعل هذا الرقم مطابقاً لارتفاع الخلية الذي حددته في الستوري بورد
        return 130
    }
}
