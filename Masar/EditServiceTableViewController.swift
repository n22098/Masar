//
//  EditServiceTableViewController.swift
//  Masar
//
//  Created by Moe Radhi  on 19/12/2025.
//

import UIKit

class EditServiceTableViewController: UITableViewController {
    
    // MARK: - Properties
    var serviceToEdit: ServiceModel?
    var onSaveComplete: ((ServiceModel) -> Void)?
    
    // MARK: - Outlets
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var packageItemsLabel: UILabel!
    @IBOutlet weak var expiryDatePicker: UIDatePicker!
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        populateData()
        setupTextViews()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.keyboardDismissMode = .interactive
        
        // Style text fields
        styleTextField(serviceNameTextField, placeholder: "Service Name")
        styleTextField(priceTextField, placeholder: "eg. 25")
        priceTextField?.keyboardType = .decimalPad
        
        // Style text views
        styleTextView(descriptionTextView)
        styleTextView(instructionsTextView)
        
        // Date picker styling
        if let datePicker = expiryDatePicker {
            datePicker.minimumDate = Date()
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .compact
            }
        }
    }
    
    func setupNavigationBar() {
        title = serviceToEdit == nil ? "Add Service" : "Edit Service"
        
        // Purple navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = brandColor
        
        // Back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        // Save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    func setupTextViews() {
        // Add borders to text views
        if let descView = descriptionTextView {
            descView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            descView.layer.borderWidth = 1
            descView.layer.cornerRadius = 8
            descView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        }
        
        if let instView = instructionsTextView {
            instView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            instView.layer.borderWidth = 1
            instView.layer.cornerRadius = 8
            instView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        }
    }
    
    func styleTextField(_ textField: UITextField?, placeholder: String) {
        guard let tf = textField else { return }
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.backgroundColor = .white
    }
    
    func styleTextView(_ textView: UITextView?) {
        guard let tv = textView else { return }
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.backgroundColor = .white
        tv.textColor = .black
    }
    
    // MARK: - Populate Data
    func populateData() {
        guard let service = serviceToEdit else { return }
        
        serviceNameTextField?.text = service.name
        priceTextField?.text = service.price.replacingOccurrences(of: "BHD ", with: "")
        descriptionTextView?.text = service.description
        
        // Instructions - you might need to add this to ServiceModel
        instructionsTextView?.text = "Instructions for this service"
        
        // Package items
        packageItemsLabel?.text = "Service includes basic package"
    }
    
    // MARK: - Actions
    @objc func backTapped() {
        // Check if there are unsaved changes
        if hasUnsavedChanges() {
            let alert = UIAlertController(
                title: "Unsaved Changes",
                message: "You have unsaved changes. Are you sure you want to go back?",
                preferredStyle: .alert
            )
            
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
        // Validate inputs
        guard let name = serviceNameTextField?.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a service name")
            return
        }
        
        guard let priceText = priceTextField?.text, !priceText.isEmpty else {
            showAlert(title: "Error", message: "Please enter a price")
            return
        }
        
        guard let description = descriptionTextView?.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Please enter a description")
            return
        }
        
        // Create or update service
        let price = "BHD \(priceText)"
        
        if var service = serviceToEdit {
            // Update existing service
            service.name = name
            service.price = price
            service.description = description
            
            onSaveComplete?(service)
        } else {
            // Create new service
            let newService = ServiceModel(
                name: name,
                price: price,
                description: description
            )
            
            onSaveComplete?(newService)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func hasUnsavedChanges() -> Bool {
        guard let service = serviceToEdit else {
            // New service - check if any field has content
            let nameChanged = !(serviceNameTextField?.text?.isEmpty ?? true)
            let priceChanged = !(priceTextField?.text?.isEmpty ?? true)
            let descChanged = !(descriptionTextView?.text?.isEmpty ?? true)
            return nameChanged || priceChanged || descChanged
        }
        
        // Existing service - check if any field changed
        let nameChanged = serviceNameTextField?.text != service.name
        let priceChanged = "BHD \(priceTextField?.text ?? "")" != service.price
        let descChanged = descriptionTextView?.text != service.description
        
        return nameChanged || priceChanged || descChanged
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle package items tap if needed
        // You can add navigation to select package items
    }
}

// MARK: - Text Field Delegate
extension EditServiceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == serviceNameTextField {
            priceTextField?.becomeFirstResponder()
        } else if textField == priceTextField {
            descriptionTextView?.becomeFirstResponder()
        }
        return true
    }
}
