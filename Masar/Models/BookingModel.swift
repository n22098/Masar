import Foundation

enum BookingStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case canceled = "Canceled"
}

class BookingModel {
    let id: String
    let seekerName: String
    let serviceName: String
    let date: String
    var status: BookingStatus

    let providerName: String

    let email: String
    let phoneNumber: String
    let price: String
    let instructions: String
    let descriptionText: String

    init(id: String,
         seekerName: String,
         serviceName: String,
         date: String,
         status: BookingStatus,
         providerName: String,
         email: String,
         phoneNumber: String,
         price: String,
         instructions: String,
         descriptionText: String) {

        self.id = id
        self.seekerName = seekerName
        self.serviceName = serviceName
        self.date = date
        self.status = status
        self.providerName = providerName
        self.email = email
        self.phoneNumber = phoneNumber
        self.price = price
        self.instructions = instructions
        self.descriptionText = descriptionText
    }
}
