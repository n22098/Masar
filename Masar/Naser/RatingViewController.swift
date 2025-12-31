import UIKit
import FirebaseFirestore

class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var providerId: String? // 🔥 إضافة معرف المزود
    var selectedRating: Double = 0.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStarButtons()
        setupUI()
    }
    
    private func setupUI() {
        title = "Rate \(bookingName ?? "Service")"
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        
        // 🎨 تحسين Navigation Bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)
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
        
        // 🎨 تحسين شكل مربع النص
        feedbackTextView.layer.borderWidth = 1
        feedbackTextView.layer.borderColor = UIColor.systemGray5.cgColor
        feedbackTextView.layer.cornerRadius = 16
        feedbackTextView.backgroundColor = .white
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        feedbackTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        feedbackTextView.textColor = .darkText
        
        // ظل خفيف
        feedbackTextView.layer.shadowColor = UIColor.black.cgColor
        feedbackTextView.layer.shadowOpacity = 0.06
        feedbackTextView.layer.shadowOffset = CGSize(width: 0, height: 4)
        feedbackTextView.layer.shadowRadius = 8
    }
    
    private func setupStarButtons() {
        guard let stack = starStackView else { return }
        for (i, view) in stack.arrangedSubviews.enumerated() {
            if let btn = view as? UIButton {
                btn.tag = i
                // إزالة التارجت القديم وإضافة مستشعر لمس لمعرفة مكان الضغطة
                // btn.addTarget... (تم حذفه)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStarTap(_:)))
                btn.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    // MARK: - Actions
    // دالة جديدة لحساب النصف نجمة
    @objc func handleStarTap(_ gesture: UITapGestureRecognizer) {
        guard let btn = gesture.view as? UIButton else { return }
        
        let location = gesture.location(in: btn)
        let midPoint = btn.bounds.width / 2
        let tag = Double(btn.tag)
        
        // إذا ضغط في النصف الأيسر = .5، وإذا في الأيمن = 1.0
        if location.x < midPoint {
            selectedRating = tag + 0.5
        } else {
            selectedRating = tag + 1.0
        }
        
        updateStars()
    }
    
    private func updateStars() {
        guard let stack = starStackView else { return }
        for (i, view) in stack.arrangedSubviews.enumerated() {
            if let btn = view as? UIButton {
                let btnIndex = Double(i)
                
                if selectedRating >= btnIndex + 1 {
                    // نجمة كاملة
                    btn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else if selectedRating > btnIndex {
                    // نصف نجمة
                    btn.setImage(UIImage(systemName: "star.leadinghalf.filled"), for: .normal)
                } else {
                    // نجمة فارغة
                    btn.setImage(UIImage(systemName: "star"), for: .normal)
                }
                
                btn.tintColor = .systemYellow
            }
        }
    }
    
    @IBAction func submitRatingTapped(_ sender: UIButton) {
        guard selectedRating > 0 else {
            let alert = UIAlertController(title: "Alert", message: "Please select a star rating first.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let feedback = feedbackTextView.text ?? ""
        let bName = bookingName ?? "Unknown Service"
        
        // إيقاف الزر لمنع التكرار
        sender.isEnabled = false
        
        // 🔥 تمرير providerId للسيرفس
        RatingService.shared.uploadRating(stars: selectedRating, feedback: feedback, bookingName: bName, providerId: providerId) { [weak self] error in
            sender.isEnabled = true
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // إشعار لتحديث الصفحة السابقة
            NotificationCenter.default.post(name: NSNotification.Name("RatingAdded"), object: nil)
            
            // رسالة نجاح والعودة
            let successAlert = UIAlertController(title: "Thank You!", message: "Feedback submitted.", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            self?.present(successAlert, animated: true)
        }
    }
}
