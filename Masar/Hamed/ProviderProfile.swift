// ===================================================================================
// PROVIDER PROFILE MODEL
// ===================================================================================
// PURPOSE: Stores specific data for users who act as Service Providers.
//
// KEY FEATURES:
// 1. Role Management: Distinguishes between Company Owners, Dept Heads, and Employees.
// 2. Computed Permissions: Automatically determines what a user can do based on their role.
// 3. Performance Stats: Tracks total bookings and user ratings.
// 4. Custom Encoding: Excludes computed properties from JSON/Database storage.
// ===================================================================================

import Foundation

struct ProviderProfile: Codable {
    
    // MARK: - Core Properties
    let id: String
    let role: ProviderRole
    
    // Organization Details (Optional, as freelancers might not have departments)
    let companyId: String?
    let companyName: String
    let departmentId: String?
    let departmentName: String?
    
    // Services offered by this specific provider
    var services: [ServiceModel]
    
    // MARK: - Dynamic Permissions Logic
    // Computed Property: This is NOT stored in the database.
    // It is calculated dynamically every time the 'role' is accessed.
    var permissions: [Permission] {
        switch role {
        case .companyOwner:
            // Owners have full access to everything in the company
            return [
                .manageCompany,
                .manageDepartments,
                .manageEmployees,
                .viewAllReports,
                .companySettings,
                .manageOwnServices,
                .viewIncomingBookings,
                .editServiceDetails,
                .respondToBookings,
                .viewOwnReports
            ]
            
        case .departmentHead:
            // Heads manage their specific department and their own tasks
            return [
                .manageDepartment,
                .assignTasks,
                .viewDepartmentReports,
                .manageTeamSchedule,
                .manageOwnServices,
                .viewIncomingBookings,
                .editServiceDetails,
                .respondToBookings,
                .viewOwnReports
            ]
            
        case .employee:
            // Employees only focus on their assigned services and bookings
            return [
                .manageOwnServices,
                .viewIncomingBookings,
                .editServiceDetails,
                .respondToBookings,
                .viewOwnReports
            ]
        }
    }
    
    // MARK: - Performance Statistics
    var totalBookings: Int
    var completedBookings: Int
    var rating: Double
    var joinedDate: String
    
    // MARK: - Initializer
    init(id: String = UUID().uuidString,
         role: ProviderRole,
         companyId: String? = nil,
         companyName: String,
         departmentId: String? = nil,
         departmentName: String? = nil,
         services: [ServiceModel] = [],
         totalBookings: Int = 0,
         completedBookings: Int = 0,
         rating: Double = 0.0,
         joinedDate: String = "") {
        
        self.id = id
        self.role = role
        self.companyId = companyId
        self.companyName = companyName
        self.departmentId = departmentId
        self.departmentName = departmentName
        self.services = services
        self.totalBookings = totalBookings
        self.completedBookings = completedBookings
        self.rating = rating
        self.joinedDate = joinedDate
    }
    
    // MARK: - Codable Conformance
    // We define CodingKeys to explicitly tell Swift which properties to save/load.
    // 'permissions' is excluded because it is calculated, not stored.
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case companyId
        case companyName
        case departmentId
        case departmentName
        case services
        case totalBookings
        case completedBookings
        case rating
        case joinedDate
    }
}
