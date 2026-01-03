import UIKit
import FirebaseFirestore
import FirebaseAnalytics

class AdminDashboardViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    
    // Class-level UI elements
    private let totalUsersLabel = UILabel()
    private let totalCategoryLabel = UILabel()
    private let totalReportsLabel = UILabel()
    private let pendingVerificationsLabel = UILabel()
    private let chartView = DonutChart()
    
    private let db = Firestore.firestore()
    
    // 🎨 Brand Color (Purple - matching Moderations Tool)
    private let brandPurple = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar() // 🆕 NEW: Setup purple header
        setupMainLayout()
        fetchFirebaseData()
        updateChartFromFirebase()
    }
    
    // MARK: - 🆕 Navigation Bar Setup (Purple Header)
    private func setupNavigationBar() {
        // Set the navigation bar title
        self.title = "Admin Dashboard"
        
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandPurple // 🎨 Purple background
        
        // Title text attributes (White color)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        // Large title text attributes (for larger navigation bars)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        // Apply the appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Make the navigation bar opaque
        navigationController?.navigationBar.isTranslucent = false
        
        // Set the tint color for navigation bar items (back button, etc.)
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Layout Setup
    private func setupMainLayout() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        mainStack.axis = .vertical
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        // Setup Grid Rows
        let topRow = createHorizontalStack(
            left: createCard(title: "Total\nUsers", valueLabel: totalUsersLabel),
            right: createCard(title: "Total\nCategory", valueLabel: totalCategoryLabel)
        )
        
        let bottomRow = createHorizontalStack(
            left: createCard(title: "Total\nReport", valueLabel: totalReportsLabel),
            right: createCard(title: "Pending\nVerifications", valueLabel: pendingVerificationsLabel)
        )
        
        // Chart Section
        let chartTitle = UILabel()
        chartTitle.text = "Most Booking Categories"
        chartTitle.font = .systemFont(ofSize: 18, weight: .bold)
        chartTitle.textAlignment = .center
        
        // IMPORTANT: We use the class property 'self.chartView' here, NO 'let' keyword.
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        chartView.backgroundColor = .clear
        
        // Set initial placeholder state
        chartView.segments = [
            ChartSegment(color: .systemGray5, value: 1.0, name: "Loading...")
        ]
        
        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(bottomRow)
        mainStack.addArrangedSubview(chartTitle)
        mainStack.addArrangedSubview(chartView)
        
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
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Firebase Data Fetching
    private func fetchFirebaseData() {
        // A. Total Users
        db.collection("users").count.getAggregation(source: .server) { snapshot, _ in
            if let count = snapshot?.count {
                DispatchQueue.main.async { self.totalUsersLabel.text = "\(count)+" }
            }
        }
        
        // B. Total Categories
        db.collection("categories").count.getAggregation(source: .server) { snapshot, _ in
            if let count = snapshot?.count {
                DispatchQueue.main.async { self.totalCategoryLabel.text = "\(count)" }
            }
        }
        
        // C. Total Reports
        db.collection("reports").count.getAggregation(source: .server) { snapshot, _ in
            if let count = snapshot?.count {
                DispatchQueue.main.async { self.totalReportsLabel.text = "\(count)" }
            }
        }
        
        // D. Pending Verifications
        db.collection("provider_requests")
            .whereField("status", isEqualTo: "pending")
            .count.getAggregation(source: .server) { snapshot, error in
                if let count = snapshot?.count {
                    DispatchQueue.main.async { self.pendingVerificationsLabel.text = "\(count)" }
                }
            }
    }
    
    // MARK: - Chart Update Logic (Updated)
    private func updateChartFromFirebase() {
        db.collection("bookings").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Chart Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("⚠️ No booking documents found.")
                DispatchQueue.main.async {
                    self.chartView.segments = [ChartSegment(color: .systemGray4, value: 1.0, name: "No Bookings")]
                }
                return
            }
            
            var counts: [String: Int] = [:]
            
            for doc in documents {
                let data = doc.data()
                
                // Fallback Logic:
                // 1. Try "category" (Ideal)
                // 2. Try "category_name" (Old code)
                // 3. Try "serviceName" (Exists in your DB screenshot)
                // 4. Fallback to "Unknown"
                var category = data["category"] as? String
                               ?? data["category_name"] as? String
                               ?? data["serviceName"] as? String
                               ?? "Unknown"
                
                // Truncate long names (e.g., "iPhone 17 Pro...") to 12 chars so the chart looks clean
                if category.count > 12 {
                    category = String(category.prefix(12)) + ".."
                }
                
                counts[category, default: 0] += 1
            }
            
            let total = CGFloat(documents.count)
            let newSegments = counts.map { (catName, count) -> ChartSegment in
                let percentage = CGFloat(count) / total
                return ChartSegment(
                    color: self.randomColor(),
                    value: percentage,
                    name: catName
                )
            }
            
            // Sort by value so largest slices are first
            let sortedSegments = newSegments.sorted { $0.value > $1.value }
            
            DispatchQueue.main.async {
                self.chartView.segments = sortedSegments
            }
        }
    }
    
    // MARK: - Helper Methods
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
        
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.text = "Loading..."
        
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
    
    private func randomColor() -> UIColor {
        return UIColor(red: .random(in: 0.2...0.8), green: .random(in: 0.2...0.8), blue: .random(in: 0.2...0.8), alpha: 1.0)
    }
}

// MARK: - Supporting Components
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
            let lineEnd = CGPoint(x: center.x + (radius + 50) * cos(midAngle), y: center.y + (radius + 50) * sin(midAngle))
            
            let labelText = "\(segment.name)\n\(Int(segment.value * 100))%"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = cos(midAngle) > 0 ? .left : .right
            
            // 🆕 IMPROVED: Increased font size from 10 to 13 for better readability
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold), // Changed from size 10 to 13, and medium to semibold
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
