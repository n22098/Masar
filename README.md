# Masar - Service Booking Platform

## 📱 Overview
Masar is an iOS service booking application that connects service seekers with service providers across various categories including IT Solutions, Teaching, Digital Services, and more. The app provides a comprehensive platform for booking, managing, and tracking service requests.

---

## 🎨 Design vs Implementation: Key Changes

---

### 1. 🔐 **Authentication Flow**

#### 📝 Login Screen

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Clean, centered layout with Masar logo
- Username and password fields  
- Single "Login" button
- "Register or Create" and "Forgot password?" links

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained the clean design aesthetic
- 🔄 **Added email validation** → Real-time format checking
- ⏳ **Added loading states** → Loading indicator during auth
- 🛡️ **Enhanced error handling** → Specific error messages

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Email validation prevents invalid API calls
- ✓ Loading states improve user feedback
- ✓ Detailed error messages help resolve issues

#### 📋 Registration Flow

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Multi-step registration for seekers
- **Required Fields:**
  - Full Name
  - Phone Number
  - Date of Birth
  - Gender
  - CPR
  - Username
  - Password
- Progress indication through multiple screens

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Implemented multi-step form as designed
- ⚡ **Real-time field validation** → Validates as user types
- 🔐 **Password strength indicator** → Visual security feedback
- 📱 **CPR field validation** → Bahraini format checking
- ☎️ **Phone number formatting** → Auto-formats with +973

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Real-time validation reduces form abandonment
- ✓ Password strength indicator improves security
- ✓ Format validation ensures data consistency

---

### 2. 🧭 **Navigation Structure**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Bottom tab navigation
- **4 Tabs:**
  - 🏠 Home
  - 🔍 Search
  - 💬 Messages
  - 👤 Account

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained 4-tab structure
- 🔴 **Notification badges** → Red dots for unread items
- 🎯 **Enhanced tab icons** → SF Symbols for consistency
- 📳 **Haptic feedback** → Tactile response on tap

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Notification badges provide at-a-glance updates
- ✓ SF Symbols ensure iOS design consistency
- ✓ Haptic feedback improves user experience

---

### 3. 🔎 **Services Discovery**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Grid layout with provider avatars
- **Categories:**
  - 💻 IT Solutions
  - 📚 Teaching
  - 🎨 Digital Services
- Search bar at top
- Filter by category

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained grid layout concept
- 📋 **Changed to list view** → Better info display
- ⭐ **Added ratings** → Star ratings on cards
- 🟢 **Availability indicators** → Real-time status dots
- 🔍 **Enhanced search** → Location, price, rating filters
- ❤️ **Favorites feature** → Save preferred providers

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ List view shows more provider information
- ✓ Ratings help users make informed decisions
- ✓ Availability indicators reduce booking failures
- ✓ Enhanced search improves discoverability
- ✓ Favorites requested by beta testers

---

### 4. 📅 **Booking Flow**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Provider details display
- Package selection
- Simple "Request" button

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- 📆 **Calendar integration** → Date/time picker
- 📍 **Location selector** → Map integration
- 📝 **Notes field** → Additional requirements
- 💰 **Price estimation** → Real-time calculation
- ✅ **Two-step confirmation** → Prevent accidents

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Calendar essential for scheduling services
- ✓ Location picker prevents miscommunication
- ✓ Notes field addresses common requests
- ✓ Price transparency builds trust
- ✓ Two-step confirmation reduces cancellations

---

### 5. 📋 **Request History**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Request list with details
- **Status Types:**
  - ⏳ Upcoming
  - ✅ Completed
  - ❌ Rejected
  - 🚫 Cancelled
- Simple card layout

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained card-based layout
- 🔄 **Pull-to-refresh** → Refresh gesture
- 🏷️ **Status filters** → Quick filter buttons
- ⚠️ **Cancel dialog** → Confirmation with reason
- 🎨 **Enhanced empty state** → Illustration + text
- 📖 **Expandable cards** → Tap to view details

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Pull-to-refresh is expected iOS behavior
- ✓ Filters help find requests quickly
- ✓ Cancel dialog prevents accidents
- ✓ Better empty state improves UX
- ✓ Expandable cards reduce navigation

---

