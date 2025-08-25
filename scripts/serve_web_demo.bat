@echo off
echo 🚀 Starting Network Ninja Web Demo Server...
echo 📍 Local URL: http://localhost:8000
echo 🌐 Public URL: https://bluematterin.github.io/network_ninja/
echo.
echo Press Ctrl+C to stop the server
echo.

cd web_demo
python -m http.server 8000

if errorlevel 1 (
    echo ❌ Python not found. Please install Python or use another HTTP server.
    echo Alternative: cd web_demo ^&^& npx serve .
    pause
)
