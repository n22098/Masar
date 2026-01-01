import UIKit

class ProviderAboutVC: UITableViewController {

    // MARK: - Outlets
    // اربط هذه العناصر في الستوري بورد
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var skillsTextView: UITextView!
    
    // MARK: - Properties
    var provider: Provider?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayData()
    }
    
    private func setupUI() {
        title = "About Provider"
        
        // تحسين شكل مربعات النص
        styleTextView(aboutTextView)
        styleTextView(skillsTextView)
        
        // إزالة الخطوط الفارغة من الجدول
        tableView.tableFooterView = UIView()
    }
    
    private func styleTextView(_ textView: UITextView) {
        // جعل الخلفية رمادية فاتحة وحواف ناعمة
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // منع التعديل لأن الادمن بس يقرأ
        textView.isEditable = false
    }

    private func displayData() {
        guard let provider = provider else { return }
        
        // هنا نعرض البيانات، إذا كانت فارغة نعرض رسالة
        if provider.aboutMe.isEmpty {
            aboutTextView.text = "No description provided."
            aboutTextView.textColor = .gray
        } else {
            aboutTextView.text = provider.aboutMe
            aboutTextView.textColor = .label
        }
        
        if provider.skills.isEmpty {
            skillsTextView.text = "No skills listed."
            skillsTextView.textColor = .gray
        } else {
            skillsTextView.text = provider.skills
            skillsTextView.textColor = .label
        }
    }
    
    // MARK: - TableView Settings
    // لإخفاء الهيدر الزائد إذا كان موجوداً
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