### 6. 💬 **Messaging System**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Chat interface
- Conversation with provider
- Text input at bottom
- Simple message bubbles

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained chat bubble design
- 📷 **Image sharing** → Camera & photo library
- ⌨️ **Typing indicators** → "Provider is typing..."
- ✓ **Message status** → Delivered/Read receipts
- 🔔 **Push notifications** → Real-time alerts
- 🕐 **Smart timestamps** → Grouped by date

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Image sharing essential for discussions
- ✓ Typing indicators improve flow
- ✓ Read receipts set expectations
- ✓ Push notifications ensure timely responses
- ✓ Timestamp grouping improves readability

---

### 7. 👤 **Account Management**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Profile screen with avatar
- Personal information display
- **Menu Options:**
  - Personal Information
  - Privacy and Policy
  - About
  - Logout
  - Delete Account

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- ✅ Maintained menu structure
- 📸 **Profile picture upload** → Camera/gallery + cropping
- ✏️ **Inline editing** → Direct profile editing
- ⚠️ **Delete confirmation** → Warning dialog
- 🔑 **Change password** → Security feature
- 🔔 **Notification settings** → Toggle preferences

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Profile picture personalizes the app
- ✓ Inline editing reduces navigation
- ✓ Delete warning prevents accidents
- ✓ Password change is security best practice
- ✓ Notification settings address user control

---

### 8. 👨‍💼 **Provider-Specific Features**

<table>
<tr>
<td width="50%" valign="top">

**🎨 Figma Design**
- Provider Management screen
- List of providers
- Provider names and roles
- About button for each

</td>
<td width="50%" valign="top">

**💻 Implementation Changes**
- 📊 **Provider analytics** → Booking stats dashboard
- 💵 **Earnings summary** → Financial overview
- ✅ **Enhanced verification** → Multi-step approval
- ✏️ **Service editing** → Add/edit/remove services
- 📅 **Availability calendar** → Set working hours

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Analytics help understand performance
- ✓ Earnings summary essential for business tracking
- ✓ Enhanced verification ensures quality
- ✓ Service editing gives providers control
- ✓ Availability calendar reduces conflicts

---

### 9. ⚙️ **Technical Implementation Changes**

#### 🔧 Backend Integration

<table>
<tr>
<td width="50%" valign="top">

**🎨 Original Plan** *(Implied by Figma)*
- Simple REST API calls
- Basic authentication

</td>
<td width="50%" valign="top">

**💻 Actual Implementation**

**Firebase Services:**
- 🔐 **Authentication** → Email/password + social auth
- 💾 **Firestore Database** → Real-time sync
- 📦 **Storage** → Scalable file storage
- 📊 **Analytics** → User behavior tracking
- 🐛 **Crashlytics** → Crash reporting
- ⚡ **Performance** → Performance monitoring
- 🎛️ **Remote Config** → Dynamic feature flags

**Third-Party:**
- ☁️ **Cloudinary** → Image optimization & CDN

</td>
</tr>
</table>

**💡 Why These Changes?**
- ✓ Firebase provides enterprise-grade scalability
- ✓ Firestore enables real-time features (chat, notifications)
- ✓ Cloudinary optimizes images automatically
- ✓ Analytics crucial for product decisions
- ✓ Crashlytics essential for production stability

---

#### 🎨 UI/UX Enhancements

**🆕 Features Not in Figma Design:**

| Feature | Description | Reason |
|---------|-------------|--------|
| 🌙 **Dark Mode** | System-wide compatibility | Expected by modern iOS users |
| ♿ **Accessibility** | VoiceOver, Dynamic Type | Ensures inclusive design |
| 📱 **iPad Optimization** | Adaptive layouts | Expands user base |
| ✨ **Animations** | Smooth transitions | Improves perceived performance |
| ⏳ **Skeleton Loading** | Placeholder content | Better than spinners |

---

## 🚀 How to Use the App

---

### 👥 **For Service Seekers**

#### 1. **Getting Started**
1. Download and launch Masar
2. Tap "Register as Seeker" on the welcome screen
3. Complete the registration form:
   - Enter your full name
   - Provide phone number (+973 format)
   - Enter date of birth
   - Select gender
   - Enter CPR number
   - Create username and secure password
4. Verify your email address
5. Complete profile setup

#### 2. **Finding a Service Provider**
1. Tap the **Home** tab
2. Browse service categories or use the search bar
3. Apply filters (location, rating, price, availability)
4. Tap on a provider to view their profile
5. Review their:
   - Services offered
   - Ratings and reviews
   - Pricing packages
   - Availability

#### 3. **Booking a Service**
1. Select a provider
2. Choose the service package you need
3. Select date and time from calendar
4. Add service location (or select "At provider's location")
5. Add any special requirements in the notes field
6. Review the price estimate
7. Tap "Request Service"
8. Wait for provider confirmation

