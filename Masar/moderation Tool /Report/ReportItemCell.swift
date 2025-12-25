import UIKit

class ReportItemCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    
    private var stackView: UIStackView?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStackView()
    }

    private func setupStackView() {
        // 1. إزالة أي قيود قديمة من Storyboard لتجنب التداخل
        [idLabel, subjectLabel, reporterLabel].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            $0?.removeFromSuperview() // سنعيد إضافتهم داخل الـ Stack
        }
        
        // 2. إنشاء الـ Stack View بتنسيق عمودي مرتب
        stackView = UIStackView(arrangedSubviews: [idLabel, subjectLabel, reporterLabel].compactMap { $0 })
        stackView?.axis = .vertical
        stackView?.spacing = 6
        stackView?.alignment = .leading
        stackView?.distribution = .fill
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        
        if let stack = stackView {
            contentView.addSubview(stack)
            
            // 3. ضبط القيود لضمان ظهور النصوص الثلاثة وتمدد الخلية
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
            ])
        }
    }

    func configure(with report: ReportItem) {
        // تنسيق النصوص كما في الصورة الاحترافية
        idLabel?.text = report.reportID
        idLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        idLabel?.textColor = .lightGray
        
        subjectLabel?.text = report.subject
        subjectLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        subjectLabel?.textColor = .label
        
        reporterLabel?.text = "Reporter: \(report.reporter)"
        reporterLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        reporterLabel?.textColor = .systemBlue
    }
}
