import UIKit

class AddCategoryViewController: UITableViewController {

    @IBOutlet weak var categoryNameTextField: UITextField!
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameTextField.becomeFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let name = categoryNameTextField.text, !name.isEmpty {
            onSave?(name)
            navigationController?.popViewController(animated: true)
        }
    }

    // THIS IS THE MISSING PART CAUSING THE ERROR
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
