// ===================================================================================
// PERSONAL INFORMATION VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows users to view and edit their profile details.
//
// KEY FEATURES:
// 1. Read-Only Fields: Email and Username cannot be changed (Identity security).
// 2. Editable Fields: Users can update their Name and Phone Number.
// 3. Programmatic UI: Uses a Card View design created via code.
// 4. Firebase Sync: Fetches current data on load and updates Firestore on save.
// ===================================================================================

import UIKit
import FirebaseAuth      // For getting the current User ID
import FirebaseFirestore // For reading/writing user data

class PersonalInformationViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    // UI Theme Colors
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 245/255, green: 246/255, blue: 250/255, alpha: 1.0)
    
    // Firebase References
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()        // Draw the visual elements
        fetchUserData()  // Get data from the cloud
    }
    
    // MARK: - UI Setup
    // Constructs the Card View layout programmatically
    private func setupUI() {
        // 1. Safety Check: Ensure all outlets are connected to prevent crashes
        guard nameTextField != nil, emailTextField != nil,
              phoneNumberTextField != nil, usernameTextField != nil,
              saveButton != nil else { return }
        
        view.backgroundColor = lightBg
        title = "Personal Information"
        
        // 2. Clean Up: Remove placeholder labels from Storyboard
        removeAllLabelsRecursively(from: view)
        
        // 3. Create Card View Container
        // A white box with shadow to hold the input fields
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // 4. Organize Fields in a StackView
        // Stacks the text fields vertically with consistent spacing
        let stackView = UIStackView(arrangedSubviews: [nameTextField, emailTextField, phoneNumberTextField, usernameTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        
        // 5. Style the Save Button
        // Applies brand color, rounded corners, and shadow
        saveButton.backgroundColor = brandColor
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.layer.shadowColor = brandColor.cgColor
        saveButton.layer.shadowOpacity = 0.3
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        saveButton.layer.shadowRadius = 10
        saveButton.addTarget(self, action: #selector(saveBtn(_:)), for: .touchUpInside)
        
        // 6. Apply Custom Styling to Fields
        // Email and Username are disabled (isEnabled: false) because they are unique identifiers
        styleListField(nameTextField, icon: "person.fill", placeholder: "Full Name")
        styleListField(emailTextField, icon: "envelope.fill", placeholder: "Email", isEnabled: false)
        styleListField(phoneNumberTextField, icon: "phone.fill", placeholder: "Phone Number")
        styleListField(usernameTextField, icon: "at", placeholder: "Username", isEnabled: false)
        
        // 7. Auto Layout Constraints
        // centers the card and positions the button below it
        NSLayoutConstraint.activate([
            // Center Card with slight offset upwards
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            // Pin StackView inside the Card
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            // Position Button below Card
            saveButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 40),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.9),
            saveButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    // Helper to style TextFields with icons and bottom borders
    private func styleListField(_ textField: UITextField, icon: String, placeholder: String, isEnabled: Bool = true) {
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.isUserInteractionEnabled = isEnabled
        
        // Grey out text if the field is disabled (Read-only)
        textField.textColor = isEnabled ? .black : .systemGray
        textField.font = .systemFont(ofSize: 16)
        
        // Add Icon
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 60))
        let iconView = UIImageView(frame: CGRect(x: 12, y: 20, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = brandColor.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
        
        // Add Bottom Line Separator
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.systemGray6
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 45),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // Recursive function to remove any placeholder labels from Storyboard
    private func removeAllLabelsRecursively(from view: UIView) {
        for subview in view.subviews {
            // Remove label if it is not tagged as "999" (Protected)
            if subview is UILabel && subview.tag != 999 {
                subview.removeFromSuperview()
            } else {
                // Recursively check deeper views
                removeAllLabelsRecursively(from: subview)
            }
        }
    }
    
    // MARK: - Firebase Logic
    
    // Fetches user details from Firestore and populates the fields
    func fetchUserData() {
        guard let uid = uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.nameTextField?.text = data["name"] as? String
                self.emailTextField?.text = data["email"] as? String
                self.phoneNumberTextField?.text = data["phone"] as? String
                self.usernameTextField?.text = data["username"] as? String
            }
        }
    }
    
    // Saves changes to Name and Phone Number
    @IBAction func saveBtn(_ sender: UIButton) {
        guard let uid = uid else { return }
        
        // 1. Validation: Ensure fields are not empty
        guard let name = nameTextField?.text, !name.isEmpty else {
            showPrompt(title: "Warning", message: "Please enter your name")
            return
        }
        
        guard let phone = phoneNumberTextField?.text, !phone.isEmpty else {
            showPrompt(title: "Warning", message: "Please enter your phone number")
            return
        }
        
        // 2. Update Firestore
        // Note: We only update 'name' and 'phone'. Email/Username remain unchanged.
        db.collection("users").document(uid).updateData(["name": name, "phone": phone]) { [weak self] error in
            if let error = error {
                self?.showPrompt(title: "Error", message: error.localizedDescription)
            } else {
                self?.showSuccessAndExit()
            }
        }
    }
    
    // MARK: - Alerts
    
    private func showPrompt(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAndExit() {
        let alert = UIAlertController(title: "Success", message: "Profile updated successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Great", style: .default) { _ in
            // Go back to the Profile screen
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
