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
}
