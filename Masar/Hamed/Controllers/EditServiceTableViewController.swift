// ===================================================================================
// EDIT SERVICE VIEW CONTROLLER
// ===================================================================================
// PURPOSE: Allows providers to Create new services or Update/Delete existing ones.
//
// KEY FEATURES:
// 1. Dual Mode: Handles both "Add New" and "Edit Existing" modes based on input.
// 2. Data Persistence: Saves changes directly to Firestore via callbacks.
// 3. Validation: Ensures all required fields (Name, Price, Description) are filled.
// 4. Safe Navigation: Warns the user if they try to leave with unsaved changes.
// ===================================================================================

import UIKit
import FirebaseFirestore

class EditServiceTableViewController: UITableViewController {
    
    // MARK: - Properties
    var serviceToEdit: ServiceModel?
    
    // Callbacks to notify the parent controller of changes
    var onSaveComplete: ((ServiceModel) -> Void)?
    var onDeleteComplete: (() -> Void)?
    
    // Stores the list of selected tags/add-ons
    var selectedSubServices: [String] = []
    
    // MARK: - Outlets
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var packageItemsLabel: UILabel!
    
    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        populateData()
        setupTextViews()
        setupDeleteButton()
    }
        
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemsSelection" {
            if let destVC = segue.destination as? ServiceItemsSelectionTableViewController {
                // Pass current selection to the picker
                destVC.previouslySelectedItems = self.selectedSubServices
                
                // Handle the selection callback
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
        // Change title based on mode (Add vs Edit)
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
    
    // MARK: - Setup Delete Button
    // Only shows the delete button if we are in "Edit" mode
    func setupDeleteButton() {
        guard serviceToEdit != nil else { return }
        
        let deleteButton = UIBarButtonItem(
            title: "Delete Service",
            style: .plain,
            target: self,
            action: #selector(deleteTapped)
        )
        deleteButton.tintColor = .systemRed
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [spacer, deleteButton, spacer]
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.toolbar.tintColor = .systemRed
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
    // Fills the form if editing an existing service
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
        // Validation Logic
        guard let name = serviceNameTextField?.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a service name")
            return
        }
        
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
        
        // Save or Update Object
        if var service = serviceToEdit {
            service.name = name
            service.price = priceValue
            service.description = description
            service.addOns = selectedSubServices
            onSaveComplete?(service)
        } else {
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
    
    // MARK: - Delete Action
    @objc func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Service",
            message: "Do you want to delete this service?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteServiceFromFirebase()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Firebase Delete Logic
    func deleteServiceFromFirebase() {
        guard let service = serviceToEdit else {
            showAlert(title: "Error", message: "No service to delete")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Deleting service...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        // Strategy 1: Delete by ID (Preferred)
        if let serviceId = service.id, !serviceId.isEmpty {
            print("Deleting service with ID: \(serviceId)")
            
            db.collection("services").document(serviceId).delete { [weak self] error in
                guard let self = self else { return }
                
                loadingAlert.dismiss(animated: true) {
                    if let error = error {
                        print("Delete error: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to delete: \(error.localizedDescription)")
                    } else {
                        print("Service deleted successfully!")
                        self.onDeleteComplete?()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            // Strategy 2: Fallback search by Name if ID is missing (Legacy support)
            print("No ID found, searching by name: \(service.name)")
            
            db.collection("services")
                .whereField("title", isEqualTo: service.name)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        loadingAlert.dismiss(animated: true) {
                            print("Search error: \(error.localizedDescription)")
                            self.showAlert(title: "Error", message: "Failed to find service: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    guard let document = snapshot?.documents.first else {
                        loadingAlert.dismiss(animated: true) {
                            print("Service not found in Firebase")
                            self.showAlert(title: "Error", message: "Service not found in database")
                        }
                        return
                    }
                    
                    print("Found service, deleting document: \(document.documentID)")
                    
                    document.reference.delete { error in
                        loadingAlert.dismiss(animated: true) {
                            if let error = error {
                                print("Delete error: \(error.localizedDescription)")
                                self.showAlert(title: "Error", message: "Failed to delete: \(error.localizedDescription)")
                            } else {
                                print("Service deleted successfully!")
                                self.onDeleteComplete?()
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: - Helper Methods
    // Checks if form values differ from the original object
    func hasUnsavedChanges() -> Bool {
        guard let service = serviceToEdit else {
            let hasName = !(serviceNameTextField?.text?.isEmpty ?? true)
            let hasPrice = !(priceTextField?.text?.isEmpty ?? true)
            let hasDesc = !(descriptionTextView?.text?.isEmpty ?? true)
            return hasName || hasPrice || hasDesc
        }
        
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
