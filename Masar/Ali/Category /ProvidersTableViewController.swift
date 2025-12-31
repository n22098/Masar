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
        
        // تسجيل الخلية
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
        
        // ❌ حذف زر الإضافة - الأدمن لا يستطيع إضافة بروفايدرز
        // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProviderTapped))
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }
    
    // MARK: - Firebase Logic
    private func startProvidersListener() {
        print("🔍 Fetching approved providers for Category: \(selectedCategory)")
        
        // ✅ جلب البروفايدرز المعتمدين فقط من provider_requests
        db.collection("provider_requests")
            .whereField("status", isEqualTo: "approved")
            .whereField("category", isEqualTo: selectedCategory)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching providers: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("⚠️ No providers found for category: \(self.selectedCategory)")
                    self.providers = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.showEmptyState()
                    }
                    return
                }
                
                print("✅ Found \(documents.count) approved providers for \(self.selectedCategory)")
                
                for (index, doc) in documents.enumerated() {
                    let name = doc.get("name") as? String ?? "Unknown"
                    let category = doc.get("category") as? String ?? "N/A"
                    print("   Provider #\(index + 1): \(name) | Category: \(category)")
                }
                
                self.providers = documents
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.hideEmptyState()
                }
            }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: tableView.bounds)
        emptyLabel.text = "No approved providers\nin \(selectedCategory)"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.numberOfLines = 2
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.tag = 999
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = providers.count
        print("📊 Number of rows to display: \(count)")
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCardCell", for: indexPath) as? CategoryCardCell else {
            return UITableViewCell()
        }
        
        let doc = providers[indexPath.row]
        let name = doc.get("name") as? String ?? "Unknown"
        cell.configure(name: name)
        
        return cell
    }
    
    // حذف (Swipe to Delete)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let docID = providers[indexPath.row].documentID
            db.collection("providers").document(docID).delete { error in
                if let error = error {
                    print("❌ Error deleting: \(error.localizedDescription)")
                } else {
                    print("✅ Provider deleted successfully")
                }
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
        
        print("➡️ Selected Provider: \(providerName) (ID: \(providerID))")
        
        // الانتقال لصفحة التفاصيل
        let detailsVC = ProviderDetailsVcontrol()
        detailsVC.providerID = providerID
        detailsVC.providerName = providerName
        detailsVC.providerPhone = phone
        detailsVC.providerEmail = email
        detailsVC.categoryName = selectedCategory
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
