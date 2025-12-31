import UIKit
import FirebaseFirestore

class SeekermanagementVC: UITableViewController {

    let brandColor = UIColor(red: 98/255, green: 84/255, blue: 243/255, alpha: 1.0)
    
    // Array to hold Firestore data
    var seekers: [Seeker] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Register Cell
        tableView.register(showSeekerDetailsCell.self, forCellReuseIdentifier: "showSeekerDetailsCell")
        
        // Fetch Data
        fetchSeekersFromFirestore()
    }
    
    // MARK: - Firebase Fetching
    func fetchSeekersFromFirestore() {
        let db = Firestore.firestore()
        
        // Get users where role is "seeker"
        db.collection("users").whereField("role", isEqualTo: "seeker")
            .addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            self.seekers = [] // Clear list
            
            for document in querySnapshot!.documents {
                let newSeeker = Seeker(document: document)
                self.seekers.append(newSeeker)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.title = "Seeker Management"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = brandColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 252/255, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seekers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "showSeekerDetailsCell", for: indexPath) as? showSeekerDetailsCell else {
            return UITableViewCell()
        }
        
        let seeker = seekers[indexPath.row]
        cell.configure(name: seeker.fullName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        performSegue(withIdentifier: "showSeekerDetailsSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SeekerDetailsTVC {
            if segue.identifier == "showSeekerDetailsSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailVC.seeker = seekers[indexPath.row]
                    detailVC.isNewSeeker = false
                }
            } else if segue.identifier == "addSeekerSegue" {
                detailVC.seeker = nil
                detailVC.isNewSeeker = true
            }
        }
    }
}
