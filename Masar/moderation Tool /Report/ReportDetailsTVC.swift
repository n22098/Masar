import UIKit

class ReportDetailsTVC: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var reportIDLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    
    // MARK: - Properties
    var reportData: [String: String]?

    // ألوان الهوية البصرية
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let bgColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModernUI() // 🎨 تفعيل التصميم الجديد
        populateData()
    }

    // MARK: - 🎨 Modern UI Setup
    private func setupModernUI() {
        self.title = "Report Details"
        
        // 1. إعداد النافيجيشن بار (بنفسجي)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // 2. إعداد الجدول (خلفية نظيفة)
        tableView.backgroundColor = bgColor
        tableView.separatorStyle = .none // إزالة الخطوط التقليدية
        
        // 3. تحسين مظهر النصوص برمجياً
        // نجعل الـ Subject عريضاً ومميزاً
        subjectLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        subjectLabel?.textColor = brandColor
        
        // نجعل الوصف مقروءاً بشكل أفضل
        descriptionLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel?.textColor = .darkGray
        descriptionLabel?.numberOfLines = 0 // لضمان ظهور النص كاملاً
        descriptionLabel?.lineBreakMode = .byWordWrapping
        
        // نجعل البيانات الأخرى بلون موحد
        let infoLabels = [reportIDLabel, reporterLabel, emailLabel]
        for label in infoLabels {
            label?.textColor = .black
            label?.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        // إعدادات الجدول لتوسيع الخلايا حسب المحتوى
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    // MARK: - Data Population
    private func populateData() {
        if let data = reportData {
            reportIDLabel.text = data["id"]
            reporterLabel.text = data["reporter"]
            emailLabel.text = data["email"]
            subjectLabel.text = data["subject"]
            descriptionLabel.text = data["description"]
        } else {
            // بيانات تجريبية (Mock Data)
            reportIDLabel.text = "#RM-2025-001"
            reporterLabel.text = "John Doe"
            emailLabel.text = "john@example.com"
            subjectLabel.text = "Violation of Community Guidelines"
            descriptionLabel.text = "This user has been posting content that violates the community rules regarding spam and harassment. Please review the attached logs for more details. We have received multiple complaints."
        }
    }

    // MARK: - Navigation
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // لإعطاء مساحة جمالية للخلايا
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear // نجعل الخلية شفافة لتظهر خلفية الجدول
        cell.contentView.backgroundColor = .white // نجعل المحتوى أبيض
        
        // إضافة تأثير بسيط (اختياري)
        // إذا كانت الخلايا ثابتة (Static Cells)، قد تحتاج لتلوينها يدوياً في الستوري بورد،
        // لكن هذا الكود يحاول تنظيفها برمجياً.
    }
}
