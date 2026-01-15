# PowerShell script to get SHA fingerprint for Android debug keystore

$debugKeystore = "$env:USERPROFILE\.android\debug.keystore"

Write-Host "Looking for debug keystore at: $debugKeystore"

if (Test-Path $debugKeystore) {
    Write-Host "Debug keystore found!" -ForegroundColor Green
    
    # Try to find keytool in Java installation
    $javaPaths = @(
        "$env:JAVA_HOME\bin\keytool.exe",
        "${env:ProgramFiles}\Java\*\bin\keytool.exe",
        "${env:ProgramFiles(x86)}\Java\*\bin\keytool.exe",
        "$env:ANDROID_HOME\*\*\keytool.exe"
    )
    
    $keytool = $null
    foreach ($path in $javaPaths) {
        $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $keytool = $found.FullName
            break
        }
    }
    
    if ($keytool) {
        Write-Host "Using keytool at: $keytool" -ForegroundColor Green
        Write-Host "`nGetting SHA fingerprints..." -ForegroundColor Yellow
        
        & "$keytool" -list -v -keystore "$debugKeystore" -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1|SHA256"
    } else {
        Write-Host "Keytool not found. Please ensure Java JDK is installed." -ForegroundColor Red
        Write-Host "`nAlternative: Use Android Studio -> Build -> Generate Signed Bundle/APK -> Create new keystore"
    }
} else {
    Write-Host "Debug keystore not found at $debugKeystore" -ForegroundColor Red
    Write-Host "Run 'flutter run' once to generate the debug keystore automatically."
}

Write-Host "`nNext steps:"
Write-Host "1. Copy the SHA1 fingerprint above"
Write-Host "2. Go to Firebase Console -> Project Settings -> Your Android App"
Write-Host "3. Add the SHA fingerprint"
Write-Host "4. Download updated google-services.json"
Write-Host "5. Replace android/app/google-services.json"