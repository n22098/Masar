import UIKit
import FirebaseFirestore

class ProvidersTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // هذه المتغيرات تستقبل البيانات من الصفحة السابقة
    var selectedCategory: String = ""
    var categoryID: String = ""
    
    private var providers: [QueryDocumentSnapshot] = []
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 🛠️ مهم جداً: تحديد ارتفاع الخلايا
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        // تسجيل الخلية (تأكد أن CategoryCardCell معرف في المشروع)
        tableView.register(CategoryCardCell.self, forCellReuseIdentifier: "CategoryCardCell")
        
        startProvidersListener()
    }
    
    private func setupUI() {
        self.title = selectedCategory // عنوان الصفحة يصير اسم القسم (مثلاً Business)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // زر الإضافة (+)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProviderTapped))
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    // MARK: - Firebase Logic
    private func startProvidersListener() {
        print("🔍 Fetching providers for Category ID: \(categoryID)")
        
        // جلب البروفايدرز الخاصين بهذا القسم فقط
        db.collection("providers")
            .whereField("categoryID", isEqualTo: categoryID)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("❌ Error fetching providers: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("⚠️ No providers found")
                    return
                }
                
                print("✅ Found \(documents.count) providers")
                self?.providers = documents
                self?.tableView.reloadData()
            }
    }
    
    @objc private func addProviderTapped() {
        let alert = UIAlertController(title: "New Provider", message: "Add to \(selectedCategory)", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Provider Name" }
        alert.addTextField { $0.placeholder = "Phone (Optional)" }
        alert.addTextField { $0.placeholder = "Email (Optional)" }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?[0].text, !name.isEmpty else { return }
            
            let phone = alert.textFields?[1].text ?? ""
            let email = alert.textFields?[2].text ?? ""
            
            self.saveProviderToFirebase(name: name, phone: phone, email: email)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func saveProviderToFirebase(name: String, phone: String, email: String) {
        db.collection("providers").addDocument(data: [
            "name": name,
            "phone": phone,
            "email": email,
            "categoryID": categoryID,      // ربط البروفايدر بالقسم
            "categoryName": selectedCategory,
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Failed to save: \(error.localizedDescription)")
            } else {
                print("✅ Provider saved successfully")
            }
        }
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UITableViewCell()
        }
        
        let doc = providers[indexPath.row]
        let name = doc.get("name") as? String ?? "Unknown"
        cell.configure(name: name) // إعادة استخدام نفس تصميم الخلية
        
        return cell
    }
    
    // حذف (Swipe to Delete)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let docID = providers[indexPath.row].documentID
            db.collection("providers").document(docID).delete { error in
                if let error = error { print("❌ Error deleting: \(error.localizedDescription)") }
            }
        }
    }
    
    // MARK: - Navigation (عند الضغط على بروفايدر)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let doc = providers[indexPath.row]
        
        // استخراج بيانات البروفايدر
        let providerName = doc.get("name") as? String ?? "Unknown"
        let phone = doc.get("phone") as? String ?? ""
        let email = doc.get("email") as? String ?? ""
        let providerID = doc.documentID
        
        // الانتقال لصفحة التفاصيل (لازم يكون عندك هذا الكلاس)
        let detailsVC = ProviderDetailsVcontrol()
        detailsVC.providerID = providerID
        detailsVC.providerName = providerName
        detailsVC.providerPhone = phone
        detailsVC.providerEmail = email
        detailsVC.categoryName = selectedCategory
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
