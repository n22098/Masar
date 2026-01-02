import UIKit
import FirebaseFirestore

// MARK: - RatingViewController
class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Double = 0.0
    
    // 🔥 إضافة الخصائص المطلوبة
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
                
                // 🔥 استخدام addTarget بدلاً من gesture recognizer
                starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Star Selection
    @objc private func starButtonTapped(_ sender: UIButton) {
        let starIndex = sender.tag
        
        // 🔥 حساب التقييم بنص نجمة
        // إذا النجمة نفسها محددة بالكامل، خليها نص نجمة
        // وإلا خليها نجمة كاملة
        let fullStarRating = Double(starIndex) + 1.0
        let halfStarRating = Double(starIndex) + 0.5
        
        if selectedRating == fullStarRating {
            // إذا النجمة محددة بالكامل، خليها نص نجمة
            selectedRating = halfStarRating
        } else {
            // وإلا خليها نجمة كاملة
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
    
    // MARK: - Actions
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
        
        saveRating(stars: selectedRating, feedback: feedback)
    }
    
    // MARK: - Save Rating
    private func saveRating(stars: Double, feedback: String) {
        // رفع التقييم إلى Firestore
        // 🔥 FIX: تمرير providerId بدلاً من bookingName
        RatingService.shared.uploadRating(
            stars: stars,
            feedback: feedback,
            providerId: self.providerId,
            completion: { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error uploading to Firestore: \(error.localizedDescription)")
                self.showErrorAlert()
            } else {
                print("Successfully uploaded to Firestore!")
                
                // حفظ نسخة محلية (اختياري)
                self.saveLocalCopy(stars: stars, feedback: feedback)
                
                // عرض رسالة النجاح
                self.showSuccessAlert {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    private func saveLocalCopy(stars: Double, feedback: String) {
        let newRating = Rating(
            stars: stars,
            feedback: feedback,
            date: Date(),
            bookingName: self.bookingName,
            username: "Guest User"
        )
        
        var ratings = loadRatings()
        ratings.append(newRating)
        
        if let encoded = try? JSONEncoder().encode(ratings) {
            UserDefaults.standard.set(encoded, forKey: "SavedRatings")
            NotificationCenter.default.post(name: NSNotification.Name("RatingAdded"), object: nil)
        }
    }
    
    private func loadRatings() -> [Rating] {
        guard let data = UserDefaults.standard.data(forKey: "SavedRatings"),
              let ratings = try? JSONDecoder().decode([Rating].self, from: data) else {
            return []
        }
        return ratings
    }
    
    // MARK: - Alert Methods
    private func showRatingAlert() {
        let alert = UIAlertController(
            title: "Missing Rating",
            message: "Please select a star rating before submitting",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showFeedbackAlert() {
        let alert = UIAlertController(
            title: "Missing Feedback",
            message: "Please write your feedback before submitting",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Your feedback has been submitted successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to submit your feedback. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
