// ===================================================================================
// RESET PASSWORD VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows an authenticated user to change their password securely.
//
// KEY FEATURES:
// 1. Security First: Requires re-authentication with current password before update.
// 2. Real-time Feedback: Visual password strength indicator (Red/Yellow/Green).
// 3. Validation: Enforces strong password rules (8+ chars, Uppercase, Numbers).
// 4. Programmatic UI: Creates complex visual elements (Card View, Labels) via code.
// 5. Firebase Integration: Updates the authentication record in the cloud.
// ===================================================================================

import UIKit
import FirebaseAuth // Firebase SDK for user authentication management

class ResetPasswordViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    // Links to UI components defined in Interface Builder
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton! // Action button to save changes
    
    // MARK: - Visual Properties
    // Define brand colors for consistent theming
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 245/255, green: 246/255, blue: 250/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Initialize the visual layout
    }
    
    // MARK: - UI Configuration
    // Builds the screen layout programmatically for precise control
    private func setupUI() {
        // Safety check to ensure outlets are connected
        guard currentPasswordTextField != nil, newPasswordTextField != nil,
              confirmPasswordTextField != nil, resetButton != nil else { return }
        
        view.backgroundColor = lightBg
        title = "Reset Password"
        
        // Clean up: Remove any placeholder labels from Storyboard recursively
        removeAllLabelsRecursively(from: view)
        
        // 1. Create Card View (The white container)
        // This creates a "Floating Card" effect with shadow and rounded corners
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        cardView.layer.shadowRadius = 15
        cardView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        view.addSubview(cardView)
        
        // 2. StackView Organization
        // Groups the text fields vertically for alignment
        let stackView = UIStackView(arrangedSubviews: [currentPasswordTextField, newPasswordTextField, confirmPasswordTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        
        // 3. Button Styling
        // Applies branding colors and shadows to the submit button
        resetButton.backgroundColor = brandColor
        resetButton.setTitle("Update Password", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 25
        resetButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.layer.shadowColor = brandColor.cgColor
        resetButton.layer.shadowOpacity = 0.3
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        resetButton.layer.shadowRadius = 10
        resetButton.addTarget(self, action: #selector(resetPasswordBtn(_:)), for: .touchUpInside)
        
        // 4. Input Field Styling
        // Adds icons and bottom borders to text fields
        styleListField(currentPasswordTextField, icon: "lock.fill", placeholder: "Current Password")
        styleListField(newPasswordTextField, icon: "key.fill", placeholder: "New Password")
        styleListField(confirmPasswordTextField, icon: "checkmark.shield.fill", placeholder: "Confirm New Password")
        
        // 5. Requirements Label (Programmatic)
        // Explains the password rules to the user
        let requirementsLabel = UILabel()
        requirementsLabel.numberOfLines = 0
        requirementsLabel.font = .systemFont(ofSize: 13)
        requirementsLabel.textColor = .darkGray
        requirementsLabel.text = """
        Password must contain:
        • At least 8 characters
        • At least one uppercase letter
        • At least one number
        """
        requirementsLabel.translatesAutoresizingMaskIntoConstraints = false
        requirementsLabel.tag = 998 // Tagged to prevent removal by clean-up function
        view.addSubview(requirementsLabel)
        
        // 6. Strength Indicator Setup (Programmatic)
        // Creates the container for the visual strength meter
        let strengthContainer = UIView()
        strengthContainer.translatesAutoresizingMaskIntoConstraints = false
        strengthContainer.tag = 997
        view.addSubview(strengthContainer)
        
        let strengthLabel = UILabel()
        strengthLabel.text = "Password Strength:"
        strengthLabel.font = .systemFont(ofSize: 13, weight: .medium)
        strengthLabel.textColor = .darkGray
        strengthLabel.translatesAutoresizingMaskIntoConstraints = false
        strengthContainer.addSubview(strengthLabel)
        
        // The actual colored bar that changes width/color
        let strengthIndicator = UIView()
        strengthIndicator.backgroundColor = .systemGray5
        strengthIndicator.layer.cornerRadius = 3
        strengthIndicator.translatesAutoresizingMaskIntoConstraints = false
        strengthIndicator.tag = 999 // Tagged for easy access later
        strengthContainer.addSubview(strengthIndicator)
        
        // 7. Auto Layout Constraints
        // Defines the position and size of all elements relative to each other
        NSLayoutConstraint.activate([
            // Card positioning
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            // StackView inside Card
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            // Requirements Label below Card
            requirementsLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 15),
            requirementsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            requirementsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            // Strength Container
            strengthContainer.topAnchor.constraint(equalTo: requirementsLabel.bottomAnchor, constant: 12),
            strengthContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            strengthContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            strengthContainer.heightAnchor.constraint(equalToConstant: 30),
            
            // Strength Label & Bar
            strengthLabel.leadingAnchor.constraint(equalTo: strengthContainer.leadingAnchor),
            strengthLabel.centerYAnchor.constraint(equalTo: strengthContainer.centerYAnchor),
            
            strengthIndicator.leadingAnchor.constraint(equalTo: strengthLabel.trailingAnchor, constant: 8),
            strengthIndicator.centerYAnchor.constraint(equalTo: strengthContainer.centerYAnchor),
            strengthIndicator.trailingAnchor.constraint(equalTo: strengthContainer.trailingAnchor),
            strengthIndicator.heightAnchor.constraint(equalToConstant: 6),
            
            // Button at the bottom
            resetButton.topAnchor.constraint(equalTo: strengthContainer.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.9),
            resetButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        // Event Listener: Watch for text changes to update strength meter in real-time
        newPasswordTextField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
    }
    
    // Helper: Custom styles for TextFields
    private func styleListField(_ textField: UITextField, icon: String, placeholder: String) {
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.placeholder = placeholder
        textField.textColor = .black
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
        
        // Add Bottom Border Line
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
    
    // Helper: Recursive View Cleaner
    // Removes all UILabels from the view unless they are tagged as "Protected" (999)
    private func removeAllLabelsRecursively(from view: UIView) {
        for subview in view.subviews {
            if subview is UILabel && subview.tag != 999 {
                subview.removeFromSuperview()
            } else {
                removeAllLabelsRecursively(from: subview) // Go deeper into hierarchy
            }
        }
    }
    
    // MARK: - User Actions
    
    // Triggered when the "Update" button is tapped
    @IBAction func resetPasswordBtn(_ sender: UIButton) {
        performUpdateLogic()
    }
    
    // Real-time Strength Monitor
    @objc private func passwordChanged() {
        guard let password = newPasswordTextField.text else { return }
        let strength = calculatePasswordStrength(password)
        updateStrengthIndicator(strength)
    }
    
    // Algorithm: Scores password from 0 to 3 based on complexity
    private func calculatePasswordStrength(_ password: String) -> Int {
        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        return strength
    }
    
    // UI Update: Changes the color of the strength bar based on score
    private func updateStrengthIndicator(_ strength: Int) {
        guard let strengthContainer = view.viewWithTag(997),
              let strengthIndicator = strengthContainer.viewWithTag(999) else { return }
        
        let color: UIColor
        
        // Logic: Weak = Red, Medium = Yellow, Strong = Green
        switch strength {
        case 0: color = .systemGray5
        case 1: color = .systemRed
        case 2: color = .systemYellow
        case 3: color = .systemGreen
        default: color = .systemGray5
        }
        
        // Animate the color change smoothly
        UIView.animate(withDuration: 0.3) {
            strengthIndicator.backgroundColor = color
        }
    }
    
    // MARK: - Core Logic: Update Password
    private func performUpdateLogic() {
        // 1. Basic Validation (Empty Fields)
        guard let currentPw = currentPasswordTextField.text, !currentPw.isEmpty,
              let newPw = newPasswordTextField.text, !newPw.isEmpty,
              let confirmPw = confirmPasswordTextField.text, !confirmPw.isEmpty else {
            showPrompt(title: "Warning", message: "Please fill in all fields")
            return
        }
        
        // 2. Strict Validation (Complexity Rules)
        if newPw.count < 8 {
            showPrompt(title: "Warning", message: "Password must be at least 8 characters")
            return
        }
        
        if newPw.rangeOfCharacter(from: .uppercaseLetters) == nil {
            showPrompt(title: "Warning", message: "Password must contain at least one uppercase letter")
            return
        }
        
        if newPw.rangeOfCharacter(from: .decimalDigits) == nil {
            showPrompt(title: "Warning", message: "Password must contain at least one number")
            return
        }
        
        // 3. Confirmation Match
        if newPw != confirmPw {
            showPrompt(title: "Warning", message: "New passwords do not match")
            return
        }
        
        // 4. Firebase Authentication Logic
        // We must re-authenticate the user to prove they are the owner before changing credentials.
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPw)
        
        // Step A: Re-authenticate
        user?.reauthenticate(with: credential) { [weak self] _, error in
            if let error = error {
                self?.showPrompt(title: "Error", message: "Current password is incorrect")
                print(error.localizedDescription)
                return
            }
            
            // Step B: Update Password
            user?.updatePassword(to: newPw) { error in
                if let error = error {
                    self?.showPrompt(title: "Error", message: error.localizedDescription)
                } else {
                    self?.showSuccessAndExit()
                }
            }
        }
    }
    
    // MARK: - Alerts & Navigation
    
    // Displays simple alert messages
    private func showPrompt(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // On success, show alert and go back to previous screen
    private func showSuccessAndExit() {
        let alert = UIAlertController(title: "Success", message: "Password updated successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Great", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
