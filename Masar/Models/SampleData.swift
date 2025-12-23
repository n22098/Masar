import Foundation

// MARK: - Sample Providers with Unique Portfolio Content

extension ServiceProviderModel {
    static var sampleProviders: [ServiceProviderModel] {
        return [
            // Provider 1: Amin Altajer
            ServiceProviderModel(
                id: "provider_001",
                name: "Amin Altajer",
                role: "Computer Repair",
                imageName: "amin_photo",
                rating: 4.8,
                skills: ["Hardware Repair", "Software Troubleshooting"],
                availability: "Daily",
                location: "Riffa",
                phone: "39999999",
                services: [
                    // 👇 التصليح: حذفنا الخانات الزائدة وحولنا السعر لرقم
                    ServiceModel(
                        name: "Computer Diagnostics",
                        price: 15.0,
                        description: "Complete hardware diagnostics"
                    ),
                    ServiceModel(
                        name: "Hardware Repair",
                        price: 35.0,
                        description: "Professional hardware repair"
                    )
                ],
                aboutMe: "Experienced computer repair specialist...",
                portfolio: [],
                certifications: [],
                reviews: [],
                experience: "8+ years",
                completedProjects: 250
            ),
            
            // Provider 2: Joe Dean
            ServiceProviderModel(
                id: "provider_002",
                name: "Joe Dean",
                role: "Network Technician",
                imageName: "joe_photo",
                rating: 4.9,
                skills: ["Network Configuration", "Cisco Routing"],
                availability: "Sat-Thu",
                location: "Online",
                phone: "36666222",
                services: [
                    ServiceModel(
                        name: "Network Setup",
                        price: 50.0,
                        description: "Complete network setup"
                    )
                ],
                aboutMe: "Certified network technician...",
                portfolio: [],
                certifications: [],
                reviews: [],
                experience: "6+ years",
                completedProjects: 180
            ),
            
            // Provider 3: Sayed Husain
            ServiceProviderModel(
                id: "provider_003",
                name: "Sayed Husain",
                role: "Software Engineer",
                imageName: "sayed_photo",
                rating: 5.0,
                skills: ["iOS Development", "Swift"],
                availability: "Mon-Fri",
                location: "Manama",
                phone: "33333333",
                services: [
                    ServiceModel(
                        name: "iOS App Development",
                        price: 500.0,
                        description: "Custom iOS application development"
                    )
                ],
                aboutMe: "Full-stack software engineer...",
                portfolio: [],
                certifications: [],
                reviews: [],
                experience: "5+ years",
                completedProjects: 45
            )
        ]
    }
}
