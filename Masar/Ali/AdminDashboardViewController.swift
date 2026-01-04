import UIKit
import FirebaseFirestore
import FirebaseAnalytics

/// AdminDashboardViewController: The primary overview for administrators to monitor app health.
/// OOD Principle: Composition - This class builds a complex UI by composing small,
/// reusable helper methods (like createCard) into a main layout.
class AdminDashboardViewController: UIViewController {
    
    // MARK: - Properties
    // Layout containers
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    
    // Class-level UI elements (Encapsulation: private keeps them safe from external interference)
    private let totalUsersLabel = UILabel()
    private let totalCategoryLabel = UILabel()
    private let totalReportsLabel = UILabel()
    private let pendingVerificationsLabel = UILabel()
    
    /// chartView: A custom-drawn UIView used for data visualization.
    private let chartView = DonutChart()
    
    /// Reference to the Firestore database
    private let db = Firestore.firestore()
    
    // 🎨 Brand Identity: Centralized color management
    private let brandPurple = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar() // Styling the header
        setupMainLayout()    // Building the UI grid
        fetchFirebaseData()  // Getting the raw numbers
        updateChartFromFirebase() // Building the visual chart
    }
    
    // MARK: - Navigation Bar Setup
    
    /// Configures the professional purple header for the admin section.
    private func setupNavigationBar() {
        self.title = "Admin Dashboard"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandPurple // 🎨 Branding consistency
        
        // Title Styling (White text for contrast)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Layout Setup
    
    /// Programmatically builds the dashboard layout using nested StackViews.
    private func setupMainLayout() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // MainStack: The vertical container for the whole screen
        mainStack.axis = .vertical
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        // Creating the Grid: 2 rows with 2 cards each
        let topRow = createHorizontalStack(
            left: createCard(title: "Total\nUsers", valueLabel: totalUsersLabel),
            right: createCard(title: "Total\nCategory", valueLabel: totalCategoryLabel)
        )
        
        let bottomRow = createHorizontalStack(
            left: createCard(title: "Total\nReport", valueLabel: totalReportsLabel),
            right: createCard(title: "Pending\nVerifications", valueLabel: pendingVerificationsLabel)
        )
        
        // Chart Heading
        let chartTitle = UILabel()
        chartTitle.text = "Most Booking Categories"
        chartTitle.font = .systemFont(ofSize: 18, weight: .bold)
        chartTitle.textAlignment = .center
        
        // Chart Configuration
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 320).isActive = true
        chartView.backgroundColor = .clear
        
        // Default state before data arrives
        chartView.segments = [
            ChartSegment(color: .systemGray5, value: 1.0, name: "Loading...")
        ]
        
        // Adding everything to the main stack
        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(bottomRow)
        mainStack.addArrangedSubview(chartTitle)
        mainStack.addArrangedSubview(chartView)
        
        // MARK: - Auto Layout Constraints
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
    
    /// Uses Firebase Aggregation Queries to count documents without downloading the entire collection.
    /// OOD Principle: Efficiency - Using .count is much faster and saves data/bandwidth.
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
        
        // D. Pending Verifications (Filtered Query)
        db.collection("provider_requests")
            .whereField("status", isEqualTo: "pending")
            .count.getAggregation(source: .server) { snapshot, error in
                if let count = snapshot?.count {
                    DispatchQueue.main.async { self.pendingVerificationsLabel.text = "\(count)" }
                }
            }
    }
    
    // MARK: - Chart Update Logic
    
    /// Pulls booking data and calculates percentage distribution for the donut chart.
    private func updateChartFromFirebase() {
        db.collection("bookings").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Chart Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                DispatchQueue.main.async {
                    self.chartView.segments = [ChartSegment(color: .systemGray4, value: 1.0, name: "No Bookings")]
                }
                return
            }
            
            // Logic: Tallying the occurrences of each category
            var counts: [String: Int] = [:]
            
            for doc in documents {
                let data = doc.data()
                
                // Fallback Logic: Handling different naming conventions in the database
                var category = data["category"] as? String
                               ?? data["category_name"] as? String
                               ?? data["serviceName"] as? String
                               ?? "Unknown"
                
                // UX: Clean up long category names for the chart labels
                if category.count > 12 {
                    category = String(category.prefix(12)) + ".."
                }
                
                counts[category, default: 0] += 1
            }
            
            let total = CGFloat(documents.count)
            let newSegments = counts.map { (catName, count) -> ChartSegment in
                let percentage = CGFloat(count) / total
                return ChartSegment(
                    color: self.randomColor(), // Assign unique color per segment
                    value: percentage,
                    name: catName
                )
            }
            
            // OOD Principle: Sorting - Ordering data to make the visualization more intuitive
            let sortedSegments = newSegments.sorted { $0.value > $1.value }
            
            DispatchQueue.main.async {
                self.chartView.segments = sortedSegments
            }
        }
    }
    
    // MARK: - UI Helper Methods
    
    /// createCard: A factory method to create uniform dashboard metric cards.
    /// OOD Principle: Reusability - This avoids duplicating UI code for each metric.
    private func createCard(title: String, valueLabel: UILabel) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        
        // Shadow effects for "Elevated" design
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

// MARK: - Data Models
struct ChartSegment {
    let color: UIColor
    let value: CGFloat
    let name: String
}

// MARK: - Custom View: DonutChart
/// DonutChart: Uses Core Graphics to draw a mathematical representation of data.
class DonutChart: UIView {
    
    /// Property Observer: Triggers a redraw whenever the data changes.
    var segments: [ChartSegment] = [] { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty else { return }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = 70
        var startAngle: CGFloat = -.pi / 2 // Start at 12 o'clock
        
        for segment in segments {
            // Mathematical arc calculation
            let endAngle = startAngle + (2 * .pi * segment.value)
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            segment.color.setStroke()
            path.lineWidth = 40 // Thickness of the donut
            path.stroke()
            
            // MARK: - Label Drawing Logic
            let midAngle = startAngle + (endAngle - startAngle) / 2
            let lineEnd = CGPoint(x: center.x + (radius + 50) * cos(midAngle), y: center.y + (radius + 50) * sin(midAngle))
            
            let labelText = "\(segment.name)\n\(Int(segment.value * 100))%"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = cos(midAngle) > 0 ? .left : .right
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]
            
            let size = labelText.size(withAttributes: attrs)
            let xPos = cos(midAngle) > 0 ? lineEnd.x + 5 : lineEnd.x - size.width - 5
            let yPos = lineEnd.y - (size.height / 2)
            
            labelText.draw(at: CGPoint(x: xPos, y: yPos), withAttributes: attrs)
            
            // Advance the angle for the next slice
            startAngle = endAngle
        }
    }
}