#### 4. **Managing Your Requests**
1. Tap the **Messages** tab to view request status
2. Request states:
   - **Pending**: Waiting for provider response
   - **Approved**: Service confirmed
   - **Rejected**: Provider declined (view reason)
   - **Completed**: Service finished
   - **Cancelled**: Request cancelled by you or provider
3. To cancel a request:
   - Tap the request
   - Tap "Cancel Request"
   - Select cancellation reason
   - Confirm cancellation

#### 5. **Communicating with Providers**
1. Tap the **Messages** tab
2. Select conversation with provider
3. Send text messages or images
4. View provider's online status
5. Receive notifications for new messages

#### 6. **Rating a Service**
1. After service completion, you'll receive a rating prompt
2. Rate the service (1-5 stars)
3. Write a review (optional but recommended)
4. Submit rating

---

### 👨‍💼 **For Service Providers**

#### 1. **Registration**
1. Tap "Register as Provider"
2. Complete provider registration:
   - Business/Personal information
   - Service categories
   - Pricing structure
   - Availability
   - Upload credentials (if applicable)
3. Wait for admin verification (usually 24-48 hours)
4. Receive approval notification

#### 2. **Managing Services**
1. Go to **Account** > **My Services**
2. Add new services:
   - Service name
   - Description
   - Price/package options
   - Duration
3. Edit existing services
4. Enable/disable services

#### 3. **Handling Requests**
1. Receive notification for new request
2. Review request details:
   - Seeker information
   - Service requested
   - Preferred date/time
   - Location
   - Special requirements
3. Options:
   - **Approve**: Accept the request
   - **Reject**: Decline with reason
4. Communicate with seeker via messages

#### 4. **Managing Availability**
1. Go to **Account** > **Availability**
2. Set working days
3. Set working hours per day
4. Mark specific dates as unavailable
5. System automatically blocks unavailable time slots

#### 5. **Viewing Analytics**
1. Go to **Account** > **Dashboard**
2. View metrics:
   - Total bookings
   - Completed services
   - Average rating
   - Earnings this month
   - Most requested service

---

## 🏗️ Technical Architecture

---

### 📱 Frontend Stack

| Component | Technology |
|-----------|------------|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **Minimum iOS** | iOS 15.0 |
| **Design Pattern** | MVVM (Model-View-ViewModel) |
| **Dependencies** | Swift Package Manager |

---

### ☁️ Backend Services

| Service | Provider | Purpose |
|---------|----------|---------|
| 🔐 **Authentication** | Firebase Auth | User login/signup |
| 💾 **Database** | Cloud Firestore | Real-time data storage |
| 📦 **File Storage** | Firebase + Cloudinary | Images & files |
| 🔔 **Push Notifications** | FCM | Real-time alerts |
| 📊 **Analytics** | Firebase Analytics | Usage tracking |
| 🐛 **Crash Reporting** | Firebase Crashlytics | Error monitoring |
| ⚡ **Performance** | Firebase Performance | Speed monitoring |

---

### 🔑 Key Features Implementation

#### 💬 Real-time Messaging
```swift
// Uses Firestore real-time listeners
// Message delivery with read receipts
// Typing indicators
// Image sharing with Cloudinary compression
```

#### 📅 Booking System
```swift
// Availability checking algorithm
// Double-booking prevention
// Calendar integration
// Push notification triggers
```

#### 📍 Location Services
```swift
// MapKit integration
// Location permission handling
// Distance calculation
// Address geocoding
```

---

## 📦 Project Structure

```
Masar/
├── App/
│   ├── MasarApp.swift              # App entry point
│   └── AppDelegate.swift           # App lifecycle
├── Models/
│   ├── User.swift                  # User model (Seeker/Provider)
│   ├── Service.swift               # Service model
│   ├── Request.swift               # Booking request model
│   └── Message.swift               # Chat message model
├── ViewModels/
│   ├── AuthViewModel.swift         # Authentication logic
│   ├── ServicesViewModel.swift     # Services discovery logic
│   ├── RequestsViewModel.swift     # Booking management
│   └── MessagingViewModel.swift    # Chat functionality
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   ├── RegisterSeekerView.swift
│   │   └── RegisterProviderView.swift
│   ├── Main/
│   │   ├── HomeView.swift          # Service discovery
│   │   ├── SearchView.swift
│   │   ├── MessagesView.swift
│   │   └── AccountView.swift
│   ├── Services/
│   │   ├── ServiceListView.swift
│   │   ├── ServiceDetailView.swift
│   │   └── BookingView.swift
│   └── Shared/
│       ├── CustomButton.swift
│       ├── LoadingView.swift
│       └── EmptyStateView.swift
├── Services/
│   ├── AuthService.swift           # Firebase Auth wrapper
│   ├── DatabaseService.swift       # Firestore operations
│   ├── StorageService.swift        # Image upload/download
│   └── NotificationService.swift   # Push notifications
├── Utilities/
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   └── Date+Extensions.swift
│   ├── Validators/
│   │   ├── EmailValidator.swift
│   │   ├── PhoneValidator.swift
│   │   └── CPRValidator.swift
│   └── Constants.swift             # App constants
└── Resources/
    ├── Assets.xcassets             # Images, colors
    ├── GoogleService-Info.plist    # Firebase config
    └── Info.plist
```

