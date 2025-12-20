import UIKit

class ProviderServicesTableViewController: UITableViewController {
    
    // MARK: - Properties
    // بيانات تجريبية
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
            description: "10 pages • Custom layout\nDatabase support + admin panel",
            icon: "building.2.fill"
        )
    ]
    
    // متغير لحفظ رقم السطر الذي يتم تعديله حالياً
    var selectedServiceIndex: Int?
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup UI
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        title = "My Services"
        
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
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        // تسجيل الخلية
        tableView.register(ProviderServiceCell.self, forCellReuseIdentifier: "ProviderServiceCell")
    }
    
    // MARK: - Navigation & Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editService" {
            if let destVC = segue.destination as? EditServiceTableViewController {
                
                // تمرير البيانات للتعديل
                if let service = sender as? ServiceModel {
                    destVC.serviceToEdit = service
                    
                    // استقبال البيانات بعد الحفظ
                    destVC.onSaveComplete = { [weak self] updatedService in
                        guard let self = self else { return }
                        
                        if let index = self.selectedServiceIndex {
                            // تحديث الخدمة الموجودة
                            self.myServices[index] = updatedService
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            self.showSuccessMessage("Service updated successfully!")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    // --- دالة الإضافة (التي كانت تسبب المشكلة) ---
    @objc func addServiceTapped() {
            print("🚀 الدالة بدأت تعمل") // للتأكد أن الزر مربوط صح

            let alert = UIAlertController(
                title: "Add New Service",
                message: "Enter service details",
                preferredStyle: .alert
            )
            
            // إضافة الحقول الثلاثة
            alert.addTextField { $0.placeholder = "Service Name" }
            alert.addTextField { $0.placeholder = "Price (e.g., 25)" }
            alert.addTextField { $0.placeholder = "Description" }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // زر الإضافة مع حماية ضد الكراش
            alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                // --- منطقة الحماية ---
                // نتحقق كم حقلاً يرى النظام فعلياً
                let fieldsCount = alert.textFields?.count ?? 0
                print("🔍 النظام يرى حالياً: \(fieldsCount) حقول")
                
                // إذا كان العدد أقل من 3، نوقف العملية بدلاً من انهيار التطبيق
                guard let fields = alert.textFields, fields.count >= 3 else {
                    print("❌ خطأ: لم يتم تحميل جميع الحقول! العملية توقفت بسلام.")
                    return
                }
                
                // قراءة البيانات بأمان الآن
                let name = fields[0].text ?? ""
                let price = fields[1].text ?? ""
                let description = fields[2].text ?? ""
                
                if name.isEmpty || price.isEmpty || description.isEmpty {
                    print("⚠️ تنبيه: أحد الحقول فارغ")
                    return
                }
                
                // إضافة الخدمة
                let newService = ServiceModel(
                    name: name,
                    price: price,
                    description: description
                )
                
                self.myServices.append(newService)
                self.tableView.reloadData()
                self.showSuccessMessage("Service added successfully!")
            })
            
            present(alert, animated: true)
        }
    
    // دالة التعديل (تنتقل للصفحة الثانية)
    func editService(at indexPath: IndexPath) {
        selectedServiceIndex = indexPath.row
        let service = myServices[indexPath.row]
        performSegue(withIdentifier: "editService", sender: service)
    }
    
    func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if myServices.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        return myServices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyServicesCell", for: indexPath) as? ProviderServiceCell else {
            return UITableViewCell()
        }
        
        let service = myServices[indexPath.row]
        cell.configure(with: service)
        
        // ربط زر التعديل
        cell.onEditTapped = { [weak self] in
            self?.editService(at: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    // الحذف
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
    
    // MARK: - Empty State
    func showEmptyState() {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 300))
        let iconView = UIImageView(image: UIImage(systemName: "briefcase"))
        iconView.tintColor = .lightGray
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Services Yet\nTap + to add your first service"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(iconView)
        emptyView.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -40),
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -40)
        ])
        tableView.backgroundView = emptyView
    }
    
    func hideEmptyState() {
        tableView.backgroundView = nil
    }
}
