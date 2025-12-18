import UIKit

class AddCategoryViewController: UITableViewController {

    // 1. Connect this to the text field in your Storyboard
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    // 2. This closure will 'callback' to your main list with the new name
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Focus the text field immediately when the screen opens
        categoryNameTextField.becomeFirstResponder()
    }

    // 3. Connect this to your '+' or 'Save' button in the Storyboard
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let name = categoryNameTextField.text, !name.isEmpty {
            // Pass the text back to the Category Management screen
            onSave?(name)
            
            // Go back to the previous screen
            navigationController?.popViewController(animated: true)
        } else {
            // Optional: Show an alert if the text field is empty
            print("Please enter a category name")
        }
    }
}
