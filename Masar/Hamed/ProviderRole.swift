import Foundation

enum ProviderRole: String, Codable {
    case companyOwner = "Company Owner"
    case departmentHead = "Department Head"
    case employee = "Employee"
    
    var displayName: String {
        return self.rawValue
    }
}
