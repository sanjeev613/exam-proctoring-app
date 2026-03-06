# Setup Guide: Integrate Camera Companion with Real Backend

## What's Connected Now

```
┌─────────────────────────────────────────────────────────┐
│                   Your App                              │
├─────────────────────────────────────────────────────────┤
│  Frontend (port 8080)    Backend (port 5000)            │
│   ├─ Camera Widget  ◄───► /api/exams/camera/*           │
│   ├─ Dashboard      ◄───► Proctor monitoring            │
│   └─ Proctoring     ◄───► /dashboard                    │
│        Monitor         (Proctoring Dashboard)           │
│                                                         │
│  Companion Service (Windows/Python)                     │
│   ├─ Captures camera frames                             │
│   └─ POSTs to backend: /api/exams/camera/ingest         │
└─────────────────────────────────────────────────────────┘
```

## Quick Start (All 3 Components)

### 1. **Start Backend** (PowerShell)
```powershell
cd C:\Users\sanje\exam_proctoring_app\backend
npm install  # if needed
npm start
# Runs on http://localhost:5000
```

### 2. **Start Frontend** (new PowerShell)
```powershell
cd C:\Users\sanje\exam_proctoring_app
flutter run -d chrome --web-port=8080
# Runs on http://localhost:8080
```

### 3. **Start Camera Companion** (new PowerShell)
```powershell
cd C:\Users\sanje\exam_proctoring_app\camera_companion
& .\venv\Scripts\Activate.ps1
# Change to real backend endpoint:
$env:COMPANION_BACKEND_URL = 'http://localhost:5000'
$env:COMPANION_SESSION_ID = 'test-session-123'  # or get from app
python companion_production.py
```

## Files Updated/Created

- **Backend Routes** → `backend/src/routes/examRoutes.js`
  - `POST /api/exams/camera/ingest` — receive frames
  - `GET /api/exams/camera/latest` — get latest frame
  - `GET /api/exams/camera/status/:sessionId` — check status

- **Backend Controller** → `backend/src/controllers/examController.js`
  - `ingestCameraFrame()` — store frame metadata, broadcast to proctors
  - `getLatestCameraFrame()` — return frame reference
  - `getCameraStatus()` — return status for a session

- **Frontend Widget** → `lib/widgets/camera_widget.dart`
  - Flutter widget that displays live camera feed during exam
  - Polls backend every 2 seconds for latest frame

- **Proctor Dashboard** → `backend/src/public/dashboard/index.html`
  - Modern dashboard for faculty to monitor exam sessions
  - **Access:** http://localhost:5000/dashboard
  - **Start monitoring:** Enter session ID and click "Connect Session"

## How It Works

### During Exam:
1. **Student starts exam** → Flutter frontend shows exam questions + camera widget
2. **Camera companion** captures webcam → sends frames to `/api/exams/camera/ingest`
3. **Backend stores** frame metadata & broadcasts to watching proctors
4. **Camera widget displays** latest frame in student app (read-only)

### For Faculty Proctors:
1. Open http://localhost:5000/dashboard (Proctor Dashboard)
2. Enter the exam session ID
3. Click "Connect Session" → live camera feed appears
4. Monitor in real-time

## Production Deployment

For production, consider:

**Security:**
- Use HTTPS/TLS for all communication
- Authenticate camera ingest endpoint with JWT (already implemented)
- Use RS256 keys stored securely (not in code)
- Implement frame encryption at rest

**Storage:**
- Store frames in secure cloud storage (AWS S3, Azure Blob)
- Add encryption key rotation
- Retention policies (auto-delete after exam period)

**Scaling:**
- Use message queue (RabbitMQ, Kafka) for frame ingest
- Stream frames via WebRTC peer-to-peer
- Build distributed proctoring system

## Environment Variables

**Companion Configuration:**
```powershell
$env:COMPANION_BACKEND_URL = 'http://localhost:5000'           # Backend URL
$env:COMPANION_SESSION_ID = 'exam-session-12345'               # Session ID
$env:COMPANION_ALGO = 'HS256'                                  # JWT algorithm (HS256 or RS256)
$env:PROTOTYPE_SECRET = 'your-secret-key-min-32-chars'         # For HS256
$env:PROTOTYPE_PRIVATE_KEY = 'C:\\path\\to\\keys\\private.pem' # For RS256
```

## Testing

### Test Camera Ingest:
```bash
curl -X POST http://localhost:5000/api/exams/camera/ingest \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"test-123","timestamp":"2026-02-23T12:00:00Z","frameData":"BASE64_IMAGE"}'
```

### Test Camera Status:
```bash
curl http://localhost:5000/api/exams/camera/status/test-123
```

### Test Dashboard:
- Open: http://localhost:5000/dashboard
- Enter session ID: `test-123`
- Click "Connect Session"

## Troubleshooting

**Dashboard shows "Frame Unavailable":**
- Ensure companion is running and sending frames to port 6000
- Check CORS: backend allows localhost:6000
- Verify Session ID is correct

**No frames received:**
- Check companion is running: `Get-Process python`
- Check backend logs for ingest errors
- Verify JWT token (if using RS256, check key paths)

**Camera widget shows error in Flutter app:**
- Ensure backend is responding: `curl http://localhost:5000/health`
- Check Flutter app web port is 8080
- Look at browser console for CORS errors

## Next Steps

1. ✅ Test the full flow with all 3 components running
2. ✅ Verify frames appear in both camera widget and dashboard
3. ✅ Set up database to store frame metadata (optional)
4. ✅ Implement frame storage and retrieval (file system or cloud)
5. ✅ Add alert system for suspicious activity detection
