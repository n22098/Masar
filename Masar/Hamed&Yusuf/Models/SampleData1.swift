// ===================================================================================
// SAMPLE DATA EXTENSION
// ===================================================================================
// PURPOSE: Provides mock data for testing the application without a live backend.
//
// KEY FEATURES:
// 1. Static Access: Accessible globally via ServiceProviderModel.sampleProviders.
// 2. Realistic Data: Includes diverse roles, prices, and descriptions to test UI layouts.
// 3. Unique IDs: Each mock provider has a distinct ID for safe referencing.
// ===================================================================================

import Foundation

// MARK: - Sample Providers Extension
// Extends the ServiceProviderModel to include a static list of test users.

extension ServiceProviderModel {
    
    // Static computed property returns a fresh array of providers every time it's accessed
    static var sampleProviders: [ServiceProviderModel] {
        return [
            
            // Provider 1: Hardware Specialist
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
                    // Prices are stored as Doubles for calculations
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
            
            // Provider 2: Network Specialist
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
            
            // Provider 3: Software Developer
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
