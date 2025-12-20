import UIKit // 👈 هذا السطر هو الأهم وهو الناقص عندك

class AboutViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        view.backgroundColor = .systemBackground
        
        // إظهار البار العلوي
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setupScrollView()
        setupContent()
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // --- إضافة المحتوى ---
        stackView.addArrangedSubview(createTitleLabel("Welcome to Masar!"))
        stackView.addArrangedSubview(createBodyLabel("At Masar, we believe in the power of community — where people can share their skills, offer their services, and connect with others who need them. Our mobile application is designed to make it easier for individuals in the Kingdom of Bahrain to find, offer, and exchange local skills and services in a convenient and trustworthy way."))
        
        stackView.addArrangedSubview(createSectionTitle("Our Mission"))
        stackView.addArrangedSubview(createBodyLabel("Empower individuals and small service providers by giving them a platform to showcase their talents and connect with people who need their expertise.\nWhether you’re a handyman, tutor, designer, or mechanic, Masar helps you reach those who need your help quickly and easily."))
        
        stackView.addArrangedSubview(createSectionTitle("What We Offer"))
        let offers = [
            "Skill & Service Search: Browse and search for local professionals or individuals offering the services you need — from home repairs to photography, tutoring, and more.",
            "Service Posting: If you have a skill or service to offer, create a profile and post your services within minutes. Let others in your community find and hire you with ease.",
            "Secure Communication: Contact service providers or clients directly through our secure in-app messaging feature — fast, safe, and simple.",
            "Ratings & Reviews: We value trust and transparency. That’s why users can rate and review each other’s services to help maintain quality and reliability across the community.",
            "Location-Based Results: Find nearby service providers instantly using our location-based search — connecting you with people in your area who can help right away.",
            "User-Friendly Interface: Our app is built with simplicity and usability in mind. Whether you’re offering a service or searching for one, Masar makes it straightforward and intuitive for everyone."
        ]
        for offer in offers {
            stackView.addArrangedSubview(createBulletPoint(offer))
        }
        
        stackView.addArrangedSubview(createSectionTitle("Our Vision"))
        stackView.addArrangedSubview(createBodyLabel("We aim to create a connected community in Bahrain where skills, services, and opportunities can be exchanged with ease.\nMasar aspires to become the go-to local platform for people to discover, collaborate, and grow together."))
        
        stackView.addArrangedSubview(createSectionTitle("Join Us"))
        stackView.addArrangedSubview(createBodyLabel("Download Masar today and become part of a community built on trust, collaboration, and local connection. Whether you’re looking for help or ready to offer your expertise, Masar is here to make it happen."))
        
        let footerLabel = createBodyLabel("East or west Masar is the Best")
        footerLabel.font = .italicSystemFont(ofSize: 18)
        footerLabel.textAlignment = .center
        footerLabel.textColor = .systemPurple
        stackView.addArrangedSubview(footerLabel)
    }
    
    // Helpers
    func createTitleLabel(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.font = .systemFont(ofSize: 26, weight: .bold); l.numberOfLines = 0; l.textColor = .systemPurple; return l
    }
    func createSectionTitle(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.font = .systemFont(ofSize: 20, weight: .bold); l.numberOfLines = 0; return l
    }
    func createBodyLabel(_ text: String) -> UILabel {
        let l = UILabel(); l.text = text; l.font = .systemFont(ofSize: 16); l.numberOfLines = 0; l.textColor = .darkGray; return l
    }
    func createBulletPoint(_ text: String) -> UILabel {
        let l = UILabel(); l.text = "• " + text; l.font = .systemFont(ofSize: 16); l.numberOfLines = 0; l.textColor = .darkGray; return l
    }
}
