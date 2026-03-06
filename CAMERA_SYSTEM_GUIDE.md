# 🎥 Exam Proctoring App - Camera Integration Complete

## ✅ What's Fully Integrated

Your exam proctoring app now includes:

1. **Backend Camera Endpoints** ✅
   - `POST /api/exams/camera/ingest` — receive frames from companion
   - `GET /api/exams/camera/latest` — get latest frame for monitoring
   - `GET /api/exams/camera/status/:sessionId` — check camera status
   - Uses JWT authentication (HS256/RS256 support)

2. **Frontend Camera Widget** ✅
   - Flutter widget (`camera_widget.dart`) for exam students
   - Displays live camera feed during exam (read-only, student cannot control)
   - Auto-refreshes every 2 seconds
   - Shows frame count and connection status

3. **Proctor Monitoring Dashboard** ✅
   - Web-based dashboard at `http://localhost:5000/dashboard`
   - Real-time camera feed monitoring for faculty/proctors
   - Session-based monitoring (enter session ID to start)
   - Activity log and statistics
   - Professional UI with live status indicators

4. **Camera Companion Service** ✅
   - Windows-compatible Python service (with venv support)
   - Captures webcam frames automatically
   - Sends to backend via JWT-authenticated API
   - Two versions:
     - **Prototype**: `companion.py` (for testing with local prototype server)
     - **Production**: `companion_production.py` (connects to real backend)

---

## 🚀 Quick Start (Full Integration)

### Terminal 1: Start Backend
```powershell
cd C:\Users\sanje\exam_proctoring_app\backend
npm install
npm start
# Backend running on http://localhost:5000
```

### Terminal 2: Start Frontend
```powershell
cd C:\Users\sanje\exam_proctoring_app
flutter run -d chrome --web-port=8080
# Frontend running on http://localhost:8080
```

### Terminal 3: Start Camera Companion (Production)
```powershell
cd C:\Users\sanje\exam_proctoring_app\camera_companion
& .\venv\Scripts\Activate.ps1
$env:COMPANION_BACKEND_URL = 'http://localhost:5000'
$env:COMPANION_SESSION_ID = 'test-exam-001'
python companion_production.py
```

---

## 📱 Using the System

### For Students (During Exam)
1. Start exam in Flutter app on port 8080
2. Camera widget appears alongside exam questions
3. Camera feed displays live (read-only)
4. **Student cannot:** disable camera, stop recording, or manipulate feed

### For Proctors (Monitoring)
1. Open http://localhost:5000/dashboard in browser
2. Enter exam session ID (e.g., `test-exam-001`)
3. Click "Connect Session"
4. Live camera feed appears
5. Monitor activity log and frame count
6. Multiple proctors can monitor same session simultaneously

---

## 📂 Files Created/Modified

```
exam_proctoring_app/
├── backend/
│   └── src/
│       ├── routes/
│       │   └── examRoutes.js          [UPDATED] — added camera endpoints
│       ├── controllers/
│       │   └── examController.js      [UPDATED] — added camera methods
│       ├── server.js                  [UPDATED] — made io global
│       └── public/
│           └── dashboard/
│               └── index.html         [UPDATED] → beautiful proctor dashboard
│
├── lib/
│   └── widgets/
│       └── camera_widget.dart         [NEW] — Flutter camera display widget
│
├── camera_companion/
│   ├── companion.py                   [EXISTING] — prototype version
│   ├── companion_production.py        [NEW] — production version (uses real backend)
│   ├── prototype_server.py            [EXISTING] — test server
│   ├── requirements.txt               [EXISTING] — Python deps
│   └── widgets.html                   [EXISTING] — prototype UI
│
├── CAMERA_INTEGRATION_SETUP.md        [NEW] — detailed setup guide
└── CAMERA_SYSTEM_GUIDE.md             [THIS FILE] — overview & quick start
```

---

## 🔒 Security Features

✅ **JWT Authentication**
- Companion signs requests with JWT (HS256 or RS256)
- Backend validates token before accepting frames
- Tokens are session-scoped and time-limited

✅ **Read-Only Student View**
- Camera widget is display-only
- Student cannot disable/control camera
- No camera controls exposed in UI

✅ **Access Control**
- Camera status endpoint requires authentication
- Proctors can only monitor their assigned sessions (extendable)

✅ **Network Security**
- Ready for HTTPS/TLS in production
- CORS properly configured for all origins

---

## 🧪 Testing

### Test 1: Full Flow with All Components
```bash
# Ensure all 3 servers running (see Quick Start above)
1. Open http://localhost:5000/dashboard
2. Enter session ID: test-exam-001
3. See live camera feed
4. Open http://localhost:8080 (student app)
5. See camera in exam screen
```

