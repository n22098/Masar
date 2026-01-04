// ===================================================================================
// SEEKER SERVICE VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Manages the "Become a Provider" dashboard for regular users.
//
// KEY FEATURES:
// 1. Status Tracking: Checks if the user has already applied to be a provider.
// 2. Dynamic UI: Switches between an "Apply" button and a "Status Card" based on data.
// 3. Data Passing: Auto-fills the application form with existing user data.
// 4. Feedback Loop: Visualizes Pending, Approved, and Rejected states clearly.
// ===================================================================================

import UIKit
import FirebaseAuth      // For User Authentication
import FirebaseFirestore // For Database Status Checks

class SeekerServiceViewController: UIViewController {
    
    // MARK: - Properties
    let brandColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
    
    // Stores user details fetched from Firebase to pass to the application form
    private var currentUserData: [String: String] = [:]
    
    // Tracks the current application state: "none", "pending", "approved", or "rejected"
    private var providerStatus: String = "none"
    
    // MARK: - UI Components
    // Defined programmatically to avoid Storyboard constraints issues
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let becomeProviderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // The Status Card: Hidden by default, shown only when an application exists
    private let statusCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        // Card Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let statusIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // Called every time the view appears to ensure status is up-to-date
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserStatus()
    }
    
    // MARK: - Setup UI
    // Configures the view hierarchy and Auto Layout constraints
    private func setupUI() {
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(becomeProviderButton)
        containerView.addSubview(statusCard)
        
        statusCard.addSubview(statusIconView)
        statusCard.addSubview(statusTitleLabel)
        statusCard.addSubview(statusMessageLabel)
        
        // Setup button styling
        setupBecomeProviderButton()
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            becomeProviderButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            becomeProviderButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            becomeProviderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            becomeProviderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            becomeProviderButton.heightAnchor.constraint(equalToConstant: 56),
            
            statusCard.topAnchor.constraint(equalTo: becomeProviderButton.bottomAnchor, constant: 24),
            statusCard.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            statusCard.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            statusCard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40),
            
            statusIconView.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 32),
            statusIconView.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),
            statusIconView.widthAnchor.constraint(equalToConstant: 80),
            statusIconView.heightAnchor.constraint(equalToConstant: 80),
            
            statusTitleLabel.topAnchor.constraint(equalTo: statusIconView.bottomAnchor, constant: 20),
            statusTitleLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 24),
            statusTitleLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -24),
            
            statusMessageLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 12),
            statusMessageLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 24),
            statusMessageLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -24),
            statusMessageLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Service"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupBecomeProviderButton() {
        becomeProviderButton.setTitle("Become as a provider", for: .normal)
        becomeProviderButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        becomeProviderButton.setTitleColor(.white, for: .normal)
        becomeProviderButton.backgroundColor = brandColor
        becomeProviderButton.layer.cornerRadius = 16
        
        // Button Shadow
        becomeProviderButton.layer.shadowColor = brandColor.cgColor
        becomeProviderButton.layer.shadowOpacity = 0.4
        becomeProviderButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        becomeProviderButton.layer.shadowRadius = 12
        
        becomeProviderButton.addTarget(self, action: #selector(becomeProviderTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Logic (Firebase)
    
    // Connects to Firestore to check the user's current 'providerRequestStatus'
    private func fetchUserStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            
            // Store user data to prepopulate the application form later
            self.currentUserData = [
                "uid": uid,
                "name": data["name"] as? String ?? "",
                "email": data["email"] as? String ?? "",
                "phone": data["phone"] as? String ?? "",
                "username": data["username"] as? String ?? ""
            ]
            
            // Get provider request status (Defaults to "none")
            let status = data["providerRequestStatus"] as? String ?? "none"
            self.providerStatus = status
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.updateUIBasedOnStatus()
            }
        }
    }
    
    // MARK: - State Management
    // Determines visual state based on the 'providerStatus' variable
    private func updateUIBasedOnStatus() {
        switch providerStatus {
        case "pending":
            showPendingStatus()
        case "approved":
            showApprovedStatus()
        case "rejected":
            showRejectedStatus()
        default:
            showBecomeProviderButton() // State: "none"
        }
    }
    
    // State 1: New User (Show Apply Button)
    private func showBecomeProviderButton() {
        becomeProviderButton.isHidden = false
        statusCard.isHidden = true
    }
    
    // State 2: Pending (Show Clock Icon)
    private func showPendingStatus() {
        becomeProviderButton.isHidden = true
        statusCard.isHidden = false
        
        statusIconView.image = UIImage(systemName: "clock.fill")
        statusIconView.tintColor = .systemOrange
        statusTitleLabel.text = "Application Pending"
        statusTitleLabel.textColor = .systemOrange
        statusMessageLabel.text = "Your provider application is under review. Please wait until the admin approves your request."
    }
    
    // State 3: Approved (Show Checkmark)
    private func showApprovedStatus() {
        becomeProviderButton.isHidden = true
        statusCard.isHidden = false
        
        statusIconView.image = UIImage(systemName: "checkmark.circle.fill")
        statusIconView.tintColor = .systemGreen
        statusTitleLabel.text = "Application Approved"
        statusTitleLabel.textColor = .systemGreen
        statusMessageLabel.text = "Congratulations! Your provider application has been approved. Please log out and log back in to access your provider dashboard."
    }
    
    // State 4: Rejected (Show X mark + Re-apply Button)
    private func showRejectedStatus() {
        becomeProviderButton.isHidden = false // Allow them to apply again
        statusCard.isHidden = false
        
        statusIconView.image = UIImage(systemName: "xmark.circle.fill")
        statusIconView.tintColor = .systemRed
        statusTitleLabel.text = "Application Rejected"
        statusTitleLabel.textColor = .systemRed
        statusMessageLabel.text = "Unfortunately, your provider application was not approved. You can submit a new application with updated information."
    }
    
    // MARK: - Actions
    
    // Navigates to the Application Form
    @objc private func becomeProviderTapped() {
        guard !currentUserData.isEmpty else {
            showAlert("Unable to load user data", title: "Error")
            return
        }
        
        // Navigation Logic: Instantiate the form VC and pass data
        if let applyVC = storyboard?.instantiateViewController(withIdentifier: "ApplyProviderTableViewController") as? ApplyProviderTableViewController {
            // Auto-fill the form with data fetched in fetchUserStatus()
            applyVC.userName = currentUserData["name"]
            applyVC.userEmail = currentUserData["email"]
            applyVC.userPhone = currentUserData["phone"]
            applyVC.userUsername = currentUserData["username"]
            
            navigationController?.pushViewController(applyVC, animated: true)
        }
    }
    
    private func showAlert(_ message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
