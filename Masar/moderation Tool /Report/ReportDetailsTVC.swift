import UIKit

class ReportDetailsTVC: UITableViewController {

    // MARK: - IBOutlets
    // Connect these to the labels on the right side of your prototype cells
    
    

    @IBOutlet weak var reportIDLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var reporterLabel: UILabel!
    
    // MARK: - Properties
    // This could be a model object passed from the previous screen
    var reportData: [String: String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Example of populating the data (similar to your previous code)
        // In a real app, you'd set these from a 'Report' object
        if let data = reportData {
            reportIDLabel.text = data["id"]
            reporterLabel.text = data["reporter"]
            emailLabel.text = data["email"]
            subjectLabel.text = data["subject"]
            descriptionLabel.text = data["description"]
        } else {
            // Mock data for testing
            reportIDLabel.text = "#12345"
            reporterLabel.text = "John Doe"
            emailLabel.text = "john@example.com"
            subjectLabel.text = "Inappropriate Content"
            descriptionLabel.text = "This user is posting content that violates the community guidelines regarding spam and repetitive messaging."
        }
        
        // Ensures the description cell can grow if the text is long
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    // MARK: - Navigation
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // If you decide to add document viewing logic here later,
        // you can use the QLPreviewController logic from your other file.
    }
}
