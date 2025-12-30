# Masar - Service Booking Platform

iOS application that connects service seekers with service providers across various categories including IT Solutions, Teaching, Digital Services, and more.

**Development Environment**: Xcode 16.4 | iOS 18.5 | Tested on iPhone 16 Pro Simulator

---

## GitHub Repository

[Project Repository Link - https://github.com/n22098/Masar]

---

## Group Members

| Name | Student ID |
|------|------------|
| Ali Alhawaj | 202201219 |
| Hamed Ahmed | 202201226 |
| Yusuf Mahdi | 202201323 |
| Murtadha Sarhan | 202203868 |
| Naser Rabaiaan | 202201259 |
| Mohamed Abdali | 202304651 |

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

- **Admin Features**
  - Comprehensive user management system
  - Seeker management with detailed profile views
  - Provider management with verification controls
  - Service category management
  - Booking oversight with status monitoring
  - Account suspension and deletion capabilities


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
- **What Changed**: Added real-time email validation and instant field feedback
- **Why**: Prevents user errors before form submission and improves user experience by catching invalid emails immediately rather than after submission
- **What Changed**: Added password strength indicator with visual feedback
- **Why**: Helps users create secure passwords and reduces failed registrations due to weak password requirements
- **What Changed**: Added CPR format checking specifically for Bahraini national IDs
- **Why**: Ensures data integrity and validates that CPR numbers follow the correct format (9 digits starting with year indicators)
- **What Changed**: Added automatic phone number formatting with +973 prefix
- **Why**: Standardizes phone number format for Bahrain, prevents input errors, and ensures all numbers are stored in a consistent format
- **What Changed**: Enhanced error handling with specific, actionable messages
- **Why**: Users can understand exactly what went wrong and how to fix it, reducing frustration and support requests

**2. Navigation Structure**
- **What Changed**: Added notification badges for unread messages and requests
- **Why**: Provides immediate visual feedback about pending items without requiring users to navigate to each section
- **What Changed**: Enhanced tab icons using SF Symbols instead of custom images
- **Why**: SF Symbols are native iOS icons that automatically adapt to device settings, support dynamic type, and provide better accessibility
- **What Changed**: Added haptic feedback on tab switches
- **Why**: Provides tactile confirmation of navigation actions, improving the sense of responsiveness and making the app feel more polished

**3. Services Discovery**
- **What Changed**: Changed from grid view to list view for service provider cards
- **Why**: List view allows more information to be displayed per provider (rating, location, availability, price) without overwhelming users, and is better for scanning through multiple options
- **What Changed**: Added star ratings visible directly on provider cards
- **Why**: Allows users to quickly assess provider quality without opening detailed profiles, speeding up the decision-making process
- **What Changed**: Added real-time availability indicators (green/red status)
- **Why**: Helps users immediately identify available providers, reducing time spent checking unavailable ones
- **What Changed**: Enhanced search with multiple filters (location, price range, rating)
- **Why**: Enables users to find exactly what they need faster by narrowing results based on their specific requirements
- **What Changed**: Added favorites/bookmark feature
- **Why**: Allows users to save preferred providers for quick access later, improving user retention and repeat bookings

**4. Booking Flow**
- **What Changed**: Added calendar integration with date and time picker
- **Why**: Provides intuitive scheduling interface that users are familiar with from other iOS apps, reducing booking errors
- **What Changed**: Added map integration for location selection
- **Why**: Visual location selection is more intuitive than text-based address entry and helps users confirm the service location accurately
- **What Changed**: Added notes field for special requirements
- **Why**: Allows users to communicate specific needs or instructions to providers, reducing misunderstandings
- **What Changed**: Added real-time price calculation as options are selected
- **Why**: Provides transparency about costs before booking is confirmed, preventing price-related cancellations
- **What Changed**: Changed to two-step confirmation process with review screen
- **Why**: Reduces accidental bookings and gives users a chance to verify all details before final submission

**5. Request History**
- **What Changed**: Added pull-to-refresh gesture for updating request list
- **Why**: Provides familiar iOS pattern for refreshing content and ensures users always see the latest request status
- **What Changed**: Added status filter buttons (All, Pending, Approved, Rejected, Completed)
- **Why**: Allows users to quickly find specific types of requests without scrolling through all entries
- **What Changed**: Added cancel request dialog with reason selection
- **Why**: Captures cancellation reasons for analytics and helps providers understand why bookings are cancelled
- **What Changed**: Enhanced empty state with custom illustrations and helpful text
- **Why**: Guides new users on what to do next and makes empty screens less jarring
- **What Changed**: Added expandable cards for request details
- **Why**: Keeps the list clean while allowing access to full details when needed, improving readability

**6. Messaging System**
- **What Changed**: Added image sharing capability from camera and photo library
- **Why**: Enables users to share photos of issues, locations, or examples, making communication more effective
- **What Changed**: Added typing indicators showing when other person is composing
- **Why**: Provides real-time feedback during conversations, making chat feel more interactive and live
- **What Changed**: Added message delivery and read receipts
- **Why**: Gives senders confirmation that messages were delivered and read, reducing uncertainty in communication
- **What Changed**: Added push notifications for new messages
- **Why**: Ensures users don't miss important messages even when app is closed, improving response times
- **What Changed**: Changed timestamps to grouped by date (Today, Yesterday, specific dates)
- **Why**: Makes conversation timeline easier to follow and reduces visual clutter from repeated date information

**7. Account Management**
- **What Changed**: Added profile picture upload with image cropping functionality
- **Why**: Allows users to control how they appear in the app and ensures profile pictures are properly formatted
- **What Changed**: Changed to inline editing instead of separate edit screens
- **Why**: Reduces navigation complexity and allows users to edit specific fields without going through multiple screens
- **What Changed**: Added delete account warning dialog with confirmation
- **Why**: Prevents accidental account deletion and ensures users understand this action is permanent
- **What Changed**: Added change password feature with current password verification
- **Why**: Enhances security by requiring current password before changing to a new one
- **What Changed**: Added notification settings toggle for controlling push notifications
- **Why**: Gives users control over how and when they receive notifications, improving user experience

**8. Provider Features**
- **What Changed**: Added analytics dashboard showing booking trends and statistics
- **Why**: Helps providers track their business performance and identify peak booking times
- **What Changed**: Added earnings summary with total and completed bookings
- **Why**: Provides financial overview so providers can track their income through the platform
- **What Changed**: Enhanced verification to multi-step process with document uploads
- **Why**: Ensures providers are properly verified before offering services, increasing platform trust
- **What Changed**: Added service editing capabilities to modify existing services
- **Why**: Allows providers to update pricing, descriptions, or packages without recreating services
- **What Changed**: Added availability calendar for setting working hours and days off
- **Why**: Enables providers to manage their schedule and prevent bookings during unavailable times

**9. Admin Features**
- **What Changed**: Added comprehensive user management system
- **Why**: Allows admin to oversee all platform users, manage accounts, and handle user-related issues centrally
- **What Changed**: Added seeker management with detailed profile views
- **Why**: Enables admin to monitor seeker activity, handle support requests, and suspend problematic accounts
- **What Changed**: Added provider management with verification controls
- **Why**: Allows admin to approve/reject provider applications and maintain service quality on the platform
- **What Changed**: Added service category management
- **Why**: Enables admin to add, edit, or remove service categories as the platform grows
- **What Changed**: Added booking oversight with status monitoring
- **Why**: Allows admin to resolve disputes and monitor platform activity for quality control
- **What Changed**: Added account suspension and deletion capabilities
- **Why**: Provides moderation tools to handle policy violations and maintain platform integrity

**10. Technical Enhancements**
- **What Changed**: Implemented Firebase backend for all data operations
- **Why**: Provides real-time database, secure authentication, and scalable infrastructure without managing servers
- **What Changed**: Added Cloudinary for image optimization and delivery
- **Why**: Reduces app storage requirements and ensures fast image loading through CDN
- **What Changed**: Implemented Firebase Analytics and Crashlytics
- **Why**: Enables tracking of user behavior and automatic crash reporting for better app maintenance
- **What Changed**: Added Firebase Performance monitoring
- **Why**: Helps identify and fix performance bottlenecks to ensure smooth app experience
- **What Changed**: Added dark mode support across entire app
- **Why**: Reduces eye strain in low-light conditions and matches user system preferences
- **What Changed**: Implemented comprehensive accessibility features
- **Why**: Makes the app usable for users with disabilities, expanding potential user base
- **What Changed**: Optimized layouts for iPad with adaptive components
- **Why**: Provides better experience on larger screens and expands device compatibility

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

### For Admin Users
1. Access comprehensive admin dashboard
2. Manage user accounts (seekers and providers)
3. View detailed user profiles and activity
4. Suspend or delete user accounts
5. Review and approve provider verification requests
6. Monitor all bookings and transactions
7. Manage service categories
8. Handle dispute resolution
9. View platform analytics and statistics
10. Control service provider status and permissions
11. Review and moderate provider services
12. Access detailed booking history across all users
13. Manage platform-wide settings and configurations

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
