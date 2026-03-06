# 🚀 Quick Start - All Services on localhost

Your exam proctoring app now has **unified launchers** to start everything with a single command!

---

## ⚡ **Option 1: PowerShell - RECOMMENDED (Windows)**

**Easiest & Most Reliable**

```powershell
cd C:\Users\sanje\exam_proctoring_app
.\run_all.ps1
```

**What happens:**
- ✅ Backend starts (port 5000)
- ✅ Frontend starts (port 8080)  
- ✅ Camera companion starts (background)
- ✅ All logs visible in separate windows

**Flags:**
```powershell
.\run_all.ps1 -Clean              # Kill old processes first
.\run_all.ps1 -NoCamera           # Skip camera (just backend + frontend)
.\run_all.ps1 -Clean -NoCamera    # Both options
```

**Stop:** Press `Ctrl+C` in any window, or close all windows

---

## ⚡ **Option 2: Batch File (.bat) - Simple Alternative**

```cmd
cd C:\Users\sanje\exam_proctoring_app
run_all.bat
```

**What happens:**
- Opens 3 separate command windows (Backend, Camera, Frontend)
- All running simultaneously on localhost
- Shows status banner when ready

**Stop:** Close any/all command windows

---

## 🎯 **Once Everything is Running**

### **Access Points (All on localhost):**

| Component | URL | Purpose |
|-----------|-----|---------|
| **Student App** | http://localhost:8080 | Student takes exam (see camera widget) |
| **Proctor Dashboard** | http://localhost:5000/dashboard | Faculty monitors camera + activity |
| **Backend API** | http://localhost:5000/api | REST API endpoints |
| **Health Check** | http://localhost:5000/health | Verify backend is running |

### **Quick Test:**

1. **Open in 3 browser tabs:**
   - http://localhost:8080 (student view)
   - http://localhost:5000/dashboard (proctor view)
   - http://localhost:5000/health (API check)

2. **In Proctor Dashboard:**
   - Enter Session ID: `exam-session-001`
   - Click "Connect Session"
   - See live camera feed

3. **In Student App:**
   - Should see camera widget on exam screen
   - Camera displays live (read-only)

---

## 🌐 **Optional: Single Port Proxy (Advanced)**

If you want **everything on ONE port** (e.g., http://localhost:8000):

### Setup:
```powershell
cd backend
npm install http-proxy-middleware express
cd ..
```

### Run Proxy:
```powershell
node unified_proxy.js        # Runs on port 8000
node unified_proxy.js 9000   # Or custom port 9000
```

### Access points:
- http://localhost:8000/ → Student app
- http://localhost:8000/dashboard → Proctor dashboard
- http://localhost:8000/api → All API endpoints
- http://localhost:8000/health → Service status

---

## 📋 **Service Status Monitor**

While running, you can check if services are healthy:

```powershell
# Check backend
curl http://localhost:5000/health

# Check frontend (should return HTML)
curl http://localhost:8080 | Select-Object -First 10

# Check all at once
@('http://localhost:5000/health', 'http://localhost:8080', 'http://localhost:8000') | ForEach-Object {
    Write-Host "Checking $_..."
    Invoke-WebRequest -Uri $_ -UseBasicParsing -TimeoutSec 2 | Out-Null
    Write-Host "✅ OK`n"
}
```

---

## 🆘 **Troubleshooting**

**"Port already in use" error?**
```powershell
# Kill existing processes
Get-Process node, python | Stop-Process -Force
.\run_all.ps1
```

**Camera not showing?**
- Ensure camera is connected
- Check companion logs in its window
- Verify `COMPANION_BACKEND_URL` is correct: `http://localhost:5000`

**Dashboard shows error?**
- Backend must be running on port 5000
- Check: http://localhost:5000/health returns "ok"

**Flutter won't start?**
```powershell
# Ensure Chrome is available
flutter config --list | grep chrome
# Or specify Chrome path
flutter run -d chrome --web-port=8080
```

**Want to stop everything cleanly?**
```powershell
# From any PowerShell window
Get-Process node, python, chrome -ErrorAction SilentlyContinue | Stop-Process -Force
```

---

## 📖 **Files Overview**

```
exam_proctoring_app/
├── run_all.ps1           ← PowerShell launcher (RECOMMENDED)
├── run_all.bat           ← Batch file launcher
├── unified_proxy.js      ← Optional single-port proxy
│
├── backend/              ← Node.js API server (port 5000)
├── lib/                  ← Flutter frontend (port 8080)
└── camera_companion/     ← Python camera service
```

---

## 🎬 **Typical Workflow**

```bash
# 1. Start everything (in project root)
.\run_all.ps1

# 2. Wait ~10 seconds for all services

# 3. Open browser tabs:
Start "http://localhost:8080"              # Student app
Start "http://localhost:5000/dashboard"    # Proctor view
Start "http://localhost:5000/health"       # Verify backend

# 4. Test camera:
#   - Student app: see camera widget
#   - Proctor dashboard: enter "exam-session-001" → see feed

# 5. When done:
# Ctrl+C in any window to stop all services
```

---

## 🎯 **Next Level: Deployment**

When ready for production:
- Install as Windows Service (use `install_service.ps1`)
- Use Docker for consistent environments
- Run on cloud VM (AWS/Azure)
- Set up SSL/TLS certificates
- Configure reverse proxy (nginx)

See `CAMERA_INTEGRATION_SETUP.md` and `CAMERA_SYSTEM_GUIDE.md` for details.

---

## ✅ **You're All Set!**

**Ready to start?**
```powershell
.\run_all.ps1
```

Then visit:
- 📱 http://localhost:8080 (Student)
- 💼 http://localhost:5000/dashboard (Proctor)

**Everything on localhost, everything in sync!** 🎉
