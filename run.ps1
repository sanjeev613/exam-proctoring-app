# Run Exam Proctoring App - Backend + Frontend in Chrome

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Exam Proctoring App - Startup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Kill any existing process on port 5000
Write-Host "Cleaning up port 5000..." -ForegroundColor Yellow
$portCheck = netstat -ano 2>$null | findstr ":5000" 
if ($portCheck) {
    $procId = ($portCheck -split '\s+')[-1]
    if ($procId -match '^\d+$') {
        taskkill /PID $procId /F 2>$null
        Start-Sleep -Seconds 1
    }
}

# Start Backend Server
Write-Host "Starting Backend Server on port 5000..." -ForegroundColor Green
$backendPath = "c:\Users\sanje\exam_proctoring_app\backend"
$backendProcess = Start-Process -PassThru -NoNewWindow -FilePath "node" -ArgumentList "src/server.js" -WorkingDirectory $backendPath

Write-Host "Backend started (PID: $($backendProcess.Id))" -ForegroundColor Green
Start-Sleep -Seconds 3

# Verify backend
Write-Host "Checking backend connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "Backend is running!" -ForegroundColor Green
} catch {
    Write-Host "Backend connection failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Starting Flutter Frontend in Chrome..." -ForegroundColor Green
Write-Host "Frontend URL: http://localhost:xxxxx" -ForegroundColor Cyan
Write-Host "Backend URL: http://localhost:5000/api" -ForegroundColor Cyan
Write-Host ""

# Start Flutter app in Chrome
Push-Location "c:\Users\sanje\exam_proctoring_app"
flutter run -d chrome
Pop-Location
