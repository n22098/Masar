import UIKit
import FirebaseFirestore

class RatingViewController: UIViewController {
    
    // MARK: - IBOutlets (for Storyboard)
    @IBOutlet weak var feedbackTextView: UITextView?
    @IBOutlet weak var starStackView: UIStackView?
    
    // MARK: - Programmatic UI Components (if not using Storyboard)
    private var programmaticFeedbackTextView: UITextView?
    private var programmaticStarStackView: UIStackView?
    private var programmaticSubmitButton: UIButton?
    
    // MARK: - Properties
    var bookingName: String?
    var providerId: String?
    var providerName: String?
    private var selectedRating: Double = 0.0
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if we're using Storyboard or Programmatic UI
        if feedbackTextView == nil {
            setupProgrammaticUI()
        } else {
            setupStoryboardUI()
        }
        
        setupStars()
    }
    
    // MARK: - Setup for Storyboard
    private func setupStoryboardUI() {
        title = "Rating"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // Navigation Bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Style the text view
        if let textView = feedbackTextView {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.systemGray5.cgColor
            textView.layer.cornerRadius = 16
            textView.backgroundColor = .white
            textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.layer.shadowColor = UIColor.black.cgColor
            textView.layer.shadowOpacity = 0.05
            textView.layer.shadowOffset = CGSize(width: 0, height: 2)
            textView.layer.shadowRadius = 4
        }
    }
    
    // MARK: - Setup for Programmatic UI
    private func setupProgrammaticUI() {
        title = "Rating"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // Navigation Bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        // Create UI
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let profileIcon = UIImageView()
        profileIcon.image = UIImage(systemName: "person.circle.fill")
        profileIcon.tintColor = brandColor
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Rate Your Experience"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 12
        starsStack.distribution = .fillEqually
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        programmaticStarStackView = starsStack
        
        let feedbackLabel = UILabel()
        feedbackLabel.text = "Write Your Feedback:"
        feedbackLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        feedbackLabel.textColor = .darkGray
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 16
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        programmaticFeedbackTextView = textView
        
        let submitBtn = UIButton(type: .system)
        submitBtn.setTitle("Submit Rating", for: .normal)
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        submitBtn.backgroundColor = brandColor
        submitBtn.layer.cornerRadius = 16
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
        submitBtn.addTarget(self, action: #selector(submitRatingTapped), for: .touchUpInside)
        programmaticSubmitButton = submitBtn
        
        contentView.addSubview(profileIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(starsStack)
        contentView.addSubview(feedbackLabel)
        contentView.addSubview(textView)
        contentView.addSubview(submitBtn)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            profileIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 80),
            profileIcon.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: profileIcon.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            starsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            starsStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            starsStack.heightAnchor.constraint(equalToConstant: 50),
            
            feedbackLabel.topAnchor.constraint(equalTo: starsStack.bottomAnchor, constant: 32),
            feedbackLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            textView.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            submitBtn.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 32),
            submitBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitBtn.heightAnchor.constraint(equalToConstant: 56),
            submitBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Setup Stars
    private func setupStars() {
        let stack = starStackView ?? programmaticStarStackView
        guard let stackView = stack else { return }
        
        // Clear existing stars
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add 5 star buttons
        for i in 0..<5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemGray3
            button.tag = i
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStarTap(_:)))
            button.addGestureRecognizer(tapGesture)
            
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Actions
    @objc private func handleStarTap(_ gesture: UITapGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }
        
        let location = gesture.location(in: button)
        let midPoint = button.bounds.width / 2
        let tag = Double(button.tag)
        
        // Half or full star
        if location.x < midPoint {
            selectedRating = tag + 0.5
        } else {
            selectedRating = tag + 1.0
        }
        
        updateStars()
    }
    
    private func updateStars() {
        let stack = starStackView ?? programmaticStarStackView
        guard let stackView = stack else { return }
        
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }
            let btnIndex = Double(index)
            
            if selectedRating >= btnIndex + 1 {
                button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                button.tintColor = .systemYellow
            } else if selectedRating > btnIndex {
                button.setImage(UIImage(systemName: "star.leadinghalf.filled"), for: .normal)
                button.tintColor = .systemYellow
            } else {
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.tintColor = .systemGray3
            }
        }
    }
    
    @IBAction func submitRatingTapped(_ sender: Any) {
        guard selectedRating > 0 else {
            showAlert(title: "Rating Required", message: "Please select a star rating before submitting.")
            return
        }
        
        let textView = feedbackTextView ?? programmaticFeedbackTextView
        let feedback = textView?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let serviceName = bookingName ?? "Service"
        
        guard let providerId = providerId else {
            showAlert(title: "Error", message: "Provider information is missing.")
            return
        }
        
        // Disable button
        if let btn = sender as? UIButton {
            btn.isEnabled = false
            btn.setTitle("Submitting...", for: .normal)
        }
        
        let seekerId = UserManager.shared.currentUser?.email
        let seekerName = UserManager.shared.currentUser?.name
        
        print("⭐ [RatingVC] Submitting rating:")
        print("   - Stars: \(selectedRating)")
        print("   - Seeker: \(seekerName ?? "nil")")
        print("   - Provider ID: \(providerId)")
        
        RatingService.shared.uploadRating(
            stars: selectedRating,
            feedback: feedback,
            bookingName: serviceName,
            providerId: providerId,
            seekerId: seekerId,
            seekerName: seekerName
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let btn = sender as? UIButton {
                    btn.isEnabled = true
                    btn.setTitle("Submit Rating", for: .normal)
                }
                
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to submit rating: \(error.localizedDescription)")
                } else {
                    self?.showSuccessAndDismiss()
                }
            }
        }
    }
    
    private func showSuccessAndDismiss() {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Your feedback has been submitted successfully.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
