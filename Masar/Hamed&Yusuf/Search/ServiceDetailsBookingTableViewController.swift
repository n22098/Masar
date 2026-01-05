// ===================================================================================
// SERVICE DETAILS BOOKING VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Displays the final details of a service before the user confirms the booking.
//
// KEY FEATURES:
// 1. Date & Time Selection: Users pick when they want the service.
// 2. Data Safety: Ensures user profile data exists before allowing a booking to proceed.
// 3. Data Transfer: Packages all service and user information into a BookingModel.
// 4. Dynamic Layout: Uses a TableView with automatic dimensioning for variable text lengths.
// ===================================================================================

import UIKit
import FirebaseAuth      // Required for fetching User ID
import FirebaseFirestore // Required for fetching User Data

class ServiceDetailsBookingTableViewController: UITableViewController {
    
    // MARK: - Outlets
    // Connections to the Interface Builder elements.
    // "weak" prevents memory leaks (retain cycles).
    @IBOutlet weak var datePicker: UIDatePicker?
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var serviceItemLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Data Variables
    // Variables to hold data passed from the previous Search/Service list screen.
    var receivedServiceName: String?
    var receivedServicePrice: String?
    var receivedServiceDetails: String?
    var receivedServiceItems: String?
    var serviceId: String?
    var providerData: ServiceProviderModel?
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Activity Indicator: Shows loading state when fetching missing user data.
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize UI components
        setupUI()
        setupNavigationBar()
        fillData() // Populate labels with passed data
        
