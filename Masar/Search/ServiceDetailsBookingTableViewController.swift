import UIKit

class ServiceDetailsBookingTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var serviceItemLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var receivedServiceItems: String?
    
    var providerData: ServiceProviderModel?
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fillData()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 12 }
        
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
        }
        
        if let picker = datePicker {
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .trailing
        }
    }
    
    func setupNavigationBar() {
        self.title = "Booking"
        let bookButton = UIBarButtonItem(title: "Book", style: .done, target: self, action: #selector(topBookTapped))
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
    }
    
    @objc func topBookTapped() { showBookingConfirmation() }
    
    func fillData() {
        serviceNameLabel?.text = receivedServiceName ?? "Unknown"
        
        if let price = receivedServicePrice {
            priceLabel?.text = price.replacingOccurrences(of: "BHD ", with: "")
        } else {
            priceLabel?.text = "0"
        }
        
        descriptionLabel?.text = receivedServiceDetails ?? "No description"
        descriptionLabel?.numberOfLines = 0
        
        if let items = receivedServiceItems, !items.isEmpty, items != "None" {
            serviceItemLabel?.text = items
            serviceItemLabel?.textColor = .black
        } else {
            serviceItemLabel?.text = "None"
            serviceItemLabel?.textColor = .darkGray
        }
        serviceItemLabel?.numberOfLines = 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 { return 90 }
        return UITableView.automaticDimension
    }
    
    @IBAction func bookButtonPressed(_ sender: Any) { showBookingConfirmation() }
    
    func showBookingConfirmation() {
        let alert = UIAlertController(title: "Confirm Booking", message: "Proceed with booking?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            self?.showPaymentScreen()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Payment Screen
    func showPaymentScreen() {
        let paymentVC = PaymentViewController()
        paymentVC.bookingData = createBookingModel()
        paymentVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func createBookingModel() -> BookingModel {
        let serviceName = receivedServiceName ?? "Unknown"
        let priceString = receivedServicePrice?.replacingOccurrences(of: "BHD ", with: "") ?? "0"
        let price = Double(priceString) ?? 0.0
        let date = datePicker.date
        let providerName = providerData?.name ?? "Unknown"
        
        let currentUser = UserManager.shared.currentUser
        let seekerName = currentUser?.name ?? "Guest"
        let seekerEmail = currentUser?.email ?? "no-email"
        let seekerPhone = currentUser?.phone ?? "No Phone"
        
        let realDescription = receivedServiceDetails ?? "No details provided"
        var itemsText = receivedServiceItems ?? "None"
        if itemsText.isEmpty { itemsText = "None" }
        
        return BookingModel(
            seekerName: seekerName,
            serviceName: serviceName,
            date: date,
            status: .upcoming,
            providerName: providerName,
            email: seekerEmail,
            phoneNumber: seekerPhone,
            price: price,
            instructions: itemsText,
            descriptionText: realDescription
        )
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        if #available(iOS 14.0, *) {
            var bg = UIBackgroundConfiguration.clear()
            bg.backgroundColor = .white
            bg.cornerRadius = 16
            bg.backgroundInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            cell.backgroundConfiguration = bg
        }
    }
}

// MARK: - Payment View Controller
class PaymentViewController: UIViewController {
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    
    var bookingData: BookingModel?
    var selectedPaymentMethod: PaymentMethod = .creditCard
    
    enum PaymentMethod {
        case creditCard, applePay, benefitPay
    }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let paymentMethodsLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Payment Method"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var creditCardButton = createPaymentButton(title: "💳 Credit Card", tag: 0)
    private lazy var applePayButton = createPaymentButton(title: " Apple Pay", tag: 1)
    private lazy var benefitPayButton = createPaymentButton(title: "🔵 Benefit Pay", tag: 2)
    
    private let cardDetailsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardNumberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Card Number"
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let validThruTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "MM/YY"
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let cvcTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "CVC"
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let pinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "PIN"
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let purchaseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Purchase", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updatePaymentMethodSelection()
    }
    
    private func setupUI() {
        title = "Payment"
        view.backgroundColor = lightBg
        
        purchaseButton.backgroundColor = brandColor
        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        
        creditCardButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        applePayButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        benefitPayButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        
        cardNumberTextField.delegate = self
        validThruTextField.delegate = self
        cvcTextField.delegate = self
        pinTextField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(paymentMethodsLabel)
        contentView.addSubview(creditCardButton)
        contentView.addSubview(applePayButton)
        contentView.addSubview(benefitPayButton)
        contentView.addSubview(cardDetailsContainer)
        contentView.addSubview(purchaseButton)
        
        cardDetailsContainer.addSubview(cardNumberTextField)
        cardDetailsContainer.addSubview(validThruTextField)
        cardDetailsContainer.addSubview(cvcTextField)
        cardDetailsContainer.addSubview(pinTextField)
        
        addTextFieldSeparators()
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
            
            paymentMethodsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            paymentMethodsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            creditCardButton.topAnchor.constraint(equalTo: paymentMethodsLabel.bottomAnchor, constant: 16),
            creditCardButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            creditCardButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            creditCardButton.heightAnchor.constraint(equalToConstant: 56),
            
            applePayButton.topAnchor.constraint(equalTo: creditCardButton.bottomAnchor, constant: 12),
            applePayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            applePayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            applePayButton.heightAnchor.constraint(equalToConstant: 56),
            
            benefitPayButton.topAnchor.constraint(equalTo: applePayButton.bottomAnchor, constant: 12),
            benefitPayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            benefitPayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            benefitPayButton.heightAnchor.constraint(equalToConstant: 56),
            
            cardDetailsContainer.topAnchor.constraint(equalTo: benefitPayButton.bottomAnchor, constant: 24),
            cardDetailsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardDetailsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardDetailsContainer.heightAnchor.constraint(equalToConstant: 240),
            
            cardNumberTextField.topAnchor.constraint(equalTo: cardDetailsContainer.topAnchor, constant: 20),
            cardNumberTextField.leadingAnchor.constraint(equalTo: cardDetailsContainer.leadingAnchor, constant: 16),
            cardNumberTextField.trailingAnchor.constraint(equalTo: cardDetailsContainer.trailingAnchor, constant: -16),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: 44),
            
            validThruTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 16),
            validThruTextField.leadingAnchor.constraint(equalTo: cardDetailsContainer.leadingAnchor, constant: 16),
            validThruTextField.widthAnchor.constraint(equalTo: cardDetailsContainer.widthAnchor, multiplier: 0.42),
            validThruTextField.heightAnchor.constraint(equalToConstant: 44),
            
            cvcTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 16),
            cvcTextField.trailingAnchor.constraint(equalTo: cardDetailsContainer.trailingAnchor, constant: -16),
            cvcTextField.widthAnchor.constraint(equalTo: cardDetailsContainer.widthAnchor, multiplier: 0.42),
            cvcTextField.heightAnchor.constraint(equalToConstant: 44),
            
            pinTextField.topAnchor.constraint(equalTo: validThruTextField.bottomAnchor, constant: 16),
            pinTextField.leadingAnchor.constraint(equalTo: cardDetailsContainer.leadingAnchor, constant: 16),
            pinTextField.trailingAnchor.constraint(equalTo: cardDetailsContainer.trailingAnchor, constant: -16),
            pinTextField.heightAnchor.constraint(equalToConstant: 44),
            
            purchaseButton.topAnchor.constraint(equalTo: cardDetailsContainer.bottomAnchor, constant: 32),
            purchaseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            purchaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            purchaseButton.heightAnchor.constraint(equalToConstant: 54),
            purchaseButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func createPaymentButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = tag
        return btn
    }
    
    private func addTextFieldSeparators() {
        addSeparator(below: cardNumberTextField, in: cardDetailsContainer)
        addSeparator(below: validThruTextField, in: cardDetailsContainer)
        addSeparator(below: cvcTextField, in: cardDetailsContainer)
        addSeparator(below: pinTextField, in: cardDetailsContainer)
    }
    
    private func addSeparator(below textField: UITextField, in container: UIView) {
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    @objc private func paymentMethodTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0: selectedPaymentMethod = .creditCard
        case 1: selectedPaymentMethod = .applePay
        case 2: selectedPaymentMethod = .benefitPay
        default: break
        }
        updatePaymentMethodSelection()
    }
    
    private func updatePaymentMethodSelection() {
        [creditCardButton, applePayButton, benefitPayButton].forEach { btn in
            btn.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            btn.layer.borderWidth = 2
        }
        
        let selectedButton: UIButton
        switch selectedPaymentMethod {
        case .creditCard: selectedButton = creditCardButton
        case .applePay: selectedButton = applePayButton
        case .benefitPay: selectedButton = benefitPayButton
        default: selectedButton = creditCardButton
        }
        
        selectedButton.layer.borderColor = brandColor.cgColor
        selectedButton.layer.borderWidth = 3
        
        // Show/hide card details based on payment method
        if selectedPaymentMethod == .creditCard {
            cardDetailsContainer.isHidden = false
        } else {
            cardDetailsContainer.isHidden = true
        }
    }
    
    @objc private func purchaseButtonTapped() {
        view.endEditing(true)
        
        // Save booking to Firebase here
        if let booking = bookingData {
            ServiceManager.shared.saveBooking(booking: booking) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        let alert = UIAlertController(title: "Success", message: "Payment Successfully Completed!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

extension PaymentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == cardNumberTextField {
            return updatedText.count <= 16
        } else if textField == validThruTextField {
            return updatedText.count <= 5
        } else if textField == cvcTextField {
            return updatedText.count <= 3
        } else if textField == pinTextField {
            return updatedText.count <= 4
        }
        
        return true
    }
}
