import UIKit
import FirebaseAuth

class ProfileTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCustomHeader()
    }

    private func setupUI() {
        title = "Profile"
        tableView.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func addCustomHeader() {
        let headerView = UIView(
            frame: CGRect(x: 0, y: 0,
                          width: view.bounds.width,
                          height: 180)
        )

        headerView.backgroundColor = UIColor(
            red: 117/255,
            green: 103/255,
            blue: 226/255,
            alpha: 1
        )

        let label = UILabel()
        label.text = "Profile"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])

        tableView.tableHeaderView = headerView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 1:
            navigationController?.pushViewController(
                PrivacyPolicyViewController(),
                animated: true
            )

        case 2:
            navigationController?.pushViewController(
                AboutViewController(),
                animated: true
            )

        case 3:
            showDeleteAccountAlert()

        case 4:
            showLogoutAlert()

        default:
            break
        }
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Do you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            try? Auth.auth().signOut()
            self.goToSignIn()
        })

        present(alert, animated: true)
    }

    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "Delete account?",
            message: "Are you sure?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive))

        present(alert, animated: true)
    }

    private func goToSignIn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController")

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = scene.delegate as? SceneDelegate {
            delegate.window?.rootViewController = vc
        }
    }
}
