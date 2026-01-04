// ===================================================================================
// PERMISSION ENUM
// ===================================================================================
// PURPOSE: Defines the specific actions that a user is allowed to perform within the app.
//
// KEY FEATURES:
// 1. Granular Access Control: Breaks down capabilities into specific actions (e.g., "Manage Company").
// 2. String Raw Value: Allows these permissions to be easily stored in the database as strings.
// 3. Codable: Enables easy conversion to/from JSON for network transmission.
// 4. UI Helper: Includes a computed property to generate user-friendly display names.
// ===================================================================================

import Foundation

enum Permission: String, Codable {
    
    // MARK: - Company Owner Level (High Level)
    // These permissions are restricted to the highest level of authority.
    case manageCompany          // Edit company profile, delete company
    case manageDepartments      // Create, edit, or delete departments
    case manageEmployees        // Hire/Fire employees, change roles
    case viewAllReports         // See analytics for the entire organization
    case companySettings        // Access billing, global configurations
    
    // MARK: - Department Head Level (Mid Level)
    // Focused on managing a specific team or sector within the company.
    case manageDepartment       // Edit department details
    case assignTasks            // Allocate work to specific employees
    case viewDepartmentReports  // See analytics for their specific department only
    case manageTeamSchedule     // Set shifts and availability for the team
    
    // MARK: - Provider Level (Operational Level)
    // Basic permissions required for day-to-day service delivery.
    // Every provider (Owner, Head, or Employee) usually gets these.
    case manageOwnServices      // Add/Edit the services they personally offer
    case viewIncomingBookings   // See new job requests
    case editServiceDetails     // Update prices, descriptions of services
    case respondToBookings      // Accept or Reject bookings
    case viewOwnReports         // See personal performance stats
    
    // MARK: - Computed Properties
    // Converts the technical enum case name into a human-readable string.
    // Useful for displaying permissions in the UI (e.g., in a Settings screen).
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
