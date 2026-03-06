@echo off
REM Unified Exam Proctoring App - All in One Launcher
REM This script starts Backend, Frontend, and Camera Companion services
REM All running on localhost (backend: 5000, frontend: 8080, camera: companion)

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║   📚 Exam Proctoring App - Unified Launcher                    ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Check if all required folders exist
if not exist "backend" (
    echo ❌ Error: backend folder not found
    exit /b 1
)

if not exist "camera_companion" (
    echo ❌ Error: camera_companion folder not found
    exit /b 1
)

echo Cleaning up any existing processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo.
echo 1️⃣  Starting Backend Server (port 5000)...
start "Backend Server" cmd /k "cd backend && npm start"
timeout /t 3 /nobreak >nul

echo 2️⃣  Starting Camera Companion (captures frames)...
cd camera_companion
if not exist "venv" (
    echo    Creating Python virtual environment...
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install -q -r requirements.txt 2>nul
cd ..
start "Camera Companion" cmd /k "cd camera_companion && venv\Scripts\python.exe companion_production.py"
timeout /t 2 /nobreak >nul

echo 3️⃣  Starting Flutter Frontend (port 8080)...
start "Flutter Frontend" cmd /k "flutter run -d chrome --web-port=8080"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                     🎉 All services starting                   ║
echo ╠════════════════════════════════════════════════════════════════╣
echo ║                                                                ║
echo ║  📱 Student Exam App:    http://localhost:8080                 ║
echo ║  💼 Proctor Dashboard:   http://localhost:5000/dashboard       ║
echo ║  🎥 Camera Companion:    Running (background)                  ║
echo ║  🔗 Backend API:         http://localhost:5000/api             ║
echo ║                                                                ║
echo ║  📖 Full Guide: CAMERA_SYSTEM_GUIDE.md                        ║
echo ║  ⚙️  Setup Help: CAMERA_INTEGRATION_SETUP.md                   ║
echo ║                                                                ║
echo ║  To stop all services: Close all command windows              ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

pause
