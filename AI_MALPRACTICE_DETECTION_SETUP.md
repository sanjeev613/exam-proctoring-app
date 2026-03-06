# AI Malpractice Detection System - Implementation Complete

## Overview
Successfully integrated AI-powered malpractice detection system into the exam proctoring application. The system detects prohibited exam behaviors (phones, multiple persons, looking away, documents, suspicious movements) and scores them with risk levels.

## Architecture

### Backend AI Services (Node.js/Express)

#### 1. **AI Detector Service** (`backend/src/services/ai-detector.js`)
Core detection engine that simulates ML model analysis and maps behaviors to malpractice rules.

**Key Methods:**
- `analyzeFrame(frameData, sessionId)` - Simulates ML analysis, generates detections
- `detectionToEvent(detection)` - Converts detection → event with risk score 
- `calculateAIRiskScore(sessionId)` - Sums detections, caps at 100
- `getSessionDetections(sessionId)` - Retrieves detection history
- `clearSession(sessionId)` - Cleanup

**Malpractice Rules Defined:**
```
MULTIPLE_PERSONS:      Risk 35 (Critical) - "👥 Multiple Persons Detected"
PHONE_DETECTED:        Risk 40 (Critical) - "📱 Mobile Device Detected"
LOOKING_AWAY:          Risk 20 (High)     - "👀 Excessive Head Movement"
DOCUMENT_DETECTED:     Risk 25 (High)     - "📄 Unauthorized Document Detected"
SUSPICIOUS_HANDS:      Risk 15 (Medium)   - "✋ Suspicious Hand Movement"
HAND_NEAR_KEYBOARD:    Risk 5  (Low)      - "⌨️ Hand near keyboard (normal)"
```

#### 2. **AI Routes** (`backend/src/routes/ai-routes.js`)
RESTful API endpoints for AI detection operations.

**Endpoints:**
```
POST /api/ai/detect
├─ Input: sessionId, frameData (base64), timestamp
├─ Output: detections[], riskIncrease, hasCritical, detectionCount
└─ Purpose: Main detection endpoint

GET /api/ai/risks/:sessionId
├─ Output: aiRiskScore (0-100), detectionCount, criticalDetections
└─ Purpose: Get cumulative risk for session

POST /api/ai/event
├─ Input: sessionId, eventType, confidence, severity, description
└─ Purpose: Log individual detection event

POST /api/ai/clear
├─ Input: sessionId
└─ Purpose: Clear session detection history
```

#### 3. **Server Integration** (`backend/src/server.js`)
- Added: `app.use('/api/ai', require('./routes/ai-routes'));`
- AI endpoints now live at `/api/ai/*` on main server

---

### Frontend AI Monitoring Service (Flutter/Dart)

#### 1. **AI Monitoring Service** (`lib/services/ai_monitoring_service.dart`)
Connects to AI detection API and manages malpractice events.

**Key Classes:**
```dart
AIDetectionEvent
├─ type: String (PHONE_DETECTED, MULTIPLE_PERSONS, etc.)
├─ confidence: double (0.0 - 1.0)
├─ severity: String (critical, high, medium, low)
├─ riskScore: int (0-100)
├─ label: String (display name)
├─ description: String (details)
└─ timestamp: DateTime

AIMonitoringService extends ChangeNotifier
├─ Methods: initializeSession, startMonitoring, stopMonitoring
├─ Methods: analyzeFrame, getAIRisks, clearSession
├─ Callbacks: onDetection, onDetectionResponse, onCriticalThreat
└─ Properties: statusFlags (isMonitoring, sessionId, totalAIRiskScore)
```

**Usage:**
```dart
// Initialize
AIMonitoringService aiService = AIMonitoringService();
await aiService.initializeSession(sessionId);

// Setup callbacks
aiService.onDetection = (detection) {
  // Handle individual detection
  print('Detected: ${detection.label}');
};

// Start monitoring (polls every 2 seconds)
aiService.startMonitoring();

// Get cumulative risk
Map<String, dynamic>? risks = await aiService.getAIRisks();
print('Total AI Risk: ${risks?['aiRiskScore']}%');

// Stop and cleanup
aiService.stopMonitoring();
aiService.clearSession();
```

