import UIKit

class SeekerDetailTableViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var RoleTypeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    
    private let status = ["Active","Suspend","Ban"]
    
    var seeker: Seeker?
    private var selectedstatus: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI styling
        setupProfileImageCircle()
        
        // Populate data
        configureView()
        setupStatusMenu()
    }
    
    // Makes the profile image circular to match the storyboard design
    func setupProfileImageCircle() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func configureView() {
        guard let seeker = seeker else { return }
        
        userNameLabel.text = seeker.fullName
        // Use the roleType from your model instead of a hardcoded string
        RoleTypeLabel.text = seeker.roleType
        statusLabel.text = seeker.status
        profileImageView.image = UIImage(named: seeker.imageName)
        
        fullNameTextField.text = seeker.fullName
        emailTextField.text = seeker.email
        phoneTextField.text = seeker.phone
        usernameTextField.text = seeker.username
        passwordTextField.text = "********"
    }

   private func setupStatusMenu() {
        // Create the actions with checkmark 'state' based on current status
        let activeAction = UIAction(title: "Active",
                                    image: UIImage(systemName: "checkmark.circle"),
                                    state: seeker?.status == "Active" ? .on : .off) { _ in
            self.updateStatus("Active")
        }
        
        let suspendAction = UIAction(title: "Suspend",
                                     image: UIImage(systemName: "pause.circle"),
                                     state: seeker?.status == "Suspend" ? .on : .off) { _ in
            self.updateStatus("Suspend")
        }
        
        let banAction = UIAction(title: "Ban",
                                 image: UIImage(systemName: "xmark.octagon"),
                                 attributes: .destructive,
                                 state: seeker?.status == "Ban" ? .on : .off) { _ in
            self.updateStatus("Ban")
        }

        // Attach the menu to the button
        let menu = UIMenu(title: "Change Status", children: [activeAction, suspendAction, banAction])
        statusButton.menu = menu
        statusButton.showsMenuAsPrimaryAction = true
    }

    func updateStatus(_ newStatus: String) {
        statusLabel.text = newStatus
        seeker?.status = newStatus
        
        // Update SampleData globally so the list screen is updated too
        if let seekerName = seeker?.fullName {
            if let index = SampleData.seekers.firstIndex(where: { $0.fullName == seekerName }) {
                SampleData.seekers[index].status = newStatus
            }
        }
        
        // Re-run setup to update the checkmarks in the menu
        setupStatusMenu()
    }

    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
