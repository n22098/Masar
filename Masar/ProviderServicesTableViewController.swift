import UIKit

class ProviderServicesTableViewController: UITableViewController {
    
    // MARK: - Properties
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
    
    // MARK: - Setup Navigation Bar
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
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addServiceTapped)
        )
        addButton.tintColor = .white
        navigationItem.rightBarButtonItem = addButton
    }
    
    // MARK: - Setup Table View
    func setupTableView() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(ProviderServiceCell.self, forCellReuseIdentifier: "ProviderServiceCell")
    }
    
    // MARK: - Navigation (Segues)
    // هذه الدالة مسؤولة عن نقل البيانات للصفحة الثانية
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editService" {
            if let destVC = segue.destination as? EditServiceTableViewController {
                
                // إذا كان المرسل خدمة (تعديل)، نرسل البيانات
                if let service = sender as? ServiceModel {
                    destVC.serviceToEdit = service
                    
                    // هذا الكود يتنفذ لما تضغط Save في الصفحة الثانية وترجع
                    destVC.onSaveComplete = { [weak self] updatedService in
                        guard let self = self else { return }
                        
                        // تحديث الخدمة الموجودة في القائمة
                        if let index = self.selectedServiceIndex {
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
    @objc func addServiceTapped() {
        // إذا كنت تريد زر الإضافة يفتح نفس الصفحة الكبيرة أيضاً، يمكنك تعديل هذا الجزء ليعمل Segue
        // حالياً سأتركه كما هو (Alert) حسب كودك القديم، إلا لو أردت تغييره أيضاً.
        let alert = UIAlertController(
            title: "Add New Service",
            message: "Enter service details",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Service Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Price (e.g., BHD 100.000)"
            textField.keyboardType = .decimalPad
        }
        alert.addTextField { textField in
            textField.placeholder = "Description"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let price = alert.textFields?[1].text, !price.isEmpty,
                  let description = alert.textFields?[2].text, !description.isEmpty else {
                return
            }
            
            let newService = ServiceModel(
                name: name,
                price: price,
                description: description
            )
            
            self?.myServices.append(newService)
            self?.tableView.reloadData()
            self?.showSuccessMessage("Service added successfully!")
        })
        
        present(alert, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderServiceCell", for: indexPath) as? ProviderServiceCell else {
            return UITableViewCell()
        }
        
        let service = myServices[indexPath.row]
        cell.configure(with: service)
        
        cell.onEditTapped = { [weak self] in
            self?.editService(at: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
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
    
    // MARK: - Edit Service Logic (UPDATED)
    func editService(at indexPath: IndexPath) {
        // 1. نحفظ مكان السطر الذي نريد تعديله
        selectedServiceIndex = indexPath.row
        
        // 2. نجلب بيانات الخدمة
        let service = myServices[indexPath.row]
        
        // 3. ننتقل للصفحة الكبيرة باستخدام الـ Segue
        // تأكد أن اسم الـ Segue في الستوري بورد هو "editService"
        performSegue(withIdentifier: "editService", sender: service)
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
