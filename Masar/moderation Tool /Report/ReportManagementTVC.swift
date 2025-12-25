import UIKit

class ReportManagementTVC: UITableViewController {
    
    private let viewModel = ReportManagementViewModel()
    
    // اللون البنفسجي الموحد (نفس المستخدم في الصفحات السابقة)
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 1. Navigation Bar - توحيد اللون البنفسجي
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        // النصوص باللون الأبيض لتباين ممتاز
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.shadowColor = .clear // إزالة الخط الفاصل
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white // لون أزرار الرجوع
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = "Reports"
        
        // 2. Table View Styling - خلفية رمادية فاتحة عصرية
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none // إزالة الخطوط لأننا نستخدم نظام البطاقات
        tableView.tableFooterView = UIView()
        
        // إعدادات الارتفاع
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // إزالة الحشوة الزائدة في حالة الـ Grouped
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfReports()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReportItemCell", for: indexPath) as? ReportItemCell else {
            return UITableViewCell()
        }
        
        if let report = viewModel.report(at: indexPath.row) {
            cell.configure(with: report)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // التأخير قليلاً لرؤية الأنيميشن
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Feedback لمسي خفيف عند الضغط
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Handle navigation here...
    }
}
