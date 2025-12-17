import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    let mainColor = UIColor(red: 0.35, green: 0.34, blue: 0.91, alpha: 1.0)

    private var searchText: String = ""
    private var selectedCategory: ServiceCategory = .itSolutions

    private lazy var categorySegment: UISegmentedControl = { [unowned self] in
        let items = ["IT Solutions", "Teaching", "Digital Services"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .systemGray6
        sc.selectedSegmentTintColor = .white

        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: self.mainColor]
        sc.setTitleTextAttributes(normalTextAttributes, for: .normal)
        sc.setTitleTextAttributes(selectedTextAttributes, for: .selected)

        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()

    var allProviders: [ServiceProvider] = [
        .init(name: "Sayed Husain", role: "Software Engineer", rating: "⭐️ 4.9", imageName: "it1", category: .itSolutions),
        .init(name: "Joe Dean", role: "Network Technician", rating: "⭐️ 4.5", imageName: "it2", category: .itSolutions),
        .init(name: "Amin Altajer", role: "Computer Repair", rating: "⭐️ 4.8", imageName: "it3", category: .itSolutions),
        .init(name: "Kashmala Saleem", role: "Math Teacher", rating: "⭐️ 5.0", imageName: "t1", category: .teaching),
        .init(name: "Osama Hasan", role: "UI/UX Designer", rating: "⭐️ 4.6", imageName: "d1", category: .digitalServices),
        .init(name: "Vishal Santhosh", role: "Content Creator", rating: "⭐️ 4.8", imageName: "d3", category: .digitalServices)
    ]

    private var filteredProviders: [ServiceProvider] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()

        setupCustomHeader()
        filterProviders()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func setupCustomHeader() {
        let width = tableView.frame.width
        let headerHeight: CGFloat = 190
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight))
        headerView.backgroundColor = .systemBackground

        let purpleBackground = UIView(frame: CGRect(x: 0, y: -1000, width: width, height: 1000 + 145))
        purpleBackground.backgroundColor = mainColor
        purpleBackground.layer.cornerRadius = 25
        purpleBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.addSubview(purpleBackground)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 50, width: width, height: 40))
        titleLabel.text = "Services"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        let sortButton = UIButton(type: .system)
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.tintColor = .white
        sortButton.frame = CGRect(x: width - 50, y: 55, width: 30, height: 30)
        sortButton.addTarget(self, action: #selector(showSortMenu), for: .touchUpInside)
        headerView.addSubview(sortButton)

        searchBar.removeFromSuperview()
        searchBar.frame = CGRect(x: 16, y: 95, width: width - 32, height: 50)
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 18
        searchBar.searchTextField.clipsToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        headerView.addSubview(searchBar)

        categorySegment.frame = CGRect(x: 16, y: 155, width: width - 32, height: 32)
        headerView.addSubview(categorySegment)

        tableView.tableHeaderView = headerView
    }

    @objc func showSortMenu() {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "A-Z", style: .default) { _ in
            self.filteredProviders.sort { $0.name < $1.name }
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Z-A", style: .default) { _ in
            self.filteredProviders.sort { $0.name > $1.name }
            self.tableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedCategory = .itSolutions
        case 1: selectedCategory = .teaching
        case 2: selectedCategory = .digitalServices
        default: break
        }
        filterProviders()
    }

    func filterProviders() {
        filteredProviders = allProviders.filter { provider in
            let matchesCategory = provider.category == selectedCategory
            let matchesSearch = searchText.isEmpty || provider.name.lowercased().contains(searchText.lowercased())
            return matchesCategory && matchesSearch
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredProviders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath) as! ProviderCell
        let provider = filteredProviders[indexPath.row]
        cell.configure(with: provider)

        cell.onButtonTapped = { [weak self] in
            self?.performSegue(withIdentifier: "showServiceItem", sender: provider)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showServiceItem",
              let provider = sender as? ServiceProvider else { return }

        // إذا الوجهة داخل NavigationController
        if let nav = segue.destination as? UINavigationController,
           let vc = nav.topViewController as? ServiceItemTableViewController {
            vc.providerData = provider
            return
        }

        // الوجهة مباشرة
        if let vc = segue.destination as? ServiceItemTableViewController {
            vc.providerData = provider
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterProviders()
    }
}
