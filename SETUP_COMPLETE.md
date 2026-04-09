# Frontend-Backend Integration Summary & Setup Guide

## ✅ Fixes Applied

### 1. **Fixed Port Mismatch Issue**
**Problem**: Frontend was connecting to `http://localhost:3000/api` but backend runs on port 5000
**Solution**: Updated [lib/services/api_client.dart](lib/services/api_client.dart#L3) to use correct port
```dart
// Changed from: 'http://localhost:3000/api'
// Changed to: 'http://localhost:5000/api'
static const String _baseUrl = 'http://localhost:5000/api';
```

### 2. **Created Backend Environment Configuration**
Created [backend/.env](backend/.env) with all required environment variables:
- Database configuration
- JWT secrets for authentication
- CORS settings for frontend
- Server port (5000)

### 3. **Added Mock Database Support**
Created [backend/src/db/mock-connection.js](backend/src/db/mock-connection.js) to enable development without PostgreSQL
- The backend will automatically fall back to mock database if PostgreSQL is unavailable
- Supports user registration and login for testing

### 4. **Updated Database Connection** 
Modified [backend/src/db/connection.js](backend/src/db/connection.js) to:
- Attempt PostgreSQL connection first
- Automatically fall back to mock database if connection fails
- Log status for debugging

## 🚀 Running the Application

### Step 1: Start the Backend Server
```bash
cd backend
npm install  # (already done if dependencies were installed)
node src/server.js
```
**Expected Output**:
```
╔══════════════════════════════════════════════════╗
║   Exam Proctoring Backend Server Started        ║
║   Environment: development
║   Port: 5000
║   API: http://localhost:5000/api
║   Health Check: http://localhost:5000/health
╚══════════════════════════════════════════════════╝
```

✅ **Backend is currently running on port 5000** (verified with health check endpoint)

### Step 2: Test Backend Login Endpoint
With the backend running, you can test the login:
```
POST http://localhost:5000/api/auth/login
Body: {
  "studentId": "S001",
  "password": "password123"
}
```

### Step 3: Start the Flutter App

#### Option A: Run on Windows (Requires Developer Mode enabled)
```bash
cd exam_proctoring_app
flutter run -d windows
```

#### Option B: Run on Web
```bash
cd exam_proctoring_app
flutter run -d web
```

#### Option C: Run on Chrome
```bash
cd exam_proctoring_app
flutter run -d chrome
```

### Step 4: Test the Login Flow
1. Open the app (once running)
2. Navigate to login page
3. Register a new student OR use the default test credentials
4. After successful login, you should navigate to the home screen

## 📋 Login Flow Diagram

```
LoginScreen → _handleLogin()
    ↓
AuthProvider.login(studentId, password)
    ↓
ApiClient.login(request) → POST http://localhost:5000/api/auth/login
    ↓
Backend authController.login()
    ↓
Returns: { success: true, data: { accessToken, refreshToken, userId, ... } }
    ↓
AuthProvider stores tokens & updates isAuthenticated state
    ↓
Front-end navigates to /home screen
```

## 🔑 Test Credentials

You can register a new user through the app, or use these sample credentials after registering:
- **Student ID**: S001
- **Password**: password123

## ✅ Changes Made Summary

| File | Change |
|------|--------|
| [lib/services/api_client.dart](lib/services/api_client.dart#L3) | Changed port from 3000 to 5000 |
| [backend/.env](backend/.env) | New file - environment configuration |
| [backend/src/db/mock-connection.js](backend/src/db/mock-connection.js) | New file - mock database layer |
| [backend/src/db/connection.js](backend/src/db/connection.js) | Updated to support fallback to mock DB |

## 🛠️ Troubleshooting

### Backend won't start
1. Check if port 5000 is in use: `netstat -ano | findstr ":5000"`
2. Kill any existing process: `taskkill /PID [PID] /F`
3. Ensure .env file exists in backend directory

### Login fails
1. Verify backend is running on port 5000
2. Check frontend API URL is `http://localhost:5000/api`
3. Check network requests in browser DevTools

### Flutter won't build on Windows
1. Enable Developer Mode: `start ms-settings:developers`
2. Or use web version: `flutter run -d web`

## ✨ Next Steps

1. **Enable Database**: If you want to use PostgreSQL instead of mock database:
   - Install PostgreSQL
   - Create database: `exam_proctoring`
   - Run migrations: `npm run migrate` (from backend directory)

2. **Deploy**: When ready for production:
   - Remove mock database support
   - Use real PostgreSQL
   - Update environment variables for production

3. **Add More Features**: 
   - Face verification screen
   - Exam session management
   - Proctoring monitoring dashboard
