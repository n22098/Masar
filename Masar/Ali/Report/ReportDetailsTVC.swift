import UIKit
import FirebaseFirestore

/// ReportDetailsTVC: Displays the comprehensive details of a specific user report.
/// OOD Principle: Single Responsibility - This class is solely responsible for
/// formatting and presenting report data to the administrator.
class ReportDetailsTVC: UITableViewController {
    
    // MARK: - Properties
    /// reportData: A dictionary containing the key-value pairs for the report details.
    var reportData: [String: String]?
    
    /// Centralized brand color to ensure visual consistency across the Admin panel.
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /// Configures the look and feel of the screen, specifically the Navigation Bar and Background.
    private func setupUI() {
        title = "Report Details"
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1.0)
        tableView.separatorStyle = .none // Using custom card styling instead of standard separators
        
        // Navigation Bar Appearance (OOD: Centralized styling for predictability)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Apply the appearance to ensure it persists during scroll
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Table View Setup
    // OOD Principle: Delegation - Implementing the UITableViewDataSource protocol.
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0: Metadata, Section 1: Subject and Description
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Each section contains one large "Card" cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We use a blank cell and inject a custom CardView for modern styling
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Constructing the Card (Encapsulation of visual style)
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(cardView)
        
        // Constraints to center the Card inside the cell content view
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
        ])
        
        // OOD Principle: Strategy Pattern - Deciding which setup method to use based on section
        if indexPath.section == 0 {
            setupReporterInfo(in: cardView)
        } else {
            setupDescription(in: cardView)
        }
        
        return cell
    }
    
    /// Builds the metadata stack (ID, Reporter Name, Email).
    private func setupReporterInfo(in view: UIView) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Injecting data from the reportData dictionary
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
    
    /// Builds the descriptive text section of the report.
    private func setupDescription(in view: UIView) {
        let subjectLabel = UILabel()
        subjectLabel.text = reportData?["subject"] ?? "No Subject"
        subjectLabel.font = .systemFont(ofSize: 18, weight: .bold)
        subjectLabel.textColor = brandColor
        
        let descLabel = UILabel()
        descLabel.text = reportData?["description"] ?? "No Description"
        descLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descLabel.textColor = .darkGray
        descLabel.numberOfLines = 0 // Allows the text to expand for long reports
        
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
    
    /// createInfoRow: A factory method to create uniform key-value rows.
    /// OOD Principle: Reusability - This avoids repeating layout code for every detail row.
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
            titleLbl.widthAnchor.constraint(equalToConstant: 100), // Fixed width for alignment
            
            valueLbl.leadingAnchor.constraint(equalTo: titleLbl.trailingAnchor, constant: 10),
            valueLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLbl.topAnchor.constraint(equalTo: row.topAnchor),
            valueLbl.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        
        return row
    }
    
    // Setting titles for each section of the report table
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Reporter Details" : "Report Description"
    }
}
