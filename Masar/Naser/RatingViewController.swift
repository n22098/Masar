import UIKit
import FirebaseFirestore

class RatingViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate Your Experience"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = "Write Your Feedback:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let feedbackTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .darkText
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 16
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray5.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.shadowColor = UIColor.black.cgColor
        tv.layer.shadowOpacity = 0.05
        tv.layer.shadowOffset = CGSize(width: 0, height: 2)
        tv.layer.shadowRadius = 4
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit Rating", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        return btn
    }()
    
    // MARK: - Properties
    var bookingName: String?
    var providerId: String?
    var providerName: String?
    private var selectedRating: Double = 0.0
    private let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStars()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
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
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(starsStackView)
        contentView.addSubview(feedbackLabel)
        contentView.addSubview(feedbackTextView)
        contentView.addSubview(submitButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            starsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            starsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            feedbackLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 32),
            feedbackLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            feedbackTextView.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 12),
            feedbackTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feedbackTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            feedbackTextView.heightAnchor.constraint(equalToConstant: 150),
            
            submitButton.topAnchor.constraint(equalTo: feedbackTextView.bottomAnchor, constant: 32),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 56),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupStars() {
        for i in 0..<5 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemGray3
            button.tag = i
            button.imageView?.contentMode = .scaleAspectFit
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStarTap(_:)))
            button.addGestureRecognizer(tapGesture)
            
            starsStackView.addArrangedSubview(button)
        }
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitRatingTapped), for: .touchUpInside)
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
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
    
    @objc private func submitRatingTapped() {
        guard selectedRating > 0 else {
            showAlert(title: "Rating Required", message: "Please select a star rating before submitting.")
            return
        }
        
        let feedback = feedbackTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let serviceName = bookingName ?? "Service"
        
        guard let providerId = providerId else {
            showAlert(title: "Error", message: "Provider information is missing.")
            return
        }
        
        submitButton.isEnabled = false
        submitButton.setTitle("Submitting...", for: .normal)
        
        let seekerId = UserManager.shared.currentUser?.email
        let seekerName = UserManager.shared.currentUser?.name
        
        RatingService.shared.uploadRating(
            stars: selectedRating,
            feedback: feedback,
            bookingName: serviceName,
            providerId: providerId,
            seekerId: seekerId,
            seekerName: seekerName
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.submitButton.isEnabled = true
                self?.submitButton.setTitle("Submit Rating", for: .normal)
                
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
