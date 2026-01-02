import UIKit
import FirebaseFirestore
import FirebaseAuth // 🔥 Added to fetch user ID

// MARK: - RatingViewController
class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Double = 0.0
    
    // 🔥 Properties passed from previous screen
    var providerId: String?
    var providerName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStarButtons()
    }
    
    // MARK: - Setup
    private func setupUI() {
        feedbackTextView?.layer.borderColor = UIColor.systemGray4.cgColor
        feedbackTextView?.layer.borderWidth = 1.0
        feedbackTextView?.layer.cornerRadius = 8.0
        
        if let name = bookingName {
            self.title = "Rate \(name)"
        }
    }
    
    private func setupStarButtons() {
        guard let stackView = starStackView else { return }
        
        stackView.isUserInteractionEnabled = true
        
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if let starButton = view as? UIButton {
                starButton.tag = index
                starButton.isUserInteractionEnabled = true
                
                // 🔥 Using addTarget as per your design
                starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Star Selection (Your Animation Code Preserved)
    @objc private func starButtonTapped(_ sender: UIButton) {
        let starIndex = sender.tag
        
        let fullStarRating = Double(starIndex) + 1.0
        let halfStarRating = Double(starIndex) + 0.5
        
        if selectedRating == fullStarRating {
            selectedRating = halfStarRating
        } else {
            selectedRating = fullStarRating
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animation
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.4, y: 1.4).translatedBy(x: 0, y: -8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
        
        updateStarsAppearance()
    }
    
    private func updateStarsAppearance() {
        guard let stackView = starStackView else { return }
        
        UIView.animate(withDuration: 0.25) {
            for (index, view) in stackView.arrangedSubviews.enumerated() {
                guard let starButton = view as? UIButton else { continue }
                
                let starPosition = Double(index) + 1.0
                
                if self.selectedRating >= starPosition {
                    starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    starButton.tintColor = .systemYellow
                } else if self.selectedRating >= Double(index) + 0.5 {
                    starButton.setImage(UIImage(systemName: "star.leadinghalf.filled"), for: .normal)
                    starButton.tintColor = .systemYellow
                } else {
                    starButton.setImage(UIImage(systemName: "star"), for: .normal)
                    starButton.tintColor = .systemGray4
                }
            }
        }
    }
    
    // MARK: - Actions (🔥 FIXED THIS SECTION)
    @IBAction func submitRatingTapped(_ sender: UIButton) {
        guard selectedRating > 0 else {
            showRatingAlert()
            return
        }
        
        let feedback = feedbackTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !feedback.isEmpty else {
            showFeedbackAlert()
            return
        }
        
        // Disable button to prevent double clicks
        sender.isEnabled = false
        
        // 1. Try to get User from UserManager first
        if let user = UserManager.shared.currentUser {
            // Found local user, send name "Ali123"
            saveRating(stars: selectedRating, feedback: feedback, username: user.name)
        } else {
            // 2. If missing, force fetch from Firebase Auth
            guard let uid = Auth.auth().currentUser?.uid else {
                sender.isEnabled = true
                showErrorAlert() // Not logged in
                return
            }
            
            print("🔍 Fetching real username for ID: \(uid)...")
            Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let data = snapshot?.data() {
                    // Try to get 'username', fallback to 'name'
                    let realName = data["username"] as? String ?? data["name"] as? String ?? "Unknown User"
                    print("✅ Found Name: \(realName)")
                    
                    self.saveRating(stars: self.selectedRating, feedback: feedback, username: realName)
                } else {
                    sender.isEnabled = true
                    self.showErrorAlert()
                }
            }
        }
    }
    
    // MARK: - Save Rating
    private func saveRating(stars: Double, feedback: String, username: String) {
        
        // 🔥 FIX: Pass the fetched 'username' ("Ali123") and 'providerId'
        RatingService.shared.uploadRating(
            stars: stars,
            feedback: feedback,
            providerId: self.providerId ?? "", // Must have ID
            username: username,                // Sends "Ali123"
            bookingName: self.bookingName,
            completion: { [weak self] error in
                guard let self = self else { return }
                self.submitButton.isEnabled = true
                
                if let error = error {
                    print("Error uploading to Firestore: \(error.localizedDescription)")
                    self.showErrorAlert()
                } else {
                    print("Successfully uploaded to Firestore!")
                    
                    // Show Success
                    self.showSuccessAlert {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        )
    }
    
    // MARK: - Alert Methods
    private func showRatingAlert() {
        let alert = UIAlertController(title: "Missing Rating", message: "Please select a star rating before submitting", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showFeedbackAlert() {
        let alert = UIAlertController(title: "Missing Feedback", message: "Please write your feedback before submitting", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Thank You!", message: "Your feedback has been submitted successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion() })
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to submit your feedback. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
