import UIKit

class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Int = 0
    
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
        
        // Enable user interaction on stack view
        stackView.isUserInteractionEnabled = true
        
        // Add tap action to each star button
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if let starButton = view as? UIButton {
                starButton.tag = index
                starButton.isUserInteractionEnabled = true
                starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Star Selection
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag + 1
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Animate the tapped star with bounce and raise effect
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.4, y: 1.4).translatedBy(x: 0, y: -8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
        
        updateStarsAppearance()
    }
    
    // Update stars to gold color with smooth animation
    private func updateStarsAppearance() {
        guard let stackView = starStackView else { return }
        
        UIView.animate(withDuration: 0.25) {
            for (index, view) in stackView.arrangedSubviews.enumerated() {
                guard let starButton = view as? UIButton else { continue }
                
                let isFilled = index < self.selectedRating
                starButton.setImage(
                    UIImage(systemName: isFilled ? "star.fill" : "star"),
                    for: .normal
                )
                starButton.tintColor = isFilled ? .systemYellow : .systemGray4
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func submitRatingTapped(_ sender: UIButton) {
        guard selectedRating > 0 else {
            showRatingAlert()
            return
        }
        
        // Here you can add your submission logic (API call, etc.)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showRatingAlert() {
        let alert = UIAlertController(
            title: "Missing Rating",
            message: "Please select a star rating before submitting",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
