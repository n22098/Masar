import Foundation
import FirebaseFirestore

class ReportManagementViewModel {
    // 1. Reference to Firestore
    private let db = Firestore.firestore()
    
    // 2. The data array
    private(set) var reports: [ReportItem] = []
    
    // 3. Callback to notify the TableViewController to reload
    var onDataUpdate: (() -> Void)?
    
    init() {
        fetchReportsFromFirebase()
    }
    
    private func fetchReportsFromFirebase() {
        // Change "reports" to match your collection name in the Firebase Console
        db.collection("reports").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Map the documents to ReportItem objects
            self?.reports = documents.compactMap { queryDocumentSnapshot -> ReportItem? in
                return try? queryDocumentSnapshot.data(as: ReportItem.self)
            }
            
            // 4. Update the UI on the main thread
            DispatchQueue.main.async {
                self?.onDataUpdate?()
            }
        }
    }
    
    // No changes needed to these functions
    func numberOfReports() -> Int {
        return reports.count
    }
    
    func report(at index: Int) -> ReportItem? {
        guard index >= 0 && index < reports.count else { return nil }
        return reports[index]
    }
}
