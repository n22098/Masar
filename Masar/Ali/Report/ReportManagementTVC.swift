import UIKit
import FirebaseFirestore

class ReportManagementTVC: UITableViewController {
    
    var reports: [[String: Any]] = []
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        fetchReports()
        
        // تسجيل الخلية برمجياً لضمان عملها حتى لو لم تربطها بالستوري بورد
        tableView.register(ReportItemCell.self, forCellReuseIdentifier: ReportItemCell.identifier)
    }
    
    func setupDesign() {
        title = "Report Management"
        // لون خلفية الجدول (رمادي فاتح جداً)
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        
        // إعداد النافيجيشن بار
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 🔥 التعديل 1: إزالة الخطوط الفاصلة
        tableView.separatorStyle = .none
        
        // 🔥 التعديل 3 (جزئي): زيادة ارتفاع الخلية قليلاً لاستيعاب المسافات الجديدة
        tableView.rowHeight = 100 // زدناها من 90 إلى 100
    }
    
    func fetchReports() {
        let db = Firestore.firestore()
        db.collection("reports").order(by: "timestamp", descending: true).addSnapshotListener { [weak self] (snapshot, error) in
            if let error = error { print(error); return }
            self?.reports = snapshot?.documents.map { $0.data() } ?? []
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportItemCell.identifier, for: indexPath) as? ReportItemCell else {
            return UITableViewCell()
        }
        
        let report = reports[indexPath.row]
        
        // تنسيق رقم التقرير (001, 002...)
        let displayId = String(format: "%03d", reports.count - indexPath.row)
        
        let name = report["reporter"] as? String ?? "Unknown"
        let email = report["email"] as? String ?? "No Email"
        
        cell.configure(id: displayId, name: name, email: email)
        
        // 🔥 التعديل 2: إزالة السهم الخارجي (لأننا وضعنا واحداً داخل الخلية)
        cell.accessoryType = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedReport = reports[indexPath.row]
        let detailsVC = ReportDetailsTVC()
        
        var stringData: [String: String] = [:]
        stringData["id"] = selectedReport["id"] as? String ?? ""
        stringData["reporter"] = selectedReport["reporter"] as? String ?? ""
        stringData["email"] = selectedReport["email"] as? String ?? ""
        stringData["subject"] = selectedReport["subject"] as? String ?? ""
        stringData["description"] = selectedReport["description"] as? String ?? ""
        
        detailsVC.reportData = stringData
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
