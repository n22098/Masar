import UIKit

class EditServiceTableViewController: UITableViewController {
    
    // MARK: - Properties
    var serviceToEdit: ServiceModel?
    var onSaveComplete: ((ServiceModel) -> Void)?
    var selectedSubServices: [String] = []
    
    // MARK: - Outlets
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    // Removed instructionsTextView and expiryDatePicker
    @IBOutlet weak var packageItemsLabel: UILabel!
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        populateData()
        setupTextViews()
    }
        
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemsSelection" {
            if let destVC = segue.destination as? ServiceItemsSelectionTableViewController {
                destVC.previouslySelectedItems = self.selectedSubServices
                
                destVC.onSelectionComplete = { [weak self] selectedNames in
                    guard let self = self else { return }
                    
                    self.selectedSubServices = selectedNames
                    let resultString = selectedNames.joined(separator: ", ")
                    
                    if selectedNames.isEmpty {
                        self.packageItemsLabel.text = "Select add-ons (Optional)"
                        self.packageItemsLabel.textColor = .lightGray
                    } else {
                        self.packageItemsLabel.text = resultString
                        self.packageItemsLabel.textColor = .black
                    }
                }
            }
        }
    }
        
    // MARK: - Setup UI & Styling
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.keyboardDismissMode = .interactive
        
        styleTextField(serviceNameTextField, placeholder: "Service Name")
        styleTextField(priceTextField, placeholder: "eg. 25")
        priceTextField?.keyboardType = .decimalPad
    }
        
    func setupNavigationBar() {
        title = serviceToEdit == nil ? "Add Service" : "Edit Service"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }
        
    func setupTextViews() {
        let borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        if let descView = descriptionTextView {
            descView.layer.borderColor = borderColor
            descView.layer.borderWidth = 1
            descView.layer.cornerRadius = 8
            descView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
            styleTextView(descView)
        }
    }
        
    func styleTextField(_ textField: UITextField?, placeholder: String) {
        guard let tf = textField else { return }
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
    }
        
    func styleTextView(_ textView: UITextView?) {
        guard let tv = textView else { return }
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.backgroundColor = .white
        tv.textColor = .black
    }
        
    // MARK: - Populate Data
    func populateData() {
        packageItemsLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        guard let service = serviceToEdit else {
            packageItemsLabel?.text = "Select add-ons (Optional)"
            packageItemsLabel?.textColor = .lightGray
            selectedSubServices = []
            return
        }
        
        selectedSubServices = service.addOns ?? []
        serviceNameTextField?.text = service.name
        
        // Show price without BHD
        priceTextField?.text = String(format: "%.0f", service.price)
        
        descriptionTextView?.text = service.description
        
        if selectedSubServices.isEmpty {
            packageItemsLabel?.text = "Select add-ons (Optional)"
            packageItemsLabel?.textColor = .lightGray
        } else {
            packageItemsLabel?.text = selectedSubServices.joined(separator: ", ")
            packageItemsLabel?.textColor = .black
        }
    }
        
    // MARK: - Actions
    @objc func backTapped() {
        if hasUnsavedChanges() {
            let alert = UIAlertController(title: "Unsaved Changes", message: "You have unsaved changes. Are you sure you want to go back?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
        
    @objc func saveTapped() {
        guard let name = serviceNameTextField?.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a service name")
            return
        }
        
        // Ensure price is numeric
        guard let priceText = priceTextField?.text,
              !priceText.isEmpty,
              let priceValue = Double(priceText) else {
            showAlert(title: "Error", message: "Please enter a valid numeric price")
            return
        }
        
        guard let description = descriptionTextView?.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Please enter a description")
            return
        }
        
        if var service = serviceToEdit {
            // Update existing service
            service.name = name
            service.price = priceValue
            service.description = description
            service.addOns = selectedSubServices
            onSaveComplete?(service)
        } else {
            // Create new service
            let newService = ServiceModel(
                name: name,
                price: priceValue,
                description: description,
                icon: "briefcase.fill"
            )
            var mutableService = newService
            mutableService.addOns = selectedSubServices
            onSaveComplete?(mutableService)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    func hasUnsavedChanges() -> Bool {
        guard let service = serviceToEdit else {
            // New Service - check if any data entered
            let hasName = !(serviceNameTextField?.text?.isEmpty ?? true)
            let hasPrice = !(priceTextField?.text?.isEmpty ?? true)
            let hasDesc = !(descriptionTextView?.text?.isEmpty ?? true)
            return hasName || hasPrice || hasDesc
        }
        
        // Existing Service - check for changes
        let nameChanged = serviceNameTextField?.text != service.name
        let priceChanged = priceTextField?.text != String(format: "%.0f", service.price)
        let descChanged = descriptionTextView?.text != service.description
        let addOnsChanged = selectedSubServices != (service.addOns ?? [])
        
        return nameChanged || priceChanged || descChanged || addOnsChanged
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
