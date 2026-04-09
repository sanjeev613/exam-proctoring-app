# exam_proctoring_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local run (all services)
Open three PowerShell windows:
1) Backend: `cd C:\Users\sanje\exam_proctoring_app\backend; cmd /c npm start`
2) Frontend: `cd C:\Users\sanje\exam_proctoring_app; flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1`
3) Camera companion: 
   ```
   cd C:\Users\sanje\exam_proctoring_app\camera_companion
   .\venv\Scripts\Activate.ps1
   $env:COMPANION_SESSION_ID='exam-session-001'   # match dashboard input
   $env:COMPANION_BACKEND_URL='http://localhost:5000'
   .\venv\Scripts\python.exe companion_production.py
   ```
Visit http://localhost:8080 (student) and http://localhost:5000/dashboard (proctor) with the same session ID.

## Flutter run shortcuts
- `r` hot reload | `R` hot restart
- `h` help / list commands
- `d` detach (leave app running)
- `c` clear screen
- `q` quit
