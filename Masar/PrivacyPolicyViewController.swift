import UIKit // 👈 لا تنسَ هذا السطر أبداً

class PrivacyPolicyViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy and Policy"
        view.backgroundColor = .systemBackground
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
        
        // --- المحتوى ---
        stackView.addArrangedSubview(createBodyLabel("Masar operates the Local Skills & Services Exchange application.\nThis page is used to inform Masar users regarding our policies with the collection, use, and disclosure of personal information if anyone decides to use our Service."))
        stackView.addArrangedSubview(createBodyLabel("By using the Masar app, you agree to the collection and use of information in accordance with this policy. The personal information that we collect is used for providing, improving, and personalizing our Service. We will not use or share your information with anyone except as described in this Privacy Policy."))
        
        stackView.addArrangedSubview(createSectionTitle("Information Collection and Use"))
        stackView.addArrangedSubview(createBodyLabel("To enhance your experience while using our Service, we may require you to provide certain personally identifiable information, including but not limited to your full name, phone number, location, and service preferences. The information we collect will be used to:"))
        let infoPoints = [
            "Help match users seeking skills or services with those providing them.",
            "Facilitate communication between users.",
            "Improve and personalize your experience in the app."
        ]
        for point in infoPoints { stackView.addArrangedSubview(createBulletPoint(point)) }
        
        stackView.addArrangedSubview(createSectionTitle("Service Providers"))
        stackView.addArrangedSubview(createBodyLabel("We may employ third-party companies and individuals for the following purposes:"))
        let servicePoints = [
            "To assist in improving our Service;",
            "To provide the Service on our behalf;",
            "To analyze app usage and performance."
        ]
        for point in servicePoints { stackView.addArrangedSubview(createBulletPoint(point)) }
        stackView.addArrangedSubview(createBodyLabel("These third parties may have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose."))
        
        stackView.addArrangedSubview(createSectionTitle("Security"))
        stackView.addArrangedSubview(createBodyLabel("We value your trust in providing your personal information and strive to use commercially acceptable means to protect it. However, please remember that no method of transmission over the internet, or method of electronic storage, is 100% secure."))
        
        stackView.addArrangedSubview(createSectionTitle("Links to Other Sites"))
        stackView.addArrangedSubview(createBodyLabel("Our Service may contain links to third-party sites. If you click on a third-party link, you will be directed to that site. We are not responsible for the content or privacy policies of these websites and strongly advise you to review their policies."))
        
        stackView.addArrangedSubview(createSectionTitle("Children’s Privacy"))
        stackView.addArrangedSubview(createBodyLabel("Our Service does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13."))
        
        stackView.addArrangedSubview(createSectionTitle("Changes to This Privacy Policy"))
        stackView.addArrangedSubview(createBodyLabel("We may update this Privacy Policy from time to time. You are advised to review this page periodically for any changes. Changes are effective immediately after being posted on this page."))
        
        stackView.addArrangedSubview(createSectionTitle("Contact Us"))
        stackView.addArrangedSubview(createBodyLabel("If you have any questions or suggestions about our Privacy Policy feel free to contact us at:"))
        
        let email = createBodyLabel("Masar@gmail.com")
        email.textColor = .systemBlue
        stackView.addArrangedSubview(email)
        
        let phone = createBodyLabel("+973-39871234")
        phone.textColor = .systemBlue
        stackView.addArrangedSubview(phone)
    }
    
    // Helpers
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