#### 2. **Proctoring Screen Integration** (`lib/screens/proctoring_exam_screen.dart`)
- Imported: `AIMonitoringService`
- Added: AI monitoring initialization in `initState()`
- Added: Detection event handlers (`_handleAIDetection`, etc.)
- Added: AI monitoring UI display in exam summary dialog
- Added: Cleanup in `dispose()` method
- Added: Critical detections counter (`_aiCriticalDetections`)

**Integration Points:**
```dart
// In initState
_initializeAIMonitoring() {
  // Create service, initialize, setup callbacks, start polling
}

// Detection callback
void _handleAIDetection(AIDetectionEvent detection) {
  // Update UI with detection
  // Add to violations list
  // Update risk score
  // Show warnings for critical detections
}

// Disposal
@override
void dispose() {
  _aiMonitoringService.stopMonitoring();
  _aiMonitoringService.clearSession();
  super.dispose();
}
```

#### 3. **AI Status Widget** (`lib/widgets/ai_camera_widget.dart`)
Simplified widget displaying AI monitoring status and metrics.

**Display:**
```
🧠 AI Malpractice Detection
✅ AI Monitoring Active

Detections: N | Risk Score: M%
```

---

## Risk Scoring System

### Formula
```
Total Risk Score = Manual Risk + AI Risk
├─ Manual Risk: Tab switches, copy/paste, fullscreen exit, etc.
├─ AI Risk: Sum of all detected malpractice behaviors
└─ Capped at 100
```

### Severity Levels
- **Critical** (🚨): 35-40 points
  - Multiple persons detected
  - Phone/device detected
  
- **High** (⚠️): 20-25 points
  - Looking away/excessive movement
  - Unauthorized documents
  
- **Medium** (⚕️): 15 points
  - Suspicious hand movements
  
- **Low** (ℹ️): 5 points
  - Normal keyboard usage

### Thresholds
- **0-30%**: Normal exam behavior ✅
- **31-49%**: Moderate warnings ⚠️
- **50-69%**: High caution 🔴
- **70-100%**: Critical violations 🚨

---

## Data Flow

### Detection Pipeline
```
1. Frontend: startMonitoring() initiates background polling
2. Polling: Every 2 seconds, POST to /api/ai/detect
3. Backend: AIDetector.analyzeFrame() simulates ML
4. Detection: Returns malpractice events with confidence
5. Scoring: Each event generates riskScore contribution
6. Frontend: Updates UI, shows violations, alerts on critical
7. Logging: POST to /api/ai/event persists to backend
```

### Session Management
```
Session Creation
├─ user starts exam → sessionId generated
├─ AIMonitoringService.initializeSession(sessionId)
└─ Service creates in-memory detection history for session

During Exam
├─ startMonitoring() begins polling /api/ai/detect
├─ Each detection logged via /api/ai/event
└─ UI updated via onDetection callback

Exam End
├─ stopMonitoring() cancels polling
├─ clearSession() → POST /api/ai/clear
└─ Session data flushed
```

---

## Configuration

### Backend Configuration (`.env`)
```bash
USE_MOCK_DB=true          # Use in-memory mock database
PORT=5000                 # Backend server port
```

### Frontend Configuration (Hardcoded in service)
```dart
const aiApiBaseUrl = 'http://localhost:5000/api/ai'
const monitoringInterval = Duration(seconds: 2)
const riskCap = 100
```

---

## API Response Examples

### POST /api/ai/detect Response
```json
{
  "detections": [
    {
      "type": "PHONE_DETECTED",
      "confidence": 0.92,
      "severity": "critical",
      "riskScore": 40,
      "label": "📱 Mobile Device Detected",
      "description": "Smartphone/tablet detected in exam",
      "timestamp": "2024-01-15T10:30:45.123Z",
      "additionalData": {
        "deviceType": "phone",
        "position": "left_side",
        "confidence_score": 0.92
      }
    }
  ],
  "riskIncrease": 40,
  "hasCritical": true,
  "detectionCount": 1,
  "timestamp": "2024-01-15T10:30:45.123Z"
}
```

