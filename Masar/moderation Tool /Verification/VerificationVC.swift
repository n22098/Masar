import UIKit

// تعريف البيانات (تأكد أن هذا هو التعريف الوحيد في المشروع)
struct VerificationItem {
    let providerName: String
    let providerCategory: String
}

class VerificationVC: UITableViewController {

    let data = [
        VerificationItem(providerName: "Ahmed Mohamed", providerCategory: "Plumbing Specialist"),
        VerificationItem(providerName: "Sara Khalid", providerCategory: "Graphic Designer"),
        VerificationItem(providerName: "John Doe", providerCategory: "Electrical Engineer")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Verification"
        
        // الحل الأساسي: تسجيل الخلية برمجياً يضمن أنها لن تكون nil أبداً
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "showVerificationCell")
        
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 1. محاولة استخراج الخلية المسجلة
        var cell = tableView.dequeueReusableCell(withIdentifier: "showVerificationCell")
        
        // 2. التأكد من أن الخلية بنمط Subtitle (هذا يمنع الـ Crash)
        if cell == nil || cell?.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "showVerificationCell")
        }

        let item = data[indexPath.row]

        // 3. تعبئة البيانات
        cell?.textLabel?.text = item.providerName
        cell?.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        cell?.detailTextLabel?.text = item.providerCategory
        cell?.detailTextLabel?.textColor = .secondaryLabel
        
        cell?.accessoryType = .disclosureIndicator

        // 4. إرجاع الخلية (مستحيل تكون nil الآن)
        return cell!
    }

    // الانتقال للصفحة التالية عند الضغط
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // تأكد أنك وضعت هذا الاسم في الـ Identifier الخاص بالـ Segue في الـ Storyboard
        performSegue(withIdentifier: "showProviderRequest", sender: indexPath)
    }
}
