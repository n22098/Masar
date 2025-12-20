import UIKit

class ProviderInfoTableViewController: UITableViewController {

    // MARK: - Outlets (من Storyboard)
    @IBOutlet weak var tellUsTextView: UITextView!
    @IBOutlet weak var skillLevelTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!

    // MARK: - Picker
    private let pickerView = UIPickerView()

    private let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    private let categories = ["Plumbing", "Electricity", "Carpentry", "Painting"]

    private enum PickerType {
        case skill
        case category
    }

    private var selectedPickerType: PickerType?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextView()
        setupPickers()
        setupUploadButtonsFooter()
    }

    // MARK: - TextView UI
    private func setupTextView() {
        tellUsTextView.layer.borderWidth = 1
        tellUsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        tellUsTextView.layer.cornerRadius = 8
    }

    // MARK: - Picker Setup
    private func setupPickers() {
        pickerView.delegate = self
        pickerView.dataSource = self

        skillLevelTextField.inputView = pickerView
        categoryTextField.inputView = pickerView

        skillLevelTextField.delegate = self
        categoryTextField.delegate = self

        addToolbar(to: skillLevelTextField)
        addToolbar(to: categoryTextField)
    }

    private func addToolbar(to textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )

        toolbar.items = [done]
        textField.inputAccessoryView = toolbar
    }

    @objc private func doneTapped() {
        view.endEditing(true)
    }

    // MARK: - Upload Buttons (Created in Runtime)
    private func setupUploadButtonsFooter() {

        let footerView = UIView()
        footerView.backgroundColor = .clear

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let idCardButton = createButton(
            title: "Upload ID Card",
            action: #selector(uploadIDCard)
        )

        let certificateButton = createButton(
            title: "Upload Certificate",
            action: #selector(uploadCertificate)
        )

        let portfolioButton = createButton(
            title: "Upload Work Portfolio",
            action: #selector(uploadPortfolio)
        )

        stackView.addArrangedSubview(idCardButton)
        stackView.addArrangedSubview(certificateButton)
        stackView.addArrangedSubview(portfolioButton)

        footerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16)
        ])

        footerView.frame.size.height = 200
        tableView.tableFooterView = footerView
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Upload Actions
    @objc private func uploadIDCard() {
        showAlert("Upload ID Card tapped")
    }

    @objc private func uploadCertificate() {
        showAlert("Upload Certificate tapped")
    }

    @objc private func uploadPortfolio() {
        showAlert("Upload Work Portfolio tapped")
    }

    // MARK: - Alert
    private func showAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Provider",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ProviderInfoTableViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == skillLevelTextField {
            selectedPickerType = .skill
        } else if textField == categoryTextField {
            selectedPickerType = .category
        }
        pickerView.reloadAllComponents()
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension ProviderInfoTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedPickerType {
        case .skill:
            return skillLevels.count
        case .category:
            return categories.count
        case .none:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        switch selectedPickerType {
        case .skill:
            return skillLevels[row]
        case .category:
            return categories[row]
        case .none:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        switch selectedPickerType {
        case .skill:
            skillLevelTextField.text = skillLevels[row]
        case .category:
            categoryTextField.text = categories[row]
        case .none:
            break
        }
    }
}
