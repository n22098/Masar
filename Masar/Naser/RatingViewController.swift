import UIKit
import FirebaseFirestore

// MARK: - RatingViewController (نسخة بديلة - النجوم برمجياً)
// 🔥 استخدم هذه النسخة إذا كانت المشكلة من الـ Storyboard

class RatingViewControllerProgrammatic: UIViewController {
    
    // MARK: - Outlets (نبقي الـ TextView والزر فقط من الـ Storyboard)
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    // 🔥 FIX: بدلاً من IBOutlet، نعمل الـ stack view برمجياً
    private var starStackView: UIStackView!
    private var starButtons: [UIButton] = []
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Double = 0.0
    var providerId: String?
    var providerName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createStarButtons() // 🔥 إنشاء النجوم برمجياً
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
    
    // 🔥 FIX: إنشاء النجوم برمجياً (يحل مشكلة الـ Storyboard)
    private func createStarButtons() {
        // إنشاء الـ Stack View
        starStackView = UIStackView()
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 8
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // إضافة 5 أزرار نجوم
        for index in 0..<5 {
            let starButton = UIButton(type: .system)
            starButton.tag = index
            starButton.setImage(UIImage(systemName: "star"), for: .normal)
            starButton.tintColor = .systemGray4
            starButton.contentVerticalAlignment = .fill
            starButton.contentHorizontalAlignment = .fill
            starButton.imageView?.contentMode = .scaleAspectFit
            
            // 🔥 إضافة action مباشر
            starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            
            starButtons.append(starButton)
            starStackView.addArrangedSubview(starButton)
        }
        
        // إضافة الـ Stack View للـ view
        view.addSubview(starStackView)
        
        // 🔥 تحديد الموقع (فوق الـ TextView)
        // عدّل القيم حسب تصميمك
        NSLayoutConstraint.activate([
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.bottomAnchor.constraint(equalTo: feedbackTextView.topAnchor, constant: -30),
            starStackView.widthAnchor.constraint(equalToConstant: 250),
            starStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        print("✅ Star buttons created programmatically!")
    }
    
    // 🔥 FIX: معالجة الضغط على النجوم
    @objc private func starButtonTapped(_ sender: UIButton) {
        print("⭐ Star tapped! Tag: \(sender.tag)")
        
        selectedRating = Double(sender.tag) + 1.0
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animation
        UIView.animate(withDuration: 0.15, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                sender.transform = .identity
            }
        }
        
        updateStarsAppearance()
    }
    
    private func updateStarsAppearance() {
        print("🎨 Updating stars. Rating: \(selectedRating)")
        
        UIView.animate(withDuration: 0.25) {
            for (index, button) in self.starButtons.enumerated() {
                let starPosition = Double(index) + 1.0
                
                if self.selectedRating >= starPosition {
                    button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    button.tintColor = .systemYellow
                } else {
                    button.setImage(UIImage(systemName: "star"), for: .normal)
                    button.tintColor = .systemGray4
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
        RatingService.shared.uploadRating(
            stars: stars,
            feedback: feedback,
            providerId: self.providerId,
            completion: { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                self.showErrorAlert()
            } else {
                print("✅ Success!")
                self.saveLocalCopy(stars: stars, feedback: feedback)
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
