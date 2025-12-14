//
//  CategoryManagementViewController.swift
//  Masar
//
//  Created by BP-36-201-22 on 14/12/2025.
//

import UIKit

class CategoryManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
                // Set up the custom cell registration here
                fetchCategories()
        // Do any additional setup after loading the view.
    }
    
    func fetchCategories() {
        // 1. Initiate API call (e.g., URLSession.shared.dataTask(with: GET_URL))
        // 2. Decode the JSON response into [Category]
        
        // --- On Success ---
        // DispatchQueue.main.async {
        // self.categories = decodedCategories.sorted { $0.order < $1.order }
        // self.tableView.reloadData()
        // }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
}
