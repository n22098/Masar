import Foundation

enum Permission: String, Codable {
    // Company Owner Permissions
    case manageCompany
    case manageDepartments
    case manageEmployees
    case viewAllReports
    case companySettings
    
    // Department Head Permissions
    case manageDepartment
    case assignTasks
    case viewDepartmentReports
    case manageTeamSchedule
    
    // All Providers
    case manageOwnServices
    case viewIncomingBookings
    case editServiceDetails
    case respondToBookings
    case viewOwnReports
    
    var displayName: String {
        switch self {
        case .manageCompany: return "Manage Company"
        case .manageDepartments: return "Manage Departments"
        case .manageEmployees: return "Manage Employees"
        case .viewAllReports: return "View All Reports"
        case .companySettings: return "Company Settings"
        case .manageDepartment: return "Manage Department"
        case .assignTasks: return "Assign Tasks"
        case .viewDepartmentReports: return "View Department Reports"
        case .manageTeamSchedule: return "Manage Team Schedule"
        case .manageOwnServices: return "Manage Own Services"
        case .viewIncomingBookings: return "View Incoming Bookings"
        case .editServiceDetails: return "Edit Service Details"
        case .respondToBookings: return "Respond to Bookings"
        case .viewOwnReports: return "View Own Reports"
        }
    }
}
