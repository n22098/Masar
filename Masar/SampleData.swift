//
//  SampleData.swift
//  Masar
//
//  Created by BP-36-201-10 on 21/12/2025.
//

import Foundation

class SampleData {
    // This static property allows you to access the data without creating a new instance
    static var seekers: [Seeker] = [
        Seeker(fullName: "John Doe", email: "john@test.com", phone: "123456", username: "jdoe", status: "Active", imageName: "profile1" , roleType: "Seeker"),
        Seeker(fullName: "Jane Smith", email: "jane@test.com", phone: "987654", username: "jsmith", status: "Suspend", imageName: "profile2" , roleType: "Seeker"),
        Seeker(fullName: "Ali Hassan", email: "ali@test.com", phone: "555111", username: "ahassan", status: "Ban", imageName: "profile3" , roleType: "Seeker")
    ]
    
    static var providers: [Provider] = [
        Provider(fullName: "Sarah Williams", email: "sarah@provider.com", phone: "111222", username: "swilliams", status: "Active", imageName: "provider1", roleType: "Provider"),
        Provider(fullName: "David Miller", email: "david@provider.com", phone: "333444", username: "dmiller", status: "Suspend", imageName: "provider2", roleType: "Provider"),
        Provider(fullName: "Omar Khaled", email: "omar@provider.com", phone: "555666", username: "okhaled", status: "Active", imageName: "provider3", roleType: "Provider"),
        Provider(fullName: "Linda Brown", email: "linda@provider.com", phone: "777888", username: "lbrown", status: "Ban", imageName: "provider4", roleType: "Provider")
    ]
   // static func getTestProviders() -> [ServiceProviderModel] {
//            return [
//                ServiceProviderModel(
//                    id: "1", name: "Amin Altajer", role: "Computer Repair",
//                    imageName: "it1", rating: 4.8, skills: ["Hardware"],
//                    availability: "9am-5pm", location: "Isa Town", phone: "123"
//                ),
//                ServiceProviderModel(
//                    id: "4", name: "Kashmala Saleem", role: "Math Teacher",
//                    imageName: "t1", rating: 5.0, skills: ["Math"],
//                    availability: "4pm-8pm", location: "Manama", phone: "456"
//                ),
//                ServiceProviderModel(
//                    id: "6", name: "Osama Hasan", role: "UI/UX Designer",
//                    imageName: "d1", rating: 4.6, skills: ["Design"],
//                    availability: "Flexible", location: "Riffa", phone: "789"
//                )
//            ]
//        }

}
