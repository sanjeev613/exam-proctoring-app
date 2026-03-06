<#
.SYNOPSIS
    Unified Exam Proctoring App Launcher - All in One PowerShell Script
    
.DESCRIPTION
    This script starts Backend, Frontend, and Camera Companion services
    All services run on localhost simultaneously
    
.USAGE
    .\run_all.ps1
#>

param(
    [switch]$Clean,
    [switch]$NoCamera
)

$ErrorActionPreference = 'Continue'

# Banner
Write-Host "
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   📚 Exam Proctoring App - Unified Launcher                    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

# Verify prerequisites
if (!(Test-Path "backend")) {
    Write-Host "❌ Error: 'backend' folder not found" -ForegroundColor Red
    exit 1
}

if (!(Test-Path "camera_companion")) {
    Write-Host "❌ Error: 'camera_companion' folder not found" -ForegroundColor Red
    exit 1
}

# Clean up old processes if requested
if ($Clean) {
    Write-Host "🧹 Cleaning up existing processes..." -ForegroundColor Yellow
    Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
}

Write-Host ""

# 1. Start Backend
Write-Host "1️⃣  Starting Backend Server (port 5000)..." -ForegroundColor Cyan
Write-Host "   Starting in background..." -ForegroundColor Gray

$backendJob = Start-Job -Name "Backend" -ScriptBlock {
    Set-Location $using:PSScriptRoot\backend
    npm start 2>&1
}

Start-Sleep -Seconds 4

# Verify backend is running
$healthCheck = $null
try {
    $healthCheck = Invoke-WebRequest -Uri 'http://localhost:5000/health' -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
}
catch {}

if ($healthCheck.StatusCode -eq 200) {
    Write-Host "✅ Backend running at http://localhost:5000" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend may not be responding yet (still starting)" -ForegroundColor Yellow
}

# 2. Start Camera Companion (unless -NoCamera flag)
if (!$NoCamera) {
    Write-Host ""
    Write-Host "2️⃣  Starting Camera Companion..." -ForegroundColor Cyan
    Write-Host "   Setting up Python environment..." -ForegroundColor Gray

    $cameraJob = Start-Job -Name "Camera" -ScriptBlock {
        $companionPath = "$using:PSScriptRoot\camera_companion"
        Set-Location $companionPath
        
        # Create venv if needed
        if (!(Test-Path "venv")) {
            Write-Host "   Creating Python virtual environment..." -ForegroundColor Gray
            python -m venv venv 2>&1
        }
        
        # Activate and install deps
        & .\venv\Scripts\Activate.ps1
        pip install -q -r requirements.txt 2>$null
        
        # Set environment variables
        $env:COMPANION_BACKEND_URL = 'http://localhost:5000'
        $env:COMPANION_SESSION_ID = 'exam-session-001'
        $env:PROTOTYPE_SECRET = 'prototype-secret-key'
        
        # Run companion
        python companion_production.py 2>&1
    }
    
    Start-Sleep -Seconds 2
    Write-Host "✅ Camera Companion starting (check window for status)" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "2️⃣  Skipping Camera Companion (use -NoCamera flag to disable)" -ForegroundColor Gray
}

# 3. Start Flutter Frontend
Write-Host ""
Write-Host "3️⃣  Starting Flutter Frontend (port 8080)..." -ForegroundColor Cyan
Write-Host "   Building and launching Chrome..." -ForegroundColor Gray

$flutterJob = Start-Job -Name "Frontend" -ScriptBlock {
    Set-Location $using:PSScriptRoot
    flutter run -d chrome --web-port=8080 2>&1
}

Start-Sleep -Seconds 6

# Success banner
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                     🎉 All services running!                   ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║                                                                ║" -ForegroundColor Green
Write-Host "║  📱 Student Exam App:    http://localhost:8080                 ║" -ForegroundColor Green
Write-Host "║  💼 Proctor Dashboard:   http://localhost:5000/dashboard       ║" -ForegroundColor Green
if (!$NoCamera) {
    Write-Host "║  🎥 Camera Companion:    Running (check background window)     ║" -ForegroundColor Green
}
Write-Host "║  🔗 Backend API:         http://localhost:5000/api             ║" -ForegroundColor Green
Write-Host "║  ⚙️  Health Check:        http://localhost:5000/health         ║" -ForegroundColor Green
Write-Host "║                                                                ║" -ForegroundColor Green
Write-Host "║  📖 Full Guide:          CAMERA_SYSTEM_GUIDE.md               ║" -ForegroundColor Green
Write-Host "║  ⚙️  Setup Help:         CAMERA_INTEGRATION_SETUP.md           ║" -ForegroundColor Green
Write-Host "║                                                                ║" -ForegroundColor Green
Write-Host "║  To stop: Press Ctrl+C or close command windows              ║" -ForegroundColor Green
Write-Host "║                                                                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow

# Wait for jobs
while ($true) {
    Start-Sleep -Seconds 1
    
    # Check if jobs are still alive
    $backend = Get-Job -Name "Backend" -ErrorAction SilentlyContinue
    $flutter = Get-Job -Name "Frontend" -ErrorAction SilentlyContinue
    $camera = Get-Job -Name "Camera" -ErrorAction SilentlyContinue
    
    # If any stopped, exit
    if ($backend.State -ne "Running" -or $flutter.State -ne "Running") {
        Write-Host ""
        Write-Host "One or more services stopped" -ForegroundColor Yellow
        break
    }
}

# Cleanup
Write-Host ""
Write-Host "⏹️  Stopping services..." -ForegroundColor Yellow
Get-Job | Stop-Job
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Host "✅ All services stopped" -ForegroundColor Green
