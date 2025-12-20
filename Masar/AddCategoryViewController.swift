import UIKit

class AddCategoryViewController: UITableViewController {

    // 1. Ensure this is connected to your TextField in the Storyboard
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    // 2. The closure that sends the string back
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Focus the text field immediately
        categoryNameTextField.becomeFirstResponder()
    }

    // 3. Connect this to your 'Save' Bar Button Item
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let name = categoryNameTextField.text, !name.isEmpty {
            // Send the name back to the previous controller
            onSave?(name)
            
            // Return to the list screen
            navigationController?.popViewController(animated: true)
        } else {
            // Shake the text field or show an alert if empty
            let alert = UIAlertController(title: "Empty Name", message: "Please enter a name for the category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // Optional: Connect this to a 'Cancel' Bar Button Item
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
        
    }
}
