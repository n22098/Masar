# Masar - Service Booking Platform

iOS application that connects service seekers with service providers across various categories including IT Solutions, Teaching, Digital Services, and more.

**Development Environment**: Xcode 16.4 | iOS 18.5 | Tested on iPhone 16 Pro Simulator

---

## GitHub Repository

[Project Repository Link - https://github.com/n22098/Masar]

---

## Group Members

| Name | Student ID | Role |
|------|------------|------|
| Ali Alhawaj | 202201219 | Developer |
| Hamed Ahmed | 202201226 | Tester |
| Yusuf Mahdi | 202201323 | Developer |
| Murtadha Sarhan | 202203868 | Tester  |
| Naser Rabaiaan | 202201259 | Tester  |
| Mohamed Abdali | 202304651 | Developer |

---

## Main Features

### Developer Features
- **User Authentication System**
  - Multi-step registration for seekers and providers
  - Email/password login with validation
  - Password reset functionality
  - Email verification

- **Service Discovery**
  - Browse service providers by category
  - Advanced search and filtering (location, price, rating)
  - Service provider ratings and reviews
  - Real-time availability indicators
  - Favorites functionality

- **Booking System**
  - Calendar integration for scheduling
  - Location selection with map integration
  - Package selection with price estimation
  - Two-step booking confirmation
  - Request management (approve, reject, cancel)

- **Messaging System**
  - Real-time chat between seekers and providers
  - Image sharing (camera and photo library)
  - Typing indicators
  - Message status (delivered/read receipts)
  - Push notifications for new messages

- **Account Management**
  - Profile editing with image upload and cropping
  - Personal information management
  - Password change functionality
  - Notification settings
  - Account deletion with confirmation

- **Provider-Specific Features**
  - Service management (add, edit, remove services)
  - Availability calendar with working hours
  - Booking analytics dashboard
  - Earnings summary
  - Multi-step verification process

### Tester Features
- Request history with status tracking
- Pull-to-refresh functionality
- Status filters for requests
- Expandable request details
- Empty state handling
- Error message validation
- Loading state indicators

---

## Extra Features

- **Dark Mode Support** - System-wide dark mode compatibility
- **Accessibility Features** - VoiceOver support and Dynamic Type
- **iPad Optimization** - Adaptive layouts for larger screens
- **Haptic Feedback** - Tactile responses for user interactions
- **Skeleton Loading** - Placeholder content while data loads
- **Notification Badges** - Visual indicators for unread items

---

## Design Changes

### From Figma to Implementation

**1. Authentication Flow**
- Added real-time email and field validation
- Added password strength indicator
- Added CPR format checking for Bahraini numbers
- Added phone number auto-formatting (+973)
- Enhanced error handling with specific messages

**2. Navigation Structure**
- Added notification badges for unread items
- Enhanced tab icons using SF Symbols
- Added haptic feedback on tab switches

**3. Services Discovery**
- Changed from grid to list view for better information display
- Added star ratings visible on cards
- Added real-time availability indicators
- Enhanced search with location, price, and rating filters
- Added favorites feature

**4. Booking Flow**
- Added calendar integration for date/time selection
- Added map integration for location selection
- Added notes field for special requirements
- Added real-time price calculation
- Changed to two-step confirmation process

**5. Request History**
- Added pull-to-refresh gesture
- Added status filter buttons
- Added cancel request dialog with reason selection
- Enhanced empty state with illustrations
- Added expandable cards for details

**6. Messaging System**
- Added image sharing capability
- Added typing indicators
- Added message delivery and read receipts
- Added push notifications
- Changed timestamps to grouped by date

**7. Account Management**
- Added profile picture upload with cropping
- Changed to inline editing instead of separate screens
- Added delete account warning dialog
- Added change password feature
- Added notification settings toggle

**8. Provider Features**
- Added analytics dashboard
- Added earnings summary
- Enhanced verification to multi-step process
- Added service editing capabilities
- Added availability calendar

**9. Technical Enhancements**
- Implemented Firebase backend (Authentication, Firestore, Storage)
- Added Cloudinary for image optimization
- Implemented Firebase Analytics and Crashlytics
- Added Firebase Performance monitoring
- Added dark mode support
- Implemented accessibility features
- Optimized for iPad

---

## Libraries and Packages

### Firebase SDK
- **FirebaseAuth** - User authentication
- **FirebaseFirestore** - Real-time database
- **FirebaseStorage** - File and image storage
- **FirebaseAnalytics** - User behavior tracking
- **FirebaseCrashlytics** - Crash reporting
- **FirebasePerformance** - Performance monitoring
- **FirebaseRemoteConfig** - Dynamic configuration
- **FirebaseMessaging** - Push notifications

### Third-Party Libraries
- **Cloudinary** - Image optimization and CDN delivery

### Native Frameworks
- UIKit - User interface components
- MapKit - Location services and maps
- PhotosUI - Photo library access
- AVFoundation - Camera functionality

### Dependency Management
- Swift Package Manager

---

## Project Setup

### Prerequisites
- Xcode 16.4 or later
- macOS Ventura or later
- iOS 18.5 SDK
- iPhone 16 Pro simulator
- Active internet connection
- Firebase account

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd Masar
   ```

2. **Open Project**
   ```bash
   open Masar.xcodeproj
   ```

3. **Configure Firebase**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add the file to the project root directory
   - Ensure it's included in the Masar target

4. **Install Dependencies**
   - Dependencies will automatically resolve via Swift Package Manager
   - Wait for package resolution to complete in Xcode

5. **Configure Cloudinary (Optional)**
   - Open `Constants.swift`
   - Add your Cloudinary credentials:
     ```swift
     static let cloudinaryCloudName = "your-cloud-name"
     static let cloudinaryApiKey = "your-api-key"
     ```

6. **Build and Run**
   - Select iPhone 16 Pro simulator from the device menu
   - Press Command + R to build and run
   - Wait for the app to launch on simulator

### Troubleshooting
- If packages fail to resolve, go to File > Packages > Reset Package Caches
- Ensure GoogleService-Info.plist is properly added to the project
- Verify simulator is set to iPhone 16 Pro with iOS 18.5
- Ensure Xcode 16.4 is installed and up to date

---

## Testing Environment

### Development Tools
- **Xcode Version**: 16.4
- **iOS Version**: 18.5
- **Swift Version**: 5.9+

### Simulators Used for Testing
- **Primary Simulator**: iPhone 16 Pro (iOS 18.5)
- **Additional Testing**: iPad Pro (6th generation) for iPad optimization

### Testing Configuration
- All testing performed on iPhone 16 Pro simulator
- iOS deployment target: 18.5
- Tested features include authentication, booking, messaging, and all user workflows

---

## Admin Login Credentials

### Admin Account
- **Email**: admin@masar.com
- **Password**: Admin1234!

### Test Accounts

**Service Seeker:**
- **Email**: seeker@masar.com
- **Password**: Test1234!

**Service Provider:**
- **Email**: provider@masar.com
- **Password**: Test1234!

---

## Project Architecture

### Design Pattern
- **MVVM** (Model-View-ViewModel)
- Storyboard-based UI with programmatic components

### Project Structure
```
Masar/
├── Models/              # Data models
├── Views/               # Storyboards and custom views
├── ViewModels/          # Business logic layer
├── Services/            # Firebase and API services
├── Utilities/           # Helper functions and extensions
└── Resources/           # Assets and configuration files
```

### Key Technologies
- **UI Framework**: UIKit with Storyboard
- **Architecture**: MVVM
- **Backend**: Firebase
- **Image Handling**: Firebase Storage + Cloudinary
- **Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

---

## Features Overview

### For Service Seekers
1. Register and create seeker account
2. Browse and search service providers
3. Filter by category, location, price, and rating
4. View provider profiles with ratings and reviews
5. Book services with calendar and location selection
6. Track booking requests and status
7. Communicate with providers via in-app chat
8. Rate and review completed services
9. Save favorite providers

### For Service Providers
1. Register as service provider
2. Complete verification process
3. Add and manage service offerings
4. Set availability calendar
5. Receive and respond to booking requests
6. View analytics and earnings
7. Communicate with seekers
8. Mark services as completed

---



## Future Enhancements

- Payment integration (Apple Pay, Credit Cards)
- Arabic language support with RTL layout
- Video call support for remote services
- Service provider verification badges
- Advanced geographic radius search
- Calendar synchronization with iCloud
- Recurring booking functionality

---


**Last Updated**: December 2025  
**Version**: 1.0.0  
**Developed with**: Xcode 16.4, iOS 18.5  
**Tested on**: iPhone 16 Pro Simulator  
**Minimum iOS**: 18.5