### Test 2: Direct Backend API
```bash
# Check camera status
curl http://localhost:5000/api/exams/camera/status/test-exam-001 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get latest frame reference
curl http://localhost:5000/api/exams/camera/latest?sessionId=test-exam-001 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test 3: Proctoring Dashboard Only
```bash
# Without running companion/frontend:
1. Open http://localhost:5000/dashboard
2. Enter any session ID
3. Try to connect (will show "connection error" — that's OK, shows UI works)
```

---

## 🏗️ Architecture Overview

```
                    ┌──────────────────┐
                    │  Student Laptop  │
                    └──────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
    ┌─────────┐        ┌──────────┐      ┌────────────┐
    │ Camera  │        │  Flutter │      │ Companion  │
    │         │        │   App    │      │  Service   │
    │ Hardware│◄──────►│ (Port    │◄────►│ (Captures) │
    └─────────┘        │  8080)   │      └────────────┘
                       └──────────┘             │
                            │                  │
                            │ HTTP             │ HTTP
                            │ (Camera          │ (Frames +
                            │  Widget)         │  JWT)
                            │                  │
                    ┌───────▼──────────────────▼──────┐
                    │    Backend (Port 5000)          │
                    ├─────────────────────────────────┤
                    │ /api/exams/camera/ingest        │
                    │ /api/exams/camera/latest        │
                    │ /api/exams/camera/status:sessionId
                    │                                 │
                    │ + Socket.IO for real-time ◄────┤────┐
                    │   updates                       │    │
                    └─────────────────────────────────┘    │
                            ▲                              │
                            │ HTTP                         │
                            │ (Dashboard)                  │
                            │                              │
                    ┌───────────────────────────────────┐  │
                    │ Proctor Browser                   │  │
                    │ /dashboard                        │◄─┘
                    │ (Real-time camera + activity log)│
                    └───────────────────────────────────┘
```

---

## 🎯 How Each Component Works

### 1. Camera Companion (`companion_production.py`)
- Runs as background Windows service/process
- Captures from default webcam every 2 seconds
- Signs each frame with JWT (session-scoped token)
- POSTs to `http://localhost:5000/api/exams/camera/ingest`
- Logs success/failures with timestamps
- **Student cannot:** kill process (with proper Windows policies)

### 2. Backend (`backend/src/server.js`)
- Receives frames via `/api/exams/camera/ingest` endpoint
- Validates JWT token (checks signature & expiration)
- Broadcasts frame event to proctors via Socket.IO
- Stores frame metadata (optional database integration)
- Serves dashboard at `/dashboard`
- All global.io available for real-time updates

### 3. Frontend (`lib/widgets/camera_widget.dart`)
- Flutter widget renders during exam
- Polls backend every 2 seconds for latest frame
- Displays image in read-only container (no controls)
- Shows status (Live / Error / Connecting)
- Frame counter for verification

### 4. Proctor Dashboard (`backend/src/public/dashboard/index.html`)
- Static HTML/JS served from backend
- Faculty enters session ID to monitor
- Polls backend for latest frame
- Displays in real-time with beautiful UI
- Shows activity log + statistics
- Multiple proctors can watch same session

---

## 🔧 Customization

### Change Frame Capture Rate
**File:** `camera_companion/companion_production.py`
```python
CAPTURE_INTERVAL = 2  # Change to 1 for every 1 second, 3 for every 3 seconds, etc.
```

### Change Frame Quality
**File:** `camera_companion/companion_production.py`
```python
ret2, buf = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 70])
# Change 70 to higher (90) for better quality or lower (50) for smaller file size
```

### Change Frame Size (reduce bandwidth)
**File:** `camera_companion/companion_production.py`
```python
# Add this before encoding:
frame = cv2.resize(frame, (640, 480))  # Resize to 640x480 instead of full resolution
```

### Store Frames to Disk (for review)
**File:** `backend/src/controllers/examController.js`
```javascript
// Add this in ingestCameraFrame():
const fs = require('fs');
const frameDir = `/path/to/frame/storage/${sessionId}`;
// ... save buf to frameDir
```

---

## 📊 Next Steps

1. ✅ **Test locally** with all components running
2. ✅ **Verify frames** appear in both widget and dashboard
3. 📍 **Add database storage** for frame metadata
4. 📍 **Implement frame archiving** (S3/Azure Blob)
5. 📍 **Add alert detection** (face detection, multiple faces, etc.)
6. 📍 **Deploy to production** (HTTPS, load balancer, clustering)

---

## ⚠️ Known Limitations (Prototype)

- Frames stored in memory (not persisted)
- No face detection/suspicious activity flagging yet
- Single machine deployment (not distributed)
- No encryption at rest
- Frame quality/bandwidth not optimized

These can be added in production deployment.

---

## 🆘 Troubleshooting

**Q: Dashboard shows "Camera Feed Unavailable"**
- A: Ensure companion is running and backend receives frames. Check browser console for CORS errors.

**Q: Camera widget not showing in Flutter app**
- A: Verify backend is running on port 5000. Check `flutter run` console for network errors.

**Q: Companion not sending frames**
- A: Run: `Get-Process python` to verify it's running. Check the log output for errors.

**Q: "Connection refused" on 5000**
- A: Start backend: `cd backend && npm start`

**Q: JWT token errors**
- A: Ensure `PROTOTYPE_SECRET` is set: `$env:PROTOTYPE_SECRET='test-secret'`

---

## 📞 Support

For issues or questions, check:
1. [CAMERA_INTEGRATION_SETUP.md](CAMERA_INTEGRATION_SETUP.md) — detailed setup
2. Terminal logs for error messages
3. Browser console (F12) for frontend errors
4. Backend logs for API errors

---

**🎉 Your exam proctoring app now has a fully integrated camera system!**

**Ready to test?** Start all 3 components above and open http://localhost:5000/dashboard 📊