---

## ⚙️ Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- macOS Ventura or later
- iOS 15.0+ device or simulator
- Swift Package Manager
- Firebase account
- Cloudinary account (optional)

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

3. **Install Dependencies**
   - Dependencies are managed via Swift Package Manager
   - Xcode will automatically resolve packages on first build
   - Wait for package resolution to complete

4. **Firebase Configuration**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Drag and drop it into the Masar folder in Xcode
   - Ensure "Copy items if needed" is checked
   - Verify it's included in the Masar target

5. **Cloudinary Setup** (Optional)
   - Create Cloudinary account at cloudinary.com
   - Add credentials to `Constants.swift`:
   ```swift
   static let cloudinaryCloudName = "your-cloud-name"
   static let cloudinaryApiKey = "your-api-key"
   static let cloudinaryApiSecret = "your-api-secret"
   ```

6. **Build and Run**
   - Select target device/simulator (iPhone 14 Pro recommended)
   - Press `⌘ + R` to build and run
   - First build may take 2-3 minutes

---

## 🧪 Testing

### Test Accounts
**Seeker:**
- Email: `seeker@masar.com`
- Password: `Test1234!`

**Provider:**
- Email: `provider@masar.com`
- Password: `Test1234!`

**Admin:**
- Email: `admin@masar.com`
- Password: `Admin1234!`

### Testing Checklist
- ✅ User registration (Seeker & Provider)
- ✅ Email verification
- ✅ Login/Logout
- ✅ Password reset
- ✅ Browse services
- ✅ Search and filter services
- ✅ Book a service
- ✅ Cancel booking
- ✅ Send messages (text and images)
- ✅ View request history
- ✅ Rate a service
- ✅ Edit profile
- ✅ Upload profile picture
- ✅ Dark mode switching
- ✅ Push notifications
- ✅ Offline mode handling

---

## 🐛 Known Issues & Limitations

---

### ⚠️ Current Limitations

| # | Limitation | Status | Timeline |
|---|------------|--------|----------|
| 1 | 💳 **Payment Integration** | Not implemented | Planned v2.0 |
| 2 | 🌐 **Multi-language** | English only | Arabic coming soon |
| 3 | 📹 **Video Calls** | Not available | Future consideration |
| 4 | 🏷️ **Service Categories** | Predefined only | Expansion planned |
| 5 | 🗺️ **Advanced Search** | No radius search | v2.0 feature |
| 6 | 📴 **Offline Mode** | Limited functionality | Investigating |

---

### 🐞 Known Bugs

#### 1️⃣ iOS 15 Keyboard Issue
> **Issue:** Keyboard sometimes overlaps input fields on iOS 15.0-15.2  
> **Workaround:** Tap outside and refocus  
> **Status:** ✅ Fixed in iOS 15.3+

#### 2️⃣ Image Upload on Slow Networks
> **Issue:** Large images may timeout during upload  
> **Workaround:** Use smaller images or better connection  
> **Status:** 🔄 Cloudinary compression helps, investigating better solution

#### 3️⃣ Push Notification Badge
> **Issue:** Badge count doesn't clear immediately on app kill  
> **Status:** 🔍 Under investigation

#### 4️⃣ Dark Mode Transition
> **Issue:** Minor UI glitch during mode transition  
> **Status:** ⬇️ Low priority, cosmetic only

---

## 🔮 Planned Features (v2.0+)

---

### 🔴 High Priority

