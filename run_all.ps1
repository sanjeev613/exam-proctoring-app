<#!
.SYNOPSIS
    Unified Exam Proctoring App Launcher - All in One PowerShell Script
.DESCRIPTION
    Starts backend (port 5000), camera companion, and Flutter web frontend (port 8080) on localhost.
.USAGE
    .\run_all.ps1 [-Clean] [-NoCamera]
#>

param(
    [switch]$Clean,
    [switch]$NoCamera
)

$ErrorActionPreference = 'Continue'

Write-Host "=== Exam Proctoring App - Unified Launcher ==="

# Verify prerequisites
if (!(Test-Path "$PSScriptRoot\backend")) {
    Write-Host "Error: 'backend' folder not found" -ForegroundColor Red
    exit 1
}

if (!(Test-Path "$PSScriptRoot\camera_companion")) {
    Write-Host "Error: 'camera_companion' folder not found" -ForegroundColor Red
    exit 1
}

# Track spawned processes so we can stop them later
$started = @()
function Start-Prog {
    param(
        [string]$Name,
        [string]$FilePath,
        [string]$ArgList,
        [string]$WorkingDir
    )
    $p = Start-Process -FilePath $FilePath -ArgumentList $ArgList -WorkingDirectory $WorkingDir -WindowStyle Normal -PassThru
    $started += [pscustomobject]@{ Name = $Name; Pid = $p.Id }
    Write-Host "$Name started (PID $($p.Id))" -ForegroundColor Green
    return $p
}

# Clean up old processes if requested
if ($Clean) {
    Write-Host "Cleaning up existing processes..." -ForegroundColor Yellow
    Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# 1. Start Backend
Write-Host "Starting Backend (port 5000)..." -ForegroundColor Cyan
Start-Prog -Name "Backend" -FilePath "cmd.exe" -ArgList "/c npm start" -WorkingDir "$PSScriptRoot\backend" | Out-Null
Start-Sleep -Seconds 4

# Verify backend is running
$healthCheck = $null
try {
    $healthCheck = Invoke-WebRequest -Uri 'http://localhost:5000/health' -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
} catch {}
if ($healthCheck.StatusCode -eq 200) {
    Write-Host "Backend running at http://localhost:5000" -ForegroundColor Green
} else {
    Write-Host "Backend may still be starting..." -ForegroundColor Yellow
}

# 2. Start Camera Companion (unless -NoCamera flag)
if (-not $NoCamera) {
    Write-Host "Starting Camera Companion..." -ForegroundColor Cyan
    $companionCmd = "cd `"$PSScriptRoot\camera_companion`"; if (-not (Test-Path venv)) { python -m venv venv }; & .\venv\Scripts\Activate.ps1; pip install -q -r requirements.txt; $env:COMPANION_BACKEND_URL='http://localhost:5000'; $env:COMPANION_SESSION_ID='9ca3c5c2-25f6-414a-83d3-5176f79fe8a1'; $env:PROTOTYPE_SECRET='prototype-secret-key'; python companion_production.py"
    Start-Prog -Name "Camera" -FilePath "powershell.exe" -ArgList "-NoProfile -ExecutionPolicy Bypass -Command \"$companionCmd\"" -WorkingDir "$PSScriptRoot\camera_companion" | Out-Null
} else {
    Write-Host "Skipping Camera Companion (-NoCamera flag)." -ForegroundColor Gray
}

# 3. Start Flutter Frontend
Write-Host "Starting Flutter Frontend (port 8080)..." -ForegroundColor Cyan
$frontendCmd = "cd `"$PSScriptRoot`"; flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1"
Start-Prog -Name "Frontend" -FilePath "powershell.exe" -ArgList "-NoProfile -ExecutionPolicy Bypass -Command \"$frontendCmd\"" -WorkingDir "$PSScriptRoot" | Out-Null
Start-Sleep -Seconds 6

Write-Host "=== All services launched ===" -ForegroundColor Green
Write-Host "Student app:   http://localhost:8080"
Write-Host "Proctor dash:  http://localhost:5000/dashboard"
Write-Host "Backend API:   http://localhost:5000/api"
if (-not $NoCamera) { Write-Host "Camera:        running (separate window)" }
Write-Host "Health check:  http://localhost:5000/health"
Write-Host "To stop: close the spawned windows or press Ctrl+C here."

Write-Host ""
Write-Host "Press Ctrl+C here to stop all services." -ForegroundColor Yellow
try {
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    Write-Host "Stopping services..." -ForegroundColor Yellow
    foreach ($p in $started) {
        try { Stop-Process -Id $p.Pid -Force -ErrorAction SilentlyContinue } catch {}
    }
    Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "All services stopped" -ForegroundColor Green
}

