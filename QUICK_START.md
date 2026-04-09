# Quick Start Guide - Exam Proctoring App

## Prerequisites

- Java JDK 11+ (for Android development)
- Flutter SDK (latest stable)
- Android Studio and/or Xcode (for iOS)
- An Android device or Android emulator running Android 5.0+
- Node.js v18+ (for running backend)
- Backend server running on `http://localhost:3000` (or update API_BASE_URL)

## Step 1: Start the Backend

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Start the server
npm start
```

The backend should be running on `http://localhost:3000`

## Step 2: Configure Frontend API URL

Edit `lib/services/api_client.dart` and ensure the API base URL matches your backend:

```dart
class ApiClient {
  static const String _apiBaseUrl = 'http://localhost:3000/api';
  // OR if running on real device:
  // static const String _apiBaseUrl = 'http://<YOUR_IP>:3000/api';
}
```

For Android Emulator, use `10.0.2.2` instead of `localhost`:
```dart
static const String _apiBaseUrl = 'http://10.0.2.2:3000/api';
```

## Step 3: Get Dependencies

```bash
# Navigate to app directory
cd exam_proctoring_app

# Get all dependencies
flutter pub get
```

## Step 4: Run the App

### On Android Emulator

```bash
# Start emulator first (or connect device)
flutter emulators --launch Pixel_4a_API_30

# Run app
flutter run
```

### On Connected Android Device

```bash
# Ensure device is connected
adb devices

# Run app
flutter run -d <device_id>
```

### On iOS (Mac only)

```bash
# Run on iOS simulator
flutter run -d ios

# Or on physical device
flutter run -d <device_id>
```

## Step 5: Test the App

### Test Account 1 - Student
- **Student ID**: `STU001`
- **Password**: `password123`

### Test Account 2 - Student
- **Student ID**: `STU002`
- **Password**: `password123`

### Test Account 3 - Faculty
- **Email**: `admin@university.edu`
- **Password**: `admin123`

## Common Workflows

### 1. Test Student Login and Exam

1. Run the app
2. Enter Student ID and password
3. Tap "Login"
4. If face verification required, upload an image
5. View available exams on Home screen
6. Tap "Start Exam" on any exam
7. Review system requirements and tap "Continue"
8. Exam session starts with timer and camera

### 2. Test Multiple Exams

1. Login as student
2. Take exam (or close app to simulate interrupt)
3. Go back to home screen
4. Select another exam
5. Both exam sessions should be visible on faculty dashboard

### 3. Test Faculty Dashboard (Web Required)

Faculty dashboard uses web interface (separate build):
```bash
flutter build web
# Open browser to http://localhost:3000/faculty
```

## Debugging

### Check Logs

```bash
# View Flutter logs in real-time
flutter logs

# With verbose output
flutter logs -v
```

### Network Debugging

```bash
# Enable network logging (add to api_client.dart):
_dio.interceptors.add(
  LoggingInterceptor(),  // Add logging interceptor
);
```

### Device Permissions

Ensure permissions are granted:
- Open device Settings
- Find app in installed apps
- Grant Camera and Microphone permissions

### Common Issues

#### "Connection refused" Error
- Verify backend is running
- Check correct IP/port in API_BASE_URL
- On Android Emulator: use `10.0.2.2` instead of `localhost`

#### "Camera permission denied"
- Check device has camera
- Grant permission when prompted
- Go to Settings → Apps → Exam Proctoring → Permissions

#### "Build fails"
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

#### "Token invalid/expired"
- Token refreshes automatically on 401
- Clear app data if persistent:
  - Settings → Apps → Exam Proctoring → Storage → Clear Data

## Project Structure Tour

```
lib/
├── main.dart                 # App initialization, routing, providers
├── models/api_models.dart    # API data models
├── services/api_client.dart  # HTTP client (Dio)
├── providers/
│   ├── auth_provider.dart    # Login, registration, tokens
│   └── exam_provider.dart    # Exam sessions, events, scoring
└── screens/
    ├── login_screen.dart     # Authentication UI
    ├── home_screen.dart      # Exam list, profile
    ├── exam_session_screen.dart  # Proctoring interface
    └── environment_check_screen.dart  # System validation
```

## API Integration Details

### Authentication Flow

```dart
// 1. Login
final response = await apiClient.login('STU001', 'password123');
// Returns: {accessToken, refreshToken, user}

// 2. Token auto-injected in all requests
// Authorization: Bearer <accessToken>

// 3. Auto-refresh on 401
// If 401 received, automatically refresh token and retry
```

### Exam Event Submission

```dart
// During exam, events submitted frequently
await examProvider.submitEvent(
  eventType: 'frameCapture',
  severity: 'low',
  description: 'Frame captured for monitoring'
);

// Risk score updated and displayed in real-time
```

## Performance Metrics

- **App Startup**: ~2-3 seconds
- **Login**: ~1-2 seconds (network dependent)
- **Exam Load**: ~1 second
- **Frame Submission**: ~100-200ms per event
- **Risk Calculation**: ~50-100ms on backend

## Device Recommendations

- **Minimum**: Android 5.0, 2GB RAM, 50MB storage
- **Recommended**: Android 8.0+, 4GB+ RAM, 100MB storage
- **Battery**: AC power recommended during exams
- **Network**: WiFi recommended (5G or 4G acceptable)

## Testing Checklist

- [ ] App launches without crashes
- [ ] Login screen displays correctly
- [ ] Student can login with valid credentials
- [ ] Login fails with invalid credentials
- [ ] Home screen shows available exams
- [ ] Environment check validates permissions
- [ ] Exam session starts with timer
- [ ] Camera initializes and streams
- [ ] Risk score updates during exam
- [ ] Events submitted successfully
- [ ] End exam completes session
- [ ] Logout clears user info
- [ ] Faculty can login separately

## Next Steps

1. **Deploy Backend**: In production, deploy to:
   - Heroku, AWS, Google Cloud, Azure, etc.
   - Update API_BASE_URL to production URL

2. **Build Production App**:
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

3. **Implement WebSocket** (optional):
   - For real-time event delivery
   - Update api_client.dart with WebSocket connection

4. **Set Up CI/CD**:
   - GitHub Actions for automated testing
   - Automated builds for staging/production

5. **App Store Distribution**:
   - Create Google Play Developer account
   - Create Apple Developer account
   - Follow review process for each store

## Useful Commands

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# View connected devices
flutter devices

# Install to specific device
flutter install -d <device_id>
```

## Documentation References

- [Flutter Documentation](https://flutter.dev)
- [Dio Package](https://pub.dev/packages/dio)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Camera Package](https://pub.dev/packages/camera)
- [Backend API Documentation](../backend/API_DOCUMENTATION.md)

## Support

For issues or questions:

1. Check this guide
2. Review Flutter logs: `flutter logs`
3. Check backend logs
4. Search Flutter documentation
5. Ask on Flutter community forums

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: Ready for Testing
