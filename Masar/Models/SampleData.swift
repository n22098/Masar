import Foundation

// MARK: - Sample Providers with Unique Portfolio Content
// Use this as a reference for creating your provider data

extension ServiceProviderModel {
    static var sampleProviders: [ServiceProviderModel] {
        return [
            // Provider 1: Amin Altajer - Computer Repair Specialist
            ServiceProviderModel(
                id: "provider_001",
                name: "Amin Altajer",
                role: "Computer Repair",
                imageName: "amin_photo",
                rating: 4.8,
                skills: ["Hardware Repair", "Software Troubleshooting", "Data Recovery", "System Optimization"],
                availability: "Daily",
                location: "Riffa",
                phone: "39999999",
                services: [
                    ServiceModel(
                        name: "Computer Diagnostics",
                        price: "BHD 15.000",
                        description: "Complete hardware and software diagnostics",
                        deliveryTime: "Same day",
                        features: ["Hardware Check", "Software Analysis", "Performance Report"]
                    ),
                    ServiceModel(
                        name: "Hardware Repair",
                        price: "BHD 35.000",
                        description: "Professional hardware repair and replacement",
                        deliveryTime: "1-2 days",
                        features: ["Component Replacement", "Cleaning", "Testing"]
                    )
                ],
                aboutMe: "Experienced computer repair specialist with over 8 years in the field. I provide fast and reliable repair services for all types of computers and laptops. Specialized in hardware upgrades, virus removal, and system optimization. My goal is to get your device back to optimal performance quickly and efficiently.",
                portfolio: [],
                certifications: [
                    Certification(
                        id: "cert_001",
                        name: "CompTIA A+ Certified",
                        issuer: "CompTIA",
                        issueDate: "2020-05-15",
                        expiryDate: "2023-05-15",
                        imageName: "comptia_cert",
                        credentialID: "COMP001234567"
                    )
                ],
                reviews: [
                    ClientReview(
                        id: "review_001",
                        clientName: "Mohammed Ali",
                        clientImageName: nil,
                        rating: 5.0,
                        comment: "Excellent service! Fixed my laptop in no time.",
                        date: "2024-12-20",
                        serviceName: "Hardware Repair"
                    )
                ],
                experience: "8+ years",
                completedProjects: 250
            ),
            
            // Provider 2: Joe Dean - Network Technician
            ServiceProviderModel(
                id: "provider_002",
                name: "Joe Dean",
                role: "Network Technician",
                imageName: "joe_photo",
                rating: 4.9,
                skills: ["Network Configuration", "Cisco Routing", "Firewall Setup", "VPN Configuration"],
                availability: "Sat-Thu",
                location: "Online",
                phone: "36666222",
                services: [
                    ServiceModel(
                        name: "Network Setup",
                        price: "BHD 50.000",
                        description: "Complete network setup and configuration",
                        deliveryTime: "2-3 days",
                        features: ["Router Setup", "WiFi Configuration", "Security Setup"]
                    ),
                    ServiceModel(
                        name: "Network Security Audit",
                        price: "BHD 75.000",
                        description: "Comprehensive network security assessment",
                        deliveryTime: "3-5 days",
                        features: ["Vulnerability Scan", "Security Report", "Recommendations"]
                    )
                ],
                aboutMe: "Certified network technician specializing in enterprise network solutions. Expert in router configuration, network security, and troubleshooting connectivity issues. I help businesses maintain secure and efficient networks. With extensive experience in Cisco technologies, I ensure your network infrastructure is robust and reliable.",
                portfolio: [],
                certifications: [
                    Certification(
                        id: "cert_002",
                        name: "Cisco CCNA",
                        issuer: "Cisco",
                        issueDate: "2021-03-10",
                        expiryDate: "2024-03-10",
                        imageName: "cisco_cert",
                        credentialID: "CSCO987654321"
                    )
                ],
                reviews: [
                    ClientReview(
                        id: "review_002",
                        clientName: "Sara Ahmed",
                        clientImageName: nil,
                        rating: 5.0,
                        comment: "Very professional! Set up our entire office network.",
                        date: "2024-12-18",
                        serviceName: "Network Setup"
                    )
                ],
                experience: "6+ years",
                completedProjects: 180
            ),
            
            // Provider 3: Sayed Husain - Software Engineer
            ServiceProviderModel(
                id: "provider_003",
                name: "Sayed Husain",
                role: "Software Engineer",
                imageName: "sayed_photo",
                rating: 5.0,
                skills: ["iOS Development", "Swift", "SwiftUI", "Firebase", "REST APIs"],
                availability: "Mon-Fri",
                location: "Manama",
                phone: "33333333",
                services: [
                    ServiceModel(
                        name: "iOS App Development",
                        price: "BHD 500.000",
                        description: "Custom iOS application development",
                        deliveryTime: "4-6 weeks",
                        features: ["Custom Design", "Backend Integration", "App Store Publishing"]
                    ),
                    ServiceModel(
                        name: "App Consultation",
                        price: "BHD 50.000",
                        description: "Expert consultation for your app idea",
                        deliveryTime: "1-2 days",
                        features: ["Technical Planning", "Cost Estimation", "Timeline Planning"]
                    )
                ],
                aboutMe: "Full-stack software engineer with 5+ years of experience in iOS development. I create beautiful, user-friendly mobile applications using Swift and SwiftUI. Passionate about clean code and elegant solutions. My apps focus on exceptional user experience and performance. Let's bring your app idea to life!",
                portfolio: [],
                certifications: [
                    Certification(
                        id: "cert_003",
                        name: "iOS App Development",
                        issuer: "Apple Developer Academy",
                        issueDate: "2019-08-20",
                        expiryDate: nil,
                        imageName: "apple_cert",
                        credentialID: "APPL456789123"
                    )
                ],
                reviews: [
                    ClientReview(
                        id: "review_003",
                        clientName: "Ahmed Hassan",
                        clientImageName: nil,
                        rating: 5.0,
                        comment: "Built an amazing app for my business. Highly recommended!",
                        date: "2024-12-15",
                        serviceName: "iOS App Development"
                    )
                ],
                experience: "5+ years",
                completedProjects: 45
            )
        ]
    }
}

// MARK: - Usage Example
// In your view controller or data manager:
/*
class DataManager {
    static let shared = DataManager()
    
    func getAllProviders() -> [ServiceProviderModel] {
        return ServiceProviderModel.sampleProviders
    }
    
    func getProvider(byId id: String) -> ServiceProviderModel? {
        return ServiceProviderModel.sampleProviders.first { $0.id == id }
    }
    
    func getProvider(byName name: String) -> ServiceProviderModel? {
        return ServiceProviderModel.sampleProviders.first { $0.name == name }
    }
}
*/
