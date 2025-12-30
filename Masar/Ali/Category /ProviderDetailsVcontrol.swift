import UIKit

class ProviderDetailsVcontrol: UIViewController {

    // المتغيرات لاستقبال البيانات
    var providerID: String = ""
    var providerName: String = ""
    var providerPhone: String = ""
    var providerEmail: String = ""
    var categoryName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = providerName // وضع اسم البروفايدر كعنوان
        
        setupUI()
    }
    
    private func setupUI() {
        // هنا سنعرض البيانات بشكل بسيط
        let label = UILabel()
        label.text = """
        Name: \(providerName)
        Phone: \(providerPhone)
        Email: \(providerEmail)
        Category: \(categoryName)
        """
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