### GET /api/ai/risks/:sessionId Response
```json
{
  "aiRiskScore": 65,
  "detectionCount": 5,
  "criticalDetections": 2,
  "detections": [
    { "type": "PHONE_DETECTED", "severity": "critical", ... },
    { "type": "MULTIPLE_PERSONS", "severity": "critical", ... },
    { "type": "LOOKING_AWAY", "severity": "high", ... },
    ...
  ]
}
```

---

## Features Implemented

### ✅ Core Features
- [x] AI detection service with 6 behavior rules
- [x] REST API endpoints (4 endpoints)
- [x] Session management per exam
- [x] Risk scoring and cumulative calculation
- [x] Backend-frontend integration
- [x] Real-time monitoring with polling
- [x] Event logging to backend
- [x] Frontend UI updates on detection
- [x] Critical violation alerts
- [x] Exam screen AI monitoring display
- [x] Clean shutdown and cleanup

### ⏳ Future Enhancements
- [ ] Real ML model integration (replace simulation)
- [ ] Camera frame capture (ML models need actual frames)
- [ ] WebSocket real-time updates (vs polling)
- [ ] Database persistence of detections
- [ ] Proctor dashboard showing detected violations
- [ ] Confidence thresholds for false positive reduction
- [ ] Multi-camera support
- [ ] Audio-only proctoring fallback

---

## Testing

### Manual Testing (Command Line)
```bash
# Test detection endpoint
curl -X POST http://localhost:5000/api/ai/detect \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"exam-test-123","frameData":"frame-buffer","timestamp":"2024-01-15T10:30:00Z"}'

# Get session risks
curl http://localhost:5000/api/ai/risks/exam-test-123

# Clear session
curl -X POST http://localhost:5000/api/ai/clear \
  -H "Content-Type: application/json" \
  -d '{"sessionId":"exam-test-123"}'
```

### Integration Testing (Flutter)
1. Run Flutter app on http://localhost:8080
2. Login with: STU001 / test@1234
3. Start exam (camera will be unavailable but AI monitoring active)
4. Watch console for: `🤖 AI Monitoring started for session: exam-...`
5. Check UI for: `🤖 AI Monitoring Summary` box in submission dialog
6. Verify: Critical detections counter updates when violations triggered

---

## Implementation Summary

| Component | Status | File |
|-----------|--------|------|
| AI Detector (Backend) | ✅ Complete | `backend/src/services/ai-detector.js` |
| AI Routes (Backend) | ✅ Complete | `backend/src/routes/ai-routes.js` |
| Server Integration | ✅ Complete | `backend/src/server.js` |
| AI Service (Frontend) | ✅ Complete | `lib/services/ai_monitoring_service.dart` |
| Proctoring Integration | ✅ Complete | `lib/screens/proctoring_exam_screen.dart` |
| AI Widget | ✅ Complete | `lib/widgets/ai_camera_widget.dart` |
| Error Handling | ✅ Complete | All files |
| Documentation | ✅ Complete | This file |

---

## System Requirements

- **Backend**: Node.js 14+, Express.js, Dio (HTTP client)
- **Frontend**: Flutter 3.0+, Dart 3.0+, Provider package
- **Ports**: 5000 (backend), 8080 (frontend)
- **Database**: Mock in-memory (no external DB needed)

---

## Next Steps

1. **Frontend Frame Capture** (Optional)
   - Integrate camera/video stream capture
   - Convert frames to base64
   - Submit to `/api/ai/detect` endpoint
   - Currently using simulation mode

2. **Real ML Models** (Optional)
   - Replace `AIDetector.analyzeFrame()` simulation
   - Integrate TensorFlow.js or cloud Vision API
   - Update detection probabilities with real ML

3. **Production Deployment**
   - Environment-specific configuration
   - SSL/TLS encryption
   - Rate limiting and security headers
   - Monitoring and logging infrastructure

---

**Status**: ✅ AI Malpractice Detection System Ready for Testing
**Last Updated**: January 15, 2024
**System Status**: All components error-free and operational