| Feature | Description | Impact |
|---------|-------------|--------|
| 💳 **Payment Integration** | Apple Pay, Cards, Benefit Pay | Critical for monetization |
| 🌐 **Arabic Language** | RTL layout support | Expand market reach |
| ✅ **Provider Verification** | Verification badges | Build trust |
| 🎯 **Advanced Filters** | Radius search, instant booking | Improve discovery |
| ⭐ **Review System v2** | Enhanced ratings | Better feedback |
| 💵 **Provider Withdrawals** | Payment processing | Provider satisfaction |

---

### 🟡 Medium Priority

| Feature | Description |
|---------|-------------|
| 📹 **Video Calls** | Remote service support |
| 📅 **Calendar Sync** | iCloud integration |
| 🔄 **Recurring Bookings** | Scheduled services |
- [ ] Provider portfolio gallery
- [ ] Service packages and bundles
- [ ] Promotional codes and discounts
- [ ] Referral program

### Low Priority
- [ ] Social media sharing
- [ ] Dark mode theme customization
- [ ] Widget support (iOS 14+)
- [ ] Apple Watch companion app
- [ ] Siri shortcuts
- [ ] Face ID/Touch ID for app lock

---

## 📊 Analytics & Monitoring

### Tracked Events
- User registration (Seeker/Provider)
- Login attempts (success/failure)
- Service searches and filters
- Booking requests (created/cancelled/completed)
- Message sends
- Profile views and edits
- Rating submissions
- App crashes
- Screen views and navigation paths
- Button clicks and user interactions

### Performance Metrics
- App launch time (cold/warm start)
- Screen load times
- Network request durations
- Image load times
- Database query performance
- API response times
- Memory usage
- Battery consumption

### Crash Reporting
- Automatic crash detection
- Stack trace collection
- Device and OS information
- User actions before crash
- Crash clustering by similarity

---

## 🔒 Privacy & Security

### Data Collection
The app collects the following data:
- **Account Information**: Name, email, phone number, CPR
- **Location Data**: Only when requesting services (with permission)
- **Usage Analytics**: App interactions, feature usage
- **Crash Reports**: Technical diagnostic data
- **Messages**: Chat conversations (encrypted in transit)
- **Photos**: Profile pictures and shared images (with permission)

### Security Measures
- ✅ Firebase Authentication with email verification
- ✅ Encrypted data transmission (HTTPS/TLS 1.3)
- ✅ Secure password storage (Firebase handles hashing)
- ✅ Regular security audits
- ✅ GDPR compliance ready
- ✅ Data minimization principles
- ✅ Secure image uploads via Cloudinary

### User Privacy Controls
- **Delete Account**: Complete account deletion with data removal
- **Data Export**: Request copy of personal data
- **Notification Settings**: Granular control over notifications
- **Location Permissions**: Request only when needed
- **Camera/Photo Access**: Permission-based access
- **Privacy Policy**: Accessible from Account screen
- **Terms of Service**: Accessible from Account screen

### Data Retention
- Active accounts: Data retained indefinitely
- Deleted accounts: Data removed within 30 days
- Chat messages: Retained for 1 year after conversation end
- Analytics data: Aggregated, anonymized after 90 days

---

## 🤝 Contributing

### Development Guidelines
1. Follow Swift API Design Guidelines
2. Use SwiftUI for all views (no UIKit unless necessary)
3. Implement MVVM pattern consistently
4. Write unit tests for ViewModels and Services
5. Document complex logic with comments
6. Use meaningful commit messages (Conventional Commits)
7. Create feature branches from `develop`
8. Submit pull requests for review

### Code Style
- Use SwiftLint for code formatting
- 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Organize imports alphabetically
- Group related code with // MARK: comments
- Use descriptive variable names
- Avoid force unwrapping (!)

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature

# Create pull request on GitHub
```

### Commit Message Format
```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Build process or auxiliary tool changes

---

## 📄 License
[Add your license information - MIT, Apache 2.0, etc.]

---

## 👥 Credits

### Design Team
- **UI/UX Design**: Figma Design Team
- **Logo & Branding**: [Designer Name]
- **Iconography**: SF Symbols + Custom Icons

### Development Team
- **iOS Lead Developer**: [Name]
- **iOS Developers**: [Names]
- **Backend Integration**: Firebase Team
- **Image Optimization**: Cloudinary

### Quality Assurance
- **QA Lead**: [Name]
- **Beta Testers**: [Names]

### Special Thanks
- Early adopters and beta testers
- User feedback contributors
- Open source community
- Apple Developer community

---

## 📞 Support & Contact

### Get Help
- **Email Support**: support@masar.app
- **Response Time**: Within 24 hours
- **Available**: 9 AM - 6 PM (Bahrain Time, Sun-Thu)

### Social Media
- **Website**: www.masar.app
- **Twitter**: @MasarApp
- **Instagram**: @masar.app
- **LinkedIn**: Masar Services
- **Facebook**: /MasarApp

### Reporting Issues
**Before submitting an issue:**
1. Check the Known Issues section above
2. Search existing issues on GitHub/Support Portal
3. Try restarting the app
4. Update to the latest version

**When creating an issue, include:**
- Clear, descriptive title
- Steps to reproduce the problem
- Expected behavior vs actual behavior
- Screenshots or screen recordings
- Device model (e.g., iPhone 14 Pro)
- iOS version (e.g., iOS 17.2)
- App version (visible in Account > About)
- Any error messages received

### Feature Requests
We welcome feature suggestions! Submit them via:
- Email: features@masar.app
- In-app: Account > Feedback
- GitHub: Feature Request template

---

## 📝 Changelog

### Version 1.0.0 (December 2025) - Initial Release
**New Features:**
- ✨ User authentication (Seeker & Provider registration)
- ✨ Service discovery and search with filters
- ✨ Real-time booking system with calendar integration
- ✨ In-app messaging with image sharing
- ✨ Request history and management
- ✨ Profile management with photo upload
- ✨ Rating and review system
- ✨ Push notifications for real-time updates
- ✨ Dark mode support
- ✨ Accessibility features (VoiceOver, Dynamic Type)

**Technical Implementation:**
- Firebase Authentication integration
- Firestore real-time database
- Firebase Storage + Cloudinary for images
- Firebase Cloud Messaging for push notifications
- Firebase Analytics for usage tracking
- Firebase Crashlytics for stability monitoring
- MVVM architecture with SwiftUI

**Changes from Figma Design:**
- Enhanced authentication with validation and error handling
- Added real-time messaging features (typing indicators, read receipts)
- Improved booking flow with calendar and location picker
- Added comprehensive analytics and crash reporting
- Implemented accessibility features
- Added dark mode support
- Enhanced empty states and loading indicators
- Added pull-to-refresh gestures
- Improved navigation with notification badges

**Known Issues:**
- See Known Issues section above

---

## 🗺️ Roadmap

### Q1 2026
- Payment gateway integration
- Arabic language support
- Provider verification system
- Advanced search filters
- Service bundles

### Q2 2026
- Video call support
- Calendar sync
- Recurring bookings
- Provider portfolio
- Promotional system

### Q3 2026
- Apple Watch app
- Widget support
- Siri shortcuts
- Social features
- Referral program

### Q4 2026
- AI-powered recommendations
- Advanced analytics dashboard
- Multi-currency support
- International expansion
- Enterprise features

---

## 📚 Documentation

### Additional Resources
- [API Documentation](#) (Coming Soon)
- [Design System](#) (Figma Link)
- [User Guide](https://www.masar.app/guide)
- [Privacy Policy](https://www.masar.app/privacy)
- [Terms of Service](https://www.masar.app/terms)
- [FAQ](https://www.masar.app/faq)

### Developer Resources
- [Swift Style Guide](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Firebase iOS Guide](https://firebase.google.com/docs/ios/setup)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

## 💡 Tips for Users

### For Best Experience
1. **Enable Notifications**: Stay updated on booking status and messages
2. **Complete Your Profile**: Providers prefer detailed seeker profiles
3. **Add Profile Picture**: Builds trust with service providers
4. **Write Detailed Requests**: Include all requirements in booking notes
5. **Rate Services**: Help other users make informed decisions
6. **Update Availability**: Providers should keep calendar current
7. **Respond Promptly**: Quick responses improve booking success rate
8. **Use Filters**: Find exactly what you need with advanced search
9. **Save Favorites**: Quick access to preferred providers
10. **Check Reviews**: Read ratings before booking

### Common Questions
**Q: How do I change my password?**
A: Account > Personal Information > Change Password

**Q: Can I book multiple services at once?**
A: Not currently, but coming in v2.0

**Q: How do I become a verified provider?**
A: Complete profile, submit credentials, wait for admin approval

**Q: What payment methods are supported?**
A: Cash on delivery (online payments coming soon)

**Q: Can I cancel after provider accepts?**
A: Yes, within 24 hours of booking time

---

**Last Updated**: December 29, 2025  
**App Version**: 1.0.0  
**Minimum iOS**: 15.0  
**Designed for**: iPhone, iPad

**© 2025 Masar. All rights reserved.**
