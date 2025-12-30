import UIKit

class ReportDetailsTVC: UITableViewController {
    
    var reportData: [String: String]?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Report Details"
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // إجبار العنوان ليكون أبيض دائماً
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Table View Setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // قسم المعلومات + قسم الوصف
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
        ])
        
        if indexPath.section == 0 {
            // قسم معلومات المراسل
            setupReporterInfo(in: cardView)
        } else {
            // قسم الوصف والموضوع
            setupDescription(in: cardView)
        }
        
        return cell
    }
    
    private func setupReporterInfo(in view: UIView) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let idRow = createInfoRow(title: "Report ID", value: reportData?["id"] ?? "--")
        let reporterRow = createInfoRow(title: "Reporter", value: reportData?["reporter"] ?? "--")
        let emailRow = createInfoRow(title: "Email", value: reportData?["email"] ?? "--")
        
        stack.addArrangedSubview(idRow)
        stack.addArrangedSubview(reporterRow)
        stack.addArrangedSubview(emailRow)
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDescription(in view: UIView) {
        let subjectLabel = UILabel()
        subjectLabel.text = reportData?["subject"] ?? "No Subject"
        subjectLabel.font = .systemFont(ofSize: 18, weight: .bold)
        subjectLabel.textColor = brandColor
        
        let descLabel = UILabel()
        descLabel.text = reportData?["description"] ?? "No Description"
        descLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descLabel.textColor = .darkGray
        descLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [subjectLabel, descLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createInfoRow(title: String, value: String) -> UIView {
        let row = UIView()
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 15, weight: .medium)
        titleLbl.textColor = .gray
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLbl.textColor = .black
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLbl)
        row.addSubview(valueLbl)
        
        NSLayoutConstraint.activate([
            titleLbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLbl.topAnchor.constraint(equalTo: row.topAnchor),
            titleLbl.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            titleLbl.widthAnchor.constraint(equalToConstant: 100),
            
            valueLbl.leadingAnchor.constraint(equalTo: titleLbl.trailingAnchor, constant: 10),
            valueLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLbl.topAnchor.constraint(equalTo: row.topAnchor),
            valueLbl.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        
        return row
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Reporter Details" : "Report Description"
    }
}
