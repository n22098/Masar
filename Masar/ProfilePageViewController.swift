//
//  ProfilePageViewController.swift
//  Masar
//
//  Created by BP-36-201-10 on 15/12/2025.
//

import UIKit

class ProfilePageViewController: UIViewController {
    var userProfile: UserProfile?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var usernameLabel: UILabel?
    @IBOutlet weak var resetPasswordButton: UIButton?
    @IBOutlet weak var PersonalInfoButton: UIButton?


    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        // Do any additional setup after loading the view.
    }
    private func configureUI() {
        title = "Profile"
        nameLabel?.text = userProfile?.name
        emailLabel?.text = userProfile?.email
        phoneLabel?.text = userProfile?.phone
        usernameLabel?.text = userProfile?.username
        
        // Wire actions if not connected in storyboard
        if let resetPasswordButton = resetPasswordButton {
            resetPasswordButton.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
        } else {
            print("⚠️ resetPasswordButton outlet is not connected.")
        }
        if let personalInfoButton = personalInfoButton {
            personalInfoButton.addTarget(self, action: #selector(didTapPersonalInfo), for: .touchUpInside)
        } else {
            print("⚠️ personalInfoButton outlet is not connected.")
        }
    }
    
    @objc private func didTapResetPassword() {
        print("✅ didTapResetPassword fired")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = "ResetPasswordViewController"
        guard let resetVC = storyboard.instantiateViewController(withIdentifier: identifier) as? ResetPasswordViewController else {
            assertionFailure("Storyboard ID '\(identifier)' not found or wrong class type. Check Identity inspector.")
            return
        }
        resetVC.prefilledEmail = userProfile?.email
        
        if let nav = navigationController {
            nav.pushViewController(resetVC, animated: true)
        } else {
            print("⚠️ No navigationController found. Presenting modally.")
            let nav = UINavigationController(rootViewController: resetVC)
            nav.modalPresentationStyle = .formSheet
            present(nav, animated: true)
        }
    }
    
    @objc private func didTapPersonalInfo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Ensure the Storyboard ID of userInfoViewController is set to "userInfoViewController"
        let identifier = "userInfoViewController"
        guard let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? userInfoViewController else {
            assertionFailure("Storyboard ID '\(identifier)' not found or wrong class type.")
            return
        }
        vc.userProfile = userProfile
        
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            print("⚠️ No navigationController found. Presenting modally.")
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            present(nav, animated: true)
        }
    }
}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
