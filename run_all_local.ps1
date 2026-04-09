# Build Flutter web, then start backend and open browser to single origin (localhost:5000)
# Usage: run PowerShell with ExecutionPolicy Bypass and run this script from project root

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "Project root: $projectRoot"

# 1) Build Flutter web
Write-Host "Building Flutter web app... this may take a while" -ForegroundColor Yellow
Push-Location $projectRoot
$build = flutter build web
if ($LASTEXITCODE -ne 0) {
  Write-Host "Flutter build failed. Please fix build errors and re-run." -ForegroundColor Red
  Pop-Location
  exit 1
}
Pop-Location

# 2) Move build artifacts to backend (server will serve from build/web)
$buildSource = Join-Path $projectRoot "build\web"
if (-Not (Test-Path $buildSource)) {
  Write-Host "Build output not found at $buildSource" -ForegroundColor Red
  exit 1
}

Write-Host "Build complete. Starting backend..." -ForegroundColor Green

# Kill existing node processes (optional)
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Start backend
$backendPath = Join-Path $projectRoot "backend"
Start-Process -FilePath node -ArgumentList "src/server.js" -WorkingDirectory $backendPath -PassThru | Out-Null
Start-Sleep -Seconds 3

# Open browser to backend root (serves frontend)
Start-Process "http://localhost:5000"

Write-Host "All started: backend + frontend served at http://localhost:5000" -ForegroundColor Cyan
