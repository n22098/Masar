import UIKit
import FirebaseFirestore
import FirebaseAuth // 🔥 Used to identify the current logged-in user

// MARK: - RatingViewController
/// RatingViewController: Manages the screen where users can provide a star rating and text feedback.
/// OOD Principle: Single Responsibility - This class handles the logic for capturing and validating user input
/// before sending it to the Service Layer.
class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Double = 0.0
    
    // Data passed from the previous screen (Dependency Injection)
    var providerId: String?
    var providerName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStarButtons() // Initialize the interactive stars
    }
    
    // MARK: - Setup
    
    /// Basic UI styling for the text view and navigation title.
    private func setupUI() {
        feedbackTextView?.layer.borderColor = UIColor.systemGray4.cgColor
        feedbackTextView?.layer.borderWidth = 1.0
        feedbackTextView?.layer.cornerRadius = 8.0
        
        if let name = bookingName {
            self.title = "Rate \(name)"
        }
    }
    
    /// Prepares the star buttons by assigning tags and target actions.
    private func setupStarButtons() {
        guard let stackView = starStackView else { return }
        
        stackView.isUserInteractionEnabled = true
        
        // Loop through each button in the stack to set up listeners
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if let starButton = view as? UIButton {
                starButton.tag = index // Store the index to calculate rating later
                starButton.isUserInteractionEnabled = true
                
                // Target-Action Pattern: Link button tap to our selector
                starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Star Selection Logic
    
    /// Handles the user tapping a star. Includes logic for full-star and half-star selection.
    @objc private func starButtonTapped(_ sender: UIButton) {
        let starIndex = sender.tag
        
        let fullStarRating = Double(starIndex) + 1.0
        let halfStarRating = Double(starIndex) + 0.5
        
        // Toggle logic: If user taps a full star twice, it becomes a half star
        if selectedRating == fullStarRating {
            selectedRating = halfStarRating
        } else {
            selectedRating = fullStarRating
        }
        
        // Haptic feedback (UX): Provides a physical vibration feel when tapping
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animation (UX): Visual "Pop" effect using a spring damping animation
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.4, y: 1.4).translatedBy(x: 0, y: -8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
        
        updateStarsAppearance()
    }
    
    /// Updates the star images (filled, half, or empty) based on the current selectedRating.
    private func updateStarsAppearance() {
        guard let stackView = starStackView else { return }
        
        UIView.animate(withDuration: 0.25) {
            for (index, view) in stackView.arrangedSubviews.enumerated() {
                guard let starButton = view as? UIButton else { continue }
                
                let starPosition = Double(index) + 1.0
                
                // Determine which system icon to use
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
    
    // MARK: - Submission Actions
    
    /// Validates inputs and prepares the data for Firestore.
    @IBAction func submitRatingTapped(_ sender: UIButton) {
        // Validation 1: Ensure a rating was selected
        guard selectedRating > 0 else {
            showRatingAlert()
            return
        }
        
        // Validation 2: Ensure feedback text is not empty
        let feedback = feedbackTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !feedback.isEmpty else {
            showFeedbackAlert()
            return
        }
        
        // UI Best Practice: Disable button to prevent multiple simultaneous database entries
        sender.isEnabled = false
        
        // OOD Principle: Data Consistency
        // 1. Check local UserManager for the user's name
        if let user = UserManager.shared.currentUser {
            saveRating(stars: selectedRating, feedback: feedback, username: user.name)
        } else {
            // 2. If not in memory, fetch the official username from Firestore using the current UID
            guard let uid = Auth.auth().currentUser?.uid else {
                sender.isEnabled = true
                showErrorAlert()
                return
            }
            
            // Asynchronous Fetch: Ensuring we have the correct user identity before posting the review
            Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let data = snapshot?.data() {
                    let realName = data["username"] as? String ?? data["name"] as? String ?? "Unknown User"
                    self.saveRating(stars: self.selectedRating, feedback: feedback, username: realName)
                } else {
                    sender.isEnabled = true
                    self.showErrorAlert()
                }
            }
        }
    }
    
    // MARK: - Save Rating
    
    /// Final step: Calls the Service Layer to upload the rating data.
    private func saveRating(stars: Double, feedback: String, username: String) {
        
        // OOD Principle: Abstraction - Controller delegates the database task to RatingService
        RatingService.shared.uploadRating(
            stars: stars,
            feedback: feedback,
            providerId: self.providerId ?? "",
            username: username,
            bookingName: self.bookingName,
            completion: { [weak self] error in
                guard let self = self else { return }
                self.submitButton.isEnabled = true
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.showErrorAlert()
                } else {
                    // Success: Provide feedback to the user and return to the previous screen
                    self.showSuccessAlert {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        )
    }
    
    // MARK: - Alert Methods (UX Feedback)
    
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
