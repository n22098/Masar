import Foundation

struct ProviderProfile: Codable {
    let id: String
    let role: ProviderRole
    let companyId: String?
    let companyName: String
    let departmentId: String?
    let departmentName: String?
    
    // Services this provider offers
    var services: [ServiceModel]
    
    // Permissions based on role (computed property - not stored)
    var permissions: [Permission] {
        switch role {
        case .companyOwner:
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
            return [
                .manageOwnServices,
                .viewIncomingBookings,
                .editServiceDetails,
                .respondToBookings,
                .viewOwnReports
            ]
        }
    }
    
    // Stats
    var totalBookings: Int
    var completedBookings: Int
    var rating: Double
    var joinedDate: String
    
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
    
    // Custom Coding Keys
    // لأن permissions محسوبة تلقائياً، ما نحتاج نحفظها
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
