//
//  SignInPageViewController.swift
//  Masar
//
//  Created by BP-36-201-12 on 04/12/2025.
//

import UIKit

class SignInPageViewController: UIViewController {

    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgetPassBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var userField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        
        let userName = userField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let userPass = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if userName.isEmpty {
            showAlert(message: "Please enter your username")
            return
        }
        
        if userPass.isEmpty {
            showAlert(message: "Please enter your password")
            return
        }
        
        print("Login allowed!")
        // Next controller
        // performSegue(withIdentifier: "goToHome", sender: self)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
