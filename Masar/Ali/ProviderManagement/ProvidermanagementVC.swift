import UIKit
import FirebaseFirestore

class ProviderManagementVC: UITableViewController {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var providers: [Provider] = []
    
    // 🔥 1. متغير جديد لتخزين التصنيفات التي سنجلبها من الداتابيس
    private var categories: [String] = []
    
    private var listener: ListenerRegistration?
    
    // Brand Color
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        
        // 🔥 2. بدلاً من استدعاء observeProviders مباشرة، نستدعي دالة تجلب التصنيفات أولاً
        fetchCategoriesAndThenProviders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Deselect row when coming back for a smooth UI feel
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Provider Management"
        
        // Remove back button text for the next screen
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func setupTableView() {
        // Modern iOS background
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = 80 // Fixed height often looks better for uniform lists
        tableView.tableFooterView = UIView()
    }

    // MARK: - Firestore Logic
    
    // 🔥 3. دالة جديدة لجلب التصنيفات أولاً
    private func fetchCategoriesAndThenProviders() {
        print("🔍 Fetching categories first...")
        
        db.collection("categories").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching categories: \(error.localizedDescription)")
                // حتى لو فشل جلب التصنيفات، نحاول جلب البروفايدرز بقائمة فارغة أو افتراضية
                self.observeProviders()
                return
            }
            
            // تخزين التصنيفات في المصفوفة مع تنظيف المسافات
            if let docs = snapshot?.documents {
                self.categories = docs.compactMap { doc in
                    return (doc.get("name") as? String)?.trimmingCharacters(in: .whitespaces)
                }
            }
            
            print("✅ Categories loaded: \(self.categories)")
            
            // 🔥 4. الآن بعد أن أصبحت التصنيفات جاهزة، نستدعي البروفايدرز
            self.observeProviders()
        }
    }

    private func observeProviders() {
        print("🔍 Fetching providers...")
        
        // نتأكد من إزالة أي ليسنر قديم
        listener?.remove()
        
        // FIX IS HERE: fetch both "approved" AND "Ban"
        listener = db.collection("provider_requests") // أو users حسب ما تستخدم
            .whereField("status", in: ["approved", "Ban"])
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No providers found")
                    self.providers = []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.showEmptyState()
                    }
                    return
                }

                // 🔥 5. التعديل هنا: نمرر self.categories التي جلبناها في الخطوة السابقة
                self.providers = documents.compactMap {
                    Provider(uid: $0.documentID,
                             dictionary: $0.data(),
                             validCategories: self.categories) // ✅ تم الحل
                }

                DispatchQueue.main.async {
                    self.hideEmptyState()
                    self.tableView.reloadData()
                    print("✅ Loaded \(self.providers.count) providers")
                }
            }
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        let emptyLabel = UILabel(frame: tableView.bounds)
        emptyLabel.text = "No providers found"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }

    // MARK: - TableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showProviderDetailsCell", for: indexPath)

        let provider = providers[indexPath.row]

        // Title (Name)
        cell.textLabel?.text = provider.fullName
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        // Change text color if Banned
        if provider.status == "Ban" {
            cell.textLabel?.textColor = .systemRed
            cell.detailTextLabel?.text = "Banned - \(provider.category)"
        } else {
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.text = provider.category
        }

        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.font = .systemFont(ofSize: 15)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProviderDetailsSegue",
           let detailsVC = segue.destination as? ProviderDetailsTVC {
            
            if let selectedProvider = sender as? Provider {
                detailsVC.provider = selectedProvider
            }
            else if let indexPath = tableView.indexPathForSelectedRow {
                detailsVC.provider = providers[indexPath.row]
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
