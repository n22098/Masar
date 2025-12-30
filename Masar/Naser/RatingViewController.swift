import UIKit
import FirebaseFirestore

class RatingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var starStackView: UIStackView!
    
    // MARK: - Properties
    var bookingName: String?
    var selectedRating: Double = 0.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStarButtons()
        setupUI()
    }
    
    private func setupUI() {
        title = "Rate \(bookingName ?? "Service")"
        // تحسين شكل مربع النص
        feedbackTextView.layer.borderWidth = 1
        feedbackTextView.layer.borderColor = UIColor.systemGray5.cgColor
        feedbackTextView.layer.cornerRadius = 12
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        
        // استخدام السيرفس الجديد
        RatingService.shared.uploadRating(stars: selectedRating, feedback: feedback, bookingName: bName) { [weak self] error in
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
