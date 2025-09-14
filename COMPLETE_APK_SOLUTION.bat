@echo off
echo ========================================
echo Complete APK Solution - Fix All Issues
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building optimized APK...
echo Building release APK with split architecture...
flutter build apk --release --split-per-abi

echo.
echo Step 4: Building single APK as backup...
flutter build apk --release

echo.
echo ========================================
echo APK FILES CREATED:
echo ========================================
echo.

echo Checking for APK files...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✓ app-release.apk - Single APK (51MB+)
    echo   Use this if split APKs don't work
)

if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    echo ✓ app-arm64-v8a-release.apk - For 64-bit devices (smaller)
    echo   Use this for most modern Android devices
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    echo ✓ app-armeabi-v7a-release.apk - For 32-bit devices
    echo   Use this for older Android devices
)

echo.
echo ========================================
echo INSTALLATION GUIDE:
echo ========================================
echo.

echo 1. CHOOSE THE RIGHT APK:
echo    - For modern devices (2018+): Use app-arm64-v8a-release.apk
echo    - For older devices: Use app-armeabi-v7a-release.apk
echo    - If unsure: Use app-release.apk
echo.

echo 2. INSTALLATION STEPS:
echo    a) Copy APK to your Android device
echo    b) Go to Settings ^> Security ^> Install unknown apps
echo    c) Enable for your file manager/browser
echo    d) Open the APK file and install
echo    e) Grant ALL permissions when prompted
echo.

echo 3. PERMISSIONS REQUIRED:
echo    - Camera (for video recording)
echo    - Location (for AR features)
echo    - Storage (for saving videos)
echo    - Microphone (for audio recording)
echo    - Internet (for backend communication)
echo.

echo ========================================
echo TROUBLESHOOTING COMMON ISSUES:
echo ========================================
echo.

echo ISSUE: "App not installed"
echo SOLUTION: 
echo - Enable "Install from Unknown Sources"
echo - Uninstall any previous version first
echo - Check device storage space (need 100MB+)
echo.

echo ISSUE: "App crashes on startup"
echo SOLUTION:
echo - Grant all permissions in Settings ^> Apps ^> GoChamp
echo - Check Android version (needs 5.0+)
echo - Restart device after installation
echo.

echo ISSUE: "Black screen or UI not loading"
echo SOLUTION:
echo - Check device RAM (needs 2GB+)
echo - Grant all app permissions
echo - Try restarting the app
echo.

echo ISSUE: "Camera not working"
echo SOLUTION:
echo - Grant camera permission
echo - Check if another app is using camera
echo - Restart the app
echo.

echo ========================================
echo BACKEND SETUP (For Full Functionality):
echo ========================================
echo.

echo To enable AI analysis and backend features:
echo 1. Open a new terminal/command prompt
echo 2. Navigate to: cd ..\backend
echo 3. Create virtual environment: python -m venv .venv
echo 4. Activate it: .venv\Scripts\activate
echo 5. Install dependencies: pip install -r requirements.txt
echo 6. Start server: python main.py
echo 7. Update API URL in app if needed
echo.

echo ========================================
echo SUCCESS INDICATORS:
echo ========================================
echo.

echo Your APK is working correctly when:
echo ✓ App installs without errors
echo ✓ Splash screen loads with GoChamp branding
echo ✓ Login screen appears
echo ✓ Camera permission is requested
echo ✓ App doesn't crash on startup
echo ✓ All UI elements are responsive
echo.

echo ========================================
echo NEXT STEPS:
echo ========================================
echo.

echo 1. Install the appropriate APK on your device
echo 2. Grant all permissions
echo 3. Test the app functionality
echo 4. Start backend server for full features
echo 5. Test video recording and AI analysis
echo.

pause
