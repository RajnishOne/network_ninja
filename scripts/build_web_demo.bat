@echo off
echo 🚀 Building Network Ninja Web Demo...

cd example
call flutter build web --release

echo 📁 Copying to network_ninja_web folder...

REM Check if directory exists, if not create it
if not exist "..\..\network_ninja_web" (
    echo 📂 Creating network_ninja_web directory...
    mkdir "..\..\network_ninja_web"
)

echo 📋 Copying files...
call xcopy /E /I /Y build\web\* ..\..\network_ninja_web\

echo ✅ Web demo built and copied to network_ninja_web folder!