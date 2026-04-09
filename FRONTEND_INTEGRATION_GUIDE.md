# Frontend-Backend Integration Guide

## Overview

This document describes the complete integration between the Flutter mobile application and the Node.js/Express backend for the Online Exam Proctoring System.

## Project Structure

```
exam_proctoring_app/
├── lib/
│   ├── main.dart                          # App entry point with MultiProvider setup
│   ├── models/
│   │   └── api_models.dart               # API models and DTOs
│   ├── services/
│   │   └── api_client.dart               # HTTP client with Dio
│   ├── providers/
│   │   ├── auth_provider.dart            # Authentication state management
│   │   └── exam_provider.dart            # Exam & session state management
│   ├── screens/
│   │   ├── login_screen.dart             # Student login
│   │   ├── home_screen.dart              # Available exams list
│   │   ├── exam_session_screen.dart      # Exam proctoring interface
│   │   └── environment_check_screen.dart # System validation
│   └── widgets/
│       └── check_illustration.dart       # Reusable widgets
├── pubspec.yaml                          # Dependencies configuration
└── test/
    └── widget_test.dart                  # Basic app test
```

## Key Components

### 1. API Client (`lib/services/api_client.dart`)

Complete HTTP client using Dio with:
- **Base Configuration**: Configurable API base URL, timeout (30s)
- **Request/Response Interceptors**: Automatic token injection and refresh
- **Error Handling**: Comprehensive error handling for all HTTP status codes
- **Auto-Retry**: Automatic token refresh and retry on 401 (Unauthorized)
- **Methods**: 20+ endpoints covering all backend operations

**Key Methods**:
```dart
// Authentication
- register(email, password, fullName)
- login(studentId, password)
- verifyFace(imageFilePath)
- refreshToken()
- logout()

// Exam Management
- getAvailableExams()
- getExamDetails(examId)
- startExam(request)
- submitProctoringEvent(request)
- getSessionEvents(sessionId)
- endExam(sessionId)

// Faculty Dashboard
- facultyLogin(email, password)
- getDashboardStats()
- getFlaggedSessions()
- getSessionForReview(sessionId)
- submitReview(request)
```

### 2. API Models (`lib/models/api_models.dart`)

Type-safe data models:
- **Authentication**: `LoginRequest`, `LoginResponse`, `RegisterRequest`, `FaceVerificationRequest`
- **Exams**: `Exam`, `ExamSession`, `ExamStartRequest`
- **Proctoring**: `ProctoringEvent`, `ProctoringEventRequest`, `RiskAssessment`
- **Device Info**: `DeviceInfo`, `NetworkInfo`
- **Generic Wrapper**: `ApiResponse<T>` for all responses

### 3. Authentication Provider (`lib/providers/auth_provider.dart`)

State management for authentication with:
- **Initialization**: Auto-loads stored tokens from SharedPreferences
- **Login/Register**: Handles student authentication flow
- **Face Verification**: ID verification with image upload
- **Token Persistence**: Automatic token storage and retrieval
- **Logout**: Clears all authentication data

**State Properties**:
```dart
isAuthenticated   // Whether user is logged in
userId           // Unique user ID
studentId        // Student ID
fullName         // User's full name
email            // User's email
isVerified       // Face verification status
isLoading        // Loading state for async operations
error            // Error messages
```

### 4. Exam Provider (`lib/providers/exam_provider.dart`)

State management for exam sessions with:
- **Exam Listing**: Fetch available exams
- **Session Management**: Start, monitor, and end exam sessions
- **Event Submission**: Submit proctoring events with risk assessment
- **Risk Scoring**: Track and display risk scores

**Methods**:
```dart
fetchAvailableExams()        // Get list of available exams
getExamDetails(examId)       // Get specific exam info
startExam(examId, deviceInfo, networkInfo)  // Start new session
submitEvent(eventType, severity, description)  // Submit proctoring event
getSessionEvents(sessionId)  // Retrieve all events + risk score
endExam(sessionId)          // Complete and submit session
```

### 5. Screen Architecture

#### Login Screen (`home_screen.dart`)
- Student/Faculty authentication
- Error handling with SnackBar feedback
- Navigation to home screen on successful login

#### Home Screen (`home_screen.dart`)
- Displays available exams list
- Shows student info (name, ID, verification status)
- Navigation to environment check before exam
- Logout functionality

#### Environment Check Screen (`environment_check_screen.dart`)
- Validates system requirements:
  - Camera permission
  - Microphone permission
  - Internet connectivity (WiFi recommended)
  - Device specifications (Android 5.0+)
- Shows warnings for connectivity issues
- Allows proceeding even with warnings

#### Exam Session Screen (`exam_session_screen.dart`)
- Real-time countdown timer
- Camera preview with continuous monitoring
- Risk score display (color-coded)
- Proctoring event submission every 10 frames
- Warning alerts for high-risk activity
- Exam instructions and guidelines
- Recent event log display
- End exam button with confirmation

## Authentication Flow

```
1. User enters credentials on LoginScreen
2. LoginScreen calls AuthProvider.login(studentId, password)
3. AuthProvider calls ApiClient.login()
4. ApiClient sends POST /auth/login to backend
5. Backend validates and returns access + refresh tokens
6. AuthProvider stores tokens in SharedPreferences
7. AuthProvider sets isAuthenticated = true
8. App navigates to HomeScreen (via main.dart Consumer)
```

## Token Management

```
1. All API requests include Authorization header with access token
2. If API returns 401 (Unauthorized):
   - Interceptor calls ApiClient.refreshToken()
   - ApiClient sends refresh token to backend
   - Backend validates and returns new access token
   - Request is retried with new token
3. On logout:
   - AuthProvider.logout() clears stored tokens
   - SharedPreferences tokens deleted
   - isAuthenticated = false
   - App navigates back to LoginScreen
```

## Exam Session Flow

```
1. User selects exam from home screen
2. Environment check validates system
3. HomeScreen navigates to ExamSessionScreen
4. ExamSessionScreen.initState calls startExam()
5. ExamProvider.startExam() creates session on backend
6. Camera initializes and starts monitoring
7. Timer starts counting down
8. Every 10 frames (~3-4 seconds):
   - Frame submitted as ProctoringEvent
   - Backend calculates risk score
   - Risk assessment updated
9. User can view current risk score and event log
10. Timer reaches 0 or user clicks "End Exam":
    - ExamSessionScreen calls endExam()
    - ExamProvider submits final session to backend
    - Backend performs comprehensive risk analysis
    - App navigates back to home screen
```

## Error Handling

### API Level
- Network timeouts (30 seconds)
- HTTP status code errors (400, 401, 403, 404, 429, 500)
- JSON parsing errors
- Connection errors

### Provider Level
- Try-catch blocks for all async operations
- Error state stored in provider
- Loading indicators for async operations

### UI Level
- SnackBar notifications for user errors
- Dialog confirmations for important actions
- Graceful fallbacks on permission denials

## Dependencies

```yaml
# HTTP & Networking
dio: ^5.3.1              # HTTP client with interceptors
http: ^1.1.0             # Additional HTTP utilities

# State Management
provider: ^6.0.0         # Provider pattern

# Storage
shared_preferences: ^2.2.2  # Local token storage

# Camera & Permissions
camera: ^0.10.5          # Device camera access
permission_handler: ^12.0.0  # Permission management

# Device Info
device_info_plus: ^9.0.2    # Device specifications
connectivity_plus: ^5.0.1   # Network status

# Image Processing
image: ^4.0.17           # Image handling

# Utilities
uuid: ^4.0.0             # Generate unique IDs
crypto: ^3.0.3           # Cryptographic functions
intl: ^0.19.0            # Internationalization
web_socket_channel: ^2.4.0  # WebSocket support
```

## API Endpoints Used

```
POST   /auth/register          # Student registration
POST   /auth/login             # Student login
POST   /auth/verify-face       # Face verification
POST   /auth/refresh-token     # Token refresh

GET    /exams                  # Get available exams
GET    /exams/:id              # Get exam details
POST   /exam-sessions/start    # Start exam session
POST   /exam-sessions/:id/events  # Submit proctoring event
GET    /exam-sessions/:id/events  # Get session events
POST   /exam-sessions/:id/end   # End exam session

POST   /auth/faculty-login     # Faculty login
GET    /faculty/dashboard      # Dashboard statistics
GET    /faculty/sessions/flagged  # Flagged sessions
GET    /faculty/sessions/:id   # Session for review
POST   /faculty/reviews        # Submit faculty review
```

## Running the App

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run in debug mode
flutter run -d <device_id>

# Release build
flutter build apk
flutter build ios
flutter build web
```

## Testing

```bash
# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Dependency Issues
```bash
flutter pub get
flutter pub upgrade
```

### API Connection Issues
- Check backend is running on configured URL
- Verify network connectivity
- Check API_BASE_URL in api_client.dart

### Camera Issues
- Ensure camera permission granted
- Check device has camera hardware
- Verify AndroidManifest.xml permissions (for Android)

### Token Issues
- Check SharedPreferences storage
- Verify backend sends valid tokens
- Clear app cache if persistent errors

### Build Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk  # or flutter build ios
```

## Performance Considerations

1. **Image Streaming**: Camera frames processed every 10 frames (~30ms intervals)
2. **API Throttling**: Events submitted with configurable frequency
3. **Battery**: Camera streaming impacts battery; recommend AC power during exams
4. **Network**: Real-time event submission requires stable internet
5. **Storage**: Tokens stored in SharedPreferences for fast startup

## Security Features

1. **Token Storage**: Tokens stored securely in SharedPreferences
2. **Token Refresh**: Automatic refresh on expiration
3. **HTTPS**: All API calls use HTTPS (enforced at backend)
4. **Permission Management**: Runtime permissions requested with context
5. **Face Verification**: ID verification before exam start
6. **Session Validation**: Backend validates session before accepting events

## Future Enhancements

1. **WebSocket Real-Time**: Replace polling with WebSocket for real-time updates
2. **Local Caching**: Cache exam list and previous sessions
3. **Offline Mode**: Buffer events when offline, sync when online
4. **Advanced Analytics**: Detailed proctoring event analytics
5. **Multi-Language**: Internationalization support
6. **Biometric Auth**: Fingerprint/face ID for login
7. **Secure Enclave**: Store tokens in secure device storage
8. **ML Integration**: On-device ML for frame analysis

## Contact & Support

For issues or questions regarding the frontend integration:
1. Check this guide first
2. Review error logs in Android Studio/Xcode
3. Contact the development team
4. Check backend logs for API issues

---

**Last Updated**: 2024
**Version**: 1.0.0
**Status**: Production Ready
