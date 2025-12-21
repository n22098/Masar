import UIKit

class ProviderServicesTableViewController: UITableViewController {
    
    // MARK: - Properties
    // 1. البيانات التجريبية
    var myServices: [ServiceModel] = [
        ServiceModel(
            name: "Website Starter",
            price: "BHD 85.000",
            description: "5 pages • Responsive design",
            icon: "doc.text.fill"
        ),
        ServiceModel(
            name: "Business Website",
            price: "BHD 150.000",
            description: "10 pages • Custom layout",
            icon: "building.2.fill"
        )
    ]
    
    // لحفظ مكان السطر الذي نعدله حالياً
    var selectedServiceIndex: Int?
    
    // اللون البنفسجي الخاص بتطبيقك
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // ✅ هذا الشرط يحل مشكلة التحذير الطويل في الكونسول
            if self.view.window != nil {
                tableView.reloadData()
            }
            
            // إعادة تعيين البار العلوي
            setupNavigationBar()
        }
    
    // MARK: - Setup UI
    func setupNavigationBar() {
        // 1. تغيير العنوان إلى Services
        title = "Services"
        
        // 2. تفعيل العنوان الكبير
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        // 3. جعل النصوص بيضاء (للصغير والكبير)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // زر الإضافة (+)
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addServiceTapped)
        )
        addButton.tintColor = .white
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupTableView() {
        // إعدادات الجدول العامة
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.tableFooterView = UIView() // إخفاء الخطوط الزائدة في الأسفل
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myServices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let service = myServices[indexPath.row]
        
        cell.textLabel?.text = service.name
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        cell.detailTextLabel?.text = "\(service.price) • \(service.description)"
        cell.detailTextLabel?.textColor = .darkGray
        
        // الصورة
        cell.imageView?.image = UIImage(systemName: service.icon)
        if cell.imageView?.image == nil {
            cell.imageView?.image = UIImage(systemName: "briefcase.fill")
        }
        cell.imageView?.tintColor = brandColor
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Navigation (نقل البيانات للتعديل أو الإضافة)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editService" {
            
            if let destVC = segue.destination as? EditServiceTableViewController {
                
                // 🔥 التحقق: هل نحن في وضع "تعديل" أم "إضافة"؟
                if let indexPath = tableView.indexPathForSelectedRow {
                    // --- وضع التعديل (Edit) ---
                    let selectedService = myServices[indexPath.row]
                    destVC.serviceToEdit = selectedService
                    selectedServiceIndex = indexPath.row
                } else {
                    // --- وضع الإضافة (Add) ---
                    // عند الضغط على زر (+)، لا يوجد سطر مختار
                    destVC.serviceToEdit = nil
                    selectedServiceIndex = nil
                }
                
                // كود استقبال البيانات بعد الحفظ
                destVC.onSaveComplete = { [weak self] updatedService in
                    guard let self = self else { return }
                    
                    if let index = self.selectedServiceIndex {
                        // تحديث خدمة موجودة
                        self.myServices[index] = updatedService
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    } else {
                        // إضافة خدمة جديدة (Add New)
                        self.myServices.append(updatedService)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Interaction (الضغط على الصف)
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // نكتفي بإلغاء التحديد فقط (لأن الستوري بورد سيقوم بالانتقال تلقائياً)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    // MARK: - Delete Action (السحب للحذف)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let serviceName = myServices[indexPath.row].name
            
            let alert = UIAlertController(
                title: "Delete Service",
                message: "Are you sure you want to delete '\(serviceName)'?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.myServices.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - Add New Service Action
    @objc func addServiceTapped() {
        // الانتقال لشاشة التعديل (وهي فارغة) لإضافة خدمة جديدة
        performSegue(withIdentifier: "editService", sender: nil)
    }
}
