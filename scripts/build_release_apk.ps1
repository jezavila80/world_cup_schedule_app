# scripts/build_release_apk.ps1

# 1. Error handling: check if pubspec.yaml exists
$pubspecPath = "pubspec.yaml"
if (-not (Test-Path $pubspecPath)) {
    Write-Error "Error: pubspec.yaml not found in the current directory."
    Exit 1
}

Write-Host "Reading app details from pubspec.yaml..."
# Parse pubspec.yaml manually for name and version
$pubspecContent = Get-Content $pubspecPath -Raw

# Match name
$nameRegex = "(?mi)^name:\s*([a-zA-Z0-9_\-]+)"
if ($pubspecContent -match $nameRegex) {
    $appName = $Matches[1].Trim()
} else {
    Write-Error "Error: Could not parse app name from pubspec.yaml."
    Exit 1
}

# Match version
$versionRegex = "(?mi)^version:\s*([a-zA-Z0-9_\-\.\+]+)"
if ($pubspecContent -match $versionRegex) {
    $appVersion = $Matches[1].Trim()
} else {
    Write-Error "Error: Could not parse app version from pubspec.yaml."
    Exit 1
}

Write-Host "App Name: $appName"
Write-Host "Version: $appVersion"

# 2. Run flutter clean
Write-Host "Running flutter clean..."
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: flutter clean failed."
    Exit 1
}

# 3. Run flutter pub get
Write-Host "Running flutter pub get..."
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: flutter pub get failed, retrying once..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: flutter pub get failed."
        Exit 1
    }
}

# 4. Run flutter build apk --release
Write-Host "Building release APK..."
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error: flutter build apk --release failed."
    Exit 1
}

# 5. Check if build output exists
$srcApk = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $srcApk)) {
    Write-Error "Error: Generated APK not found at $srcApk"
    Exit 1
}

# 6. Create dist/apk/ if it does not exist
$distDir = "dist/apk"
if (-not (Test-Path $distDir)) {
    Write-Host "Creating directory $distDir..."
    New-Item -ItemType Directory -Force -Path $distDir | Out-Null
}

# 7. Copy and rename
$destApkName = "${appName}_v${appVersion}.apk"
$destApkPath = Join-Path $distDir $destApkName

Write-Host "Copying APK to $destApkPath..."
Copy-Item -Path $srcApk -Destination $destApkPath -Force

if (-not (Test-Path $destApkPath)) {
    Write-Error "Error: Failed to copy APK to $destApkPath"
    Exit 1
}

Write-Host "`nAPK generated successfully:"
Write-Host $destApkPath
