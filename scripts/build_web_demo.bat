@echo off
echo 🚀 Building Network Ninja Web Demo...

cd example
flutter build web --release

echo 📁 Copying to docs folder...
xcopy /E /I /Y build\web\* ..\docs\

echo ✅ Web demo built and copied to docs folder!
echo 🌐 You can now enable GitHub Pages in your repository settings:
echo    - Go to Settings → Pages
echo    - Set Source to 'Deploy from a branch'
echo    - Set Branch to 'master' and folder to '/docs'
echo    - Save
echo.
echo 📍 Your web demo will be available at: https://bluematterin.github.io/network_ninja/
echo.
echo 💡 To test the web demo in debug mode:
echo    cd example ^&^& flutter run -d chrome
pause
