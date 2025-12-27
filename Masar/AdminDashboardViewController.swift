import UIKit
import FirebaseFirestore // Add this
import FirebaseAnalytics // Add this

class AdminDashboardViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()

    private let totalUsersLabel = UILabel()
        private let totalCategoryLabel = UILabel()
        private let totalReportsLabel = UILabel()
        private let pendingVerificationsLabel = UILabel()
        private let chartView = DonutChart() // Make this a property too

        let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainLayout()
    }

    private func setupMainLayout() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
     
        
        // 1. ScrollView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // 2. Main Body Stack
        mainStack.axis = .vertical
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        // 3. Grid Rows
        // Change this:
        let topRow = createHorizontalStack(
            left: createCard(title: "Total\nUsers", valueLabel: totalUsersLabel), // Pass the variable, not "2,300+"
            right: createCard(title: "Total\nCategory", valueLabel: totalCategoryLabel)
        )

        let bottomRow = createHorizontalStack(
            left: createCard(title: "Total\nReport", valueLabel: totalReportsLabel),
            right: createCard(title: "Pending\nVerifications", valueLabel: pendingVerificationsLabel)
        )

        // 4. Chart Section
        let chartTitle = UILabel()
        chartTitle.text = "Most Booking Categories"
        chartTitle.font = .systemFont(ofSize: 18, weight: .bold)
        chartTitle.textAlignment = .center

        let chartView = DonutChart()
        chartView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        chartView.backgroundColor = .clear
        
        chartView.segments = [
            ChartSegment(color: .systemOrange, value: 0.40, name: "Electronics"),
            ChartSegment(color: .systemRed, value: 0.10, name: "Fashion"),
            ChartSegment(color: .systemTeal, value: 0.25, name: "Home Goods"),
            ChartSegment(color: .systemBlue, value: 0.15, name: "Books"),
            ChartSegment(color: .systemGreen, value: 0.10, name: "Others")
        ]

        // Add everything to stack
        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(bottomRow)
        mainStack.addArrangedSubview(chartTitle)
        mainStack.addArrangedSubview(chartView)

        // 5. Constraints (Pinned to Top Safe Area)
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

            // Main stack now starts immediately at the top of the content view
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func createCard(title: String, valueLabel: UILabel) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        
        let tLabel = UILabel()
            tLabel.text = title
            tLabel.font = .systemFont(ofSize: 14, weight: .medium)
            tLabel.textColor = .systemGray
            tLabel.numberOfLines = 2

            // Style the valueLabel passed into the function
            valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
            valueLabel.text = "Loading..." // Initial state

            let stack = UIStackView(arrangedSubviews: [tLabel, valueLabel])
            stack.axis = .vertical
            stack.spacing = 6
            stack.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func createHorizontalStack(left: UIView, right: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [left, right])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }
    private func fetchFirebaseData() {
        // 1. Fetch User Count
        db.collection("users").count.getAggregation(source: .server) { snapshot, error in
            if let count = snapshot?.count {
                DispatchQueue.main.async {
                    self.totalUsersLabel.text = "\(count)+"
                }
            }
        }

        // 2. Fetch Category Count
        db.collection("categories").count.getAggregation(source: .server) { snapshot, error in
            if let count = snapshot?.count {
                DispatchQueue.main.async {
                    self.totalCategoryLabel.text = "\(count)"
                }
            }
        }
    }
    private func updateChartFromFirebase() {
        db.collection("bookings").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            
            // Count occurrences of each category
            var counts: [String: Int] = [:]
            for doc in documents {
                let cat = doc.get("category_name") as? String ?? "Other"
                counts[cat, default: 0] += 1
            }
            
            // Convert to segments for your DonutChart
            let total = CGFloat(documents.count)
            self.chartView.segments = counts.map { (key, value) in
                ChartSegment(color: self.randomColor(), value: CGFloat(value) / total, name: key)
            }
        }
    }

    // Helper for dynamic chart colors
    private func randomColor() -> UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
}

// MARK: - Donut Chart Component
struct ChartSegment {
    let color: UIColor
    let value: CGFloat
    let name: String
}

class DonutChart: UIView {
    var segments: [ChartSegment] = [] { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = 70
        var startAngle: CGFloat = -.pi / 2
        
        for segment in segments {
            let endAngle = startAngle + (2 * .pi * segment.value)
            
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            segment.color.setStroke()
            path.lineWidth = 40
            path.stroke()
            
            let midAngle = startAngle + (endAngle - startAngle) / 2
            let lineStart = CGPoint(x: center.x + (radius + 25) * cos(midAngle), y: center.y + (radius + 25) * sin(midAngle))
            let lineEnd = CGPoint(x: center.x + (radius + 50) * cos(midAngle), y: center.y + (radius + 50) * sin(midAngle))
            
            let linePath = UIBezierPath()
            linePath.move(to: lineStart)
            linePath.addLine(to: lineEnd)
            UIColor.lightGray.withAlphaComponent(0.4).setStroke()
            linePath.lineWidth = 1.0
            linePath.stroke()
            
            let labelText = "\(segment.name)\n\(Int(segment.value * 100))%"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = cos(midAngle) > 0 ? .left : .right
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]
            
            let size = labelText.size(withAttributes: attrs)
            let xPos = cos(midAngle) > 0 ? lineEnd.x + 5 : lineEnd.x - size.width - 5
            let yPos = lineEnd.y - (size.height / 2)
            
            labelText.draw(at: CGPoint(x: xPos, y: yPos), withAttributes: attrs)
            startAngle = endAngle
        }
    }
}
