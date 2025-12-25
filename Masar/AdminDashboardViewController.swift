import UIKit

class AdminDashboardViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()

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
        let topRow = createHorizontalStack(
            left: createCard(title: "Total\nUsers", value: "2,300+"),
            right: createCard(title: "Total\nCategory", value: "540")
        )
        
        let bottomRow = createHorizontalStack(
            left: createCard(title: "Total\nReport", value: "15"),
            right: createCard(title: "Pending\nVerifications", value: "2,300+")
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

    private func createCard(title: String, value: String) -> UIView {
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
        
        let vLabel = UILabel()
        vLabel.text = value
        vLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        let stack = UIStackView(arrangedSubviews: [tLabel, vLabel])
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
