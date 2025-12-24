import UIKit

class AdminDashboardViewController: UIViewController {

    private let mainStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainLayout()
    }

    private func setupMainLayout() {
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)

        // 1. Header
        let header = UIView()
        header.backgroundColor = UIColor(red: 0.12, green: 0.17, blue: 0.27, alpha: 1.0)
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text = "Admin Dashboard"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)

        let bellIcon = UIImageView(image: UIImage(systemName: "bell.fill"))
        bellIcon.tintColor = .white
        bellIcon.contentMode = .scaleAspectFit
        bellIcon.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(bellIcon)

        // 2. Main Body Stack
        mainStack.axis = .vertical
        mainStack.spacing = 25
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        // 3. Updated 2x2 Grid Labels
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
        
        // Data for the donut chart
        chartView.segments = [
            ChartSegment(color: .systemOrange, value: 0.40, name: "Electronics"),
            ChartSegment(color: .systemRed, value: 0.10, name: "Fashion"),
            ChartSegment(color: .systemTeal, value: 0.25, name: "Home Goods"),
            ChartSegment(color: .systemBlue, value: 0.15, name: "Books"),
            ChartSegment(color: .systemGreen, value: 0.10, name: "Others")
        ]

        mainStack.addArrangedSubview(topRow)
        mainStack.addArrangedSubview(bottomRow)
        mainStack.addArrangedSubview(chartTitle)
        mainStack.addArrangedSubview(chartView)

        // Constraints
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -15),
            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            
            bellIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            bellIcon.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -25),
            bellIcon.widthAnchor.constraint(equalToConstant: 22),

            mainStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func createCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 10
        
        let tLabel = UILabel()
        tLabel.text = title
        tLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tLabel.textColor = .systemGray
        tLabel.numberOfLines = 2
        
        let vLabel = UILabel()
        vLabel.text = value
        vLabel.font = .systemFont(ofSize: 26, weight: .bold)
        
        let stack = UIStackView(arrangedSubviews: [tLabel, vLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func createHorizontalStack(left: UIView, right: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [left, right])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 18
        return stack
    }
}

// MARK: - Donut Chart Component with Callouts
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
        let radius: CGFloat = 75
        var startAngle: CGFloat = -.pi / 2
        
        for segment in segments {
            let endAngle = startAngle + (2 * .pi * segment.value)
            
            // Draw segment
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            segment.color.setStroke()
            path.lineWidth = 45
            path.stroke()
            
            // Draw Callout Line
            let midAngle = startAngle + (endAngle - startAngle) / 2
            let lineStart = CGPoint(x: center.x + (radius + 28) * cos(midAngle), y: center.y + (radius + 28) * sin(midAngle))
            let lineEnd = CGPoint(x: center.x + (radius + 55) * cos(midAngle), y: center.y + (radius + 55) * sin(midAngle))
            
            let linePath = UIBezierPath()
            linePath.move(to: lineStart)
            linePath.addLine(to: lineEnd)
            UIColor.lightGray.withAlphaComponent(0.6).setStroke()
            linePath.lineWidth = 1.2
            linePath.stroke()
            
            // Draw Label text
            let labelText = "\(segment.name)\n\(Int(segment.value * 100))%"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = cos(midAngle) > 0 ? .left : .right
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
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
