import Foundation

enum BookingStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled"
}

struct BookingModel {
    let serviceName: String
    let providerName: String
    let date: String
    let price: String
    let status: BookingStatus
}