        // Configure TableView resizing behavior
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // Setup Loader placement
        activityIndicator.center = view.center
        activityIndicator.color = brandColor
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        view.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        
        // Fix for iOS 15+ extra padding
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 12 }
        
        // Style Confirm Button
        if let btn = confirmButton {
            btn.layer.cornerRadius = 12
            btn.backgroundColor = brandColor
            btn.setTitle("Book Now", for: .normal)
            btn.setTitleColor(.white, for: .normal)
        }
        
        // Configure Date Picker
        if let picker = datePicker {
            picker.datePickerMode = .dateAndTime // Allows selecting both date and specific time
            picker.preferredDatePickerStyle = .compact
            picker.tintColor = brandColor
            picker.contentHorizontalAlignment = .trailing
            picker.minimumDate = Date() // Prevents booking in the past
        }
    }
    
    func setupNavigationBar() {
        self.title = "Booking"
        // The bar button triggers the safe booking check
        let bookButton = UIBarButtonItem(title: "Book", style: .done, target: self, action: #selector(attemptBooking))
        bookButton.tintColor = .white
        navigationItem.rightBarButtonItem = bookButton
    }
    
    // MARK: - Booking Logic (Critical Safety Check)
    @IBAction func bookButtonPressed(_ sender: Any) {
        attemptBooking()
    }
    
    // Validates if the user's profile data is loaded before allowing them to book.
    // This prevents bookings with "Unknown" names or missing IDs.
    @objc func attemptBooking() {
        // Scenario 1: User data is already loaded in the Singleton
        if UserManager.shared.currentUser != nil {
            showBookingConfirmation()
            return
        }
        
        // Scenario 2: User is authenticated but data is missing locally.
        // We must fetch it from Firestore now.
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "You must be logged in to book.")
            return
        }
        
        // UI Feedback: Start loading, disable button
        activityIndicator.startAnimating()
        confirmButton?.isEnabled = false
        
        print("User data missing (Guest). Fetching from Firestore for ID: \(uid)...")
        
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.confirmButton?.isEnabled = true
            
            if let data = snapshot?.data(), error == nil {
                // Construct the User object from the database response
                let fetchedUser = AppUser(
                    id: uid,
                    name: data["name"] as? String ?? (data["username"] as? String ?? "Unknown"),
                    email: data["email"] as? String ?? (Auth.auth().currentUser?.email ?? ""),
                    phone: data["phone"] as? String ?? "",
                    role: data["role"] as? String ?? "seeker",
                    profileImageName: nil,
                    isSeekerActive: true,
                    providerProfile: nil
                )
                
                // Save it to the Singleton for future use in the session
                UserManager.shared.setCurrentUser(fetchedUser)
                print("User data fetched and saved: \(fetchedUser.name)")
                
                // Proceed to confirmation
                self.showBookingConfirmation()
                
            } else {
                print("Failed to fetch user: \(error?.localizedDescription ?? "Unknown error")")
                self.showAlert(title: "Error", message: "Failed to load user profile. Please try logging in again.")
            }
        }
    }
    
    // Populate UI with data passed from previous controller
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
    
    // Adjust row height manually for specific rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 { return 90 }
        return UITableView.automaticDimension
    }
    
    // Prompt user for final confirmation
    func showBookingConfirmation() {
        let alert = UIAlertController(title: "Confirm Booking", message: "Proceed with booking?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Book", style: .default) { [weak self] _ in
            self?.showPaymentScreen()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    func showPaymentScreen() {
        let paymentVC = PaymentViewController()
        // Create the booking object to pass to the payment screen
        paymentVC.bookingData = createBookingModel()
        paymentVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    // MARK: - Data Model Creation
    // Aggregates all data (Service info + User info + Date) into one object
    func createBookingModel() -> BookingModel {
        let serviceName = receivedServiceName ?? "Unknown"
        let priceString = receivedServicePrice?.replacingOccurrences(of: "BHD ", with: "") ?? "0"
        let price = Double(priceString) ?? 0.0
        
        // Captures selected Date AND Time
        let date = datePicker?.date ?? Date()
        
        let providerName = providerData?.name ?? "Unknown"
        let providerId = providerData?.id ?? ""
        
        // Data is guaranteed to exist here due to 'attemptBooking' check
        let currentUser = UserManager.shared.currentUser
        let seekerName = currentUser?.name ?? "Guest"
        let seekerEmail = currentUser?.email ?? "no-email"
        let seekerPhone = currentUser?.phone ?? "No Phone"
        let seekerId = currentUser?.id ?? ""
        
        let realDescription = receivedServiceDetails ?? "No details provided"
        var itemsText = receivedServiceItems ?? "None"
        if itemsText.isEmpty { itemsText = "None" }
        
        return BookingModel(
            id: UUID().uuidString,
            serviceName: serviceName,
            providerName: providerName,
            seekerName: seekerName,
            date: date,
            status: .upcoming,
            totalPrice: price,
            notes: itemsText,
            email: seekerEmail,
            phoneNumber: seekerPhone,
            providerId: providerId,
            seekerId: seekerId,
            serviceId: self.serviceId ?? "",
            descriptionText: realDescription
        )
    }
    
    // TableView Cell Styling (White background with rounded corners)
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// ===================================================================================
// PAYMENT VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Handles payment method selection and final booking submission.
//
// KEY FEATURES:
// 1. Payment Methods: Supports Credit Card, Apple Pay, and Benefit Pay.
// 2. Dynamic UI: Switches input fields based on the selected payment method.
// 3. Validation: Ensures card numbers/IBANs are formatted correctly before submission.
// ===================================================================================

class PaymentViewController: UIViewController {
    
    // Styling Properties
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let lightBg = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
    
    var bookingData: BookingModel?
    var selectedPaymentMethod: PaymentMethod = .creditCard
    
    enum PaymentMethod {
        case creditCard, applePay, benefitPay
    }
    
    // MARK: - UI Components (Programmatic Layout)
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
    
    // Custom Buttons for payment selection
    private lazy var creditCardButton = createPaymentButton(title: "Credit Card", tag: 0)
    private lazy var applePayButton = createPaymentButton(title: "Apple Pay", tag: 1)
    private lazy var benefitPayButton = createPaymentButton(title: "Benefit Pay", tag: 2)
    
    // MARK: - Credit Card Input Views
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
    
    // MARK: - Benefit Pay Input Views
    private let benefitPayContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // Hidden by default
        return view
    }()
    
    private let benefitSegmentControl: UISegmentedControl = {
        let items = ["IBAN", "Phone Number"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let ibanWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ibanPrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "GB33BUKB2020155555"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ibanSuffixTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Last 8 digits"
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textAlignment = .left
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let phoneWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let benefitPhoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Phone Number"
        tf.keyboardType = .phonePad
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // StackView to manage swapping containers (Credit Card vs Benefit)
    private let formsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updatePaymentMethodSelection() // Init default selection state
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Payment"
        view.backgroundColor = lightBg
        
        purchaseButton.backgroundColor = brandColor
        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        
        creditCardButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        applePayButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        benefitPayButton.addTarget(self, action: #selector(paymentMethodTapped(_:)), for: .touchUpInside)
        
        benefitSegmentControl.addTarget(self, action: #selector(benefitSegmentChanged(_:)), for: .valueChanged)
        
        // Set delegates for validation
        cardNumberTextField.delegate = self
        validThruTextField.delegate = self
        cvcTextField.delegate = self
        pinTextField.delegate = self
        ibanSuffixTextField.delegate = self
        
        // Add Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(paymentMethodsLabel)
        contentView.addSubview(creditCardButton)
        contentView.addSubview(applePayButton)
        contentView.addSubview(benefitPayButton)
        
        contentView.addSubview(formsStackView)
        formsStackView.addArrangedSubview(cardDetailsContainer)
        formsStackView.addArrangedSubview(benefitPayContainer)
        
        contentView.addSubview(purchaseButton)
        
        // Setup Credit Card inputs
        cardDetailsContainer.addSubview(cardNumberTextField)
        cardDetailsContainer.addSubview(validThruTextField)
        cardDetailsContainer.addSubview(cvcTextField)
        cardDetailsContainer.addSubview(pinTextField)
        addTextFieldSeparators()
        
        // Setup Benefit Pay inputs
        benefitPayContainer.addSubview(benefitSegmentControl)
        benefitPayContainer.addSubview(ibanWrapperView)
        benefitPayContainer.addSubview(phoneWrapperView)
        
        ibanWrapperView.addSubview(ibanPrefixLabel)
        ibanWrapperView.addSubview(ibanSuffixTextField)
        phoneWrapperView.addSubview(benefitPhoneTextField)
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
            
            formsStackView.topAnchor.constraint(equalTo: benefitPayButton.bottomAnchor, constant: 24),
            formsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cardDetailsContainer.heightAnchor.constraint(equalToConstant: 240),
            benefitPayContainer.heightAnchor.constraint(equalToConstant: 180),
            
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
            
            benefitSegmentControl.topAnchor.constraint(equalTo: benefitPayContainer.topAnchor, constant: 20),
            benefitSegmentControl.leadingAnchor.constraint(equalTo: benefitPayContainer.leadingAnchor, constant: 20),
            benefitSegmentControl.trailingAnchor.constraint(equalTo: benefitPayContainer.trailingAnchor, constant: -20),
            
            ibanWrapperView.topAnchor.constraint(equalTo: benefitSegmentControl.bottomAnchor, constant: 20),
            ibanWrapperView.leadingAnchor.constraint(equalTo: benefitPayContainer.leadingAnchor, constant: 20),
            ibanWrapperView.trailingAnchor.constraint(equalTo: benefitPayContainer.trailingAnchor, constant: -20),
            ibanWrapperView.bottomAnchor.constraint(equalTo: benefitPayContainer.bottomAnchor, constant: -20),
            
            ibanPrefixLabel.topAnchor.constraint(equalTo: ibanWrapperView.topAnchor),
            ibanPrefixLabel.leadingAnchor.constraint(equalTo: ibanWrapperView.leadingAnchor),
            ibanPrefixLabel.trailingAnchor.constraint(equalTo: ibanWrapperView.trailingAnchor),
            
            ibanSuffixTextField.topAnchor.constraint(equalTo: ibanPrefixLabel.bottomAnchor, constant: 8),
            ibanSuffixTextField.leadingAnchor.constraint(equalTo: ibanWrapperView.leadingAnchor),
            ibanSuffixTextField.trailingAnchor.constraint(equalTo: ibanWrapperView.trailingAnchor),
            ibanSuffixTextField.heightAnchor.constraint(equalToConstant: 40),
            
            phoneWrapperView.topAnchor.constraint(equalTo: benefitSegmentControl.bottomAnchor, constant: 20),
            phoneWrapperView.leadingAnchor.constraint(equalTo: benefitPayContainer.leadingAnchor, constant: 20),
            phoneWrapperView.trailingAnchor.constraint(equalTo: benefitPayContainer.trailingAnchor, constant: -20),
            phoneWrapperView.bottomAnchor.constraint(equalTo: benefitPayContainer.bottomAnchor, constant: -20),
            
            benefitPhoneTextField.centerYAnchor.constraint(equalTo: phoneWrapperView.centerYAnchor),
            benefitPhoneTextField.leadingAnchor.constraint(equalTo: phoneWrapperView.leadingAnchor),
            benefitPhoneTextField.trailingAnchor.constraint(equalTo: phoneWrapperView.trailingAnchor),
            benefitPhoneTextField.heightAnchor.constraint(equalToConstant: 44),
            
            purchaseButton.topAnchor.constraint(equalTo: formsStackView.bottomAnchor, constant: 32),
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
    
    // Handle switching between Credit Card, Apple Pay, and Benefit Pay
    @objc private func paymentMethodTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0: selectedPaymentMethod = .creditCard
        case 1: selectedPaymentMethod = .applePay
        case 2: selectedPaymentMethod = .benefitPay
        default: break
        }
        updatePaymentMethodSelection()
    }
    
    // Handle switching between IBAN and Phone for Benefit Pay
    @objc private func benefitSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            ibanWrapperView.isHidden = false
            phoneWrapperView.isHidden = true
        } else {
            ibanWrapperView.isHidden = true
            phoneWrapperView.isHidden = false
        }
    }
    
    // Updates UI visibility and border colors based on selection
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
        }
        
        selectedButton.layer.borderColor = brandColor.cgColor
        selectedButton.layer.borderWidth = 3
        
        // Show/Hide input forms based on selection
        UIView.animate(withDuration: 0.3) {
            switch self.selectedPaymentMethod {
            case .creditCard:
                self.cardDetailsContainer.isHidden = false
                self.benefitPayContainer.isHidden = true
            case .benefitPay:
                self.cardDetailsContainer.isHidden = true
                self.benefitPayContainer.isHidden = false
            case .applePay:
                self.cardDetailsContainer.isHidden = true
                self.benefitPayContainer.isHidden = true
            }
        }
    }
    
    // MARK: - Purchase Action
    @objc private func purchaseButtonTapped() {
        view.endEditing(true)
        
        // 1. Validation Logic
        if selectedPaymentMethod == .creditCard {
            if (cardNumberTextField.text ?? "").count < 13 { showAlert(title: "Error", message: "Invalid Card Number"); return }
            if (validThruTextField.text ?? "").isEmpty { showAlert(title: "Error", message: "Invalid Date"); return }
            if (cvcTextField.text ?? "").isEmpty { showAlert(title: "Error", message: "Invalid CVC"); return }
            if (pinTextField.text ?? "").isEmpty { showAlert(title: "Error", message: "Invalid PIN"); return }
        } else if selectedPaymentMethod == .benefitPay {
            if benefitSegmentControl.selectedSegmentIndex == 0 {
                if (ibanSuffixTextField.text ?? "").count != 8 { showAlert(title: "Error", message: "Invalid IBAN"); return }
            } else {
                if (benefitPhoneTextField.text ?? "").isEmpty { showAlert(title: "Error", message: "Invalid Phone"); return }
            }
        }
        
        // 2. Save booking to Firebase via ServiceManager
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TextField Delegate
// Restricts input length and character types for security and UX
extension PaymentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if textField == cardNumberTextField { return updatedText.count <= 16 }
        else if textField == validThruTextField { return updatedText.count <= 5 }
        else if textField == cvcTextField { return updatedText.count <= 3 }
        else if textField == pinTextField { return updatedText.count <= 4 }
        else if textField == ibanSuffixTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) && updatedText.count <= 8
        }
        return true
    }
}
