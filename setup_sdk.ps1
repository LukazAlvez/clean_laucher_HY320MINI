$toolsDir = "d:\Projetos Antgravity\projeto 01\build-tools"
if (!(Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir | Out-Null }

Write-Output "=== 1. Downloading Android Build Tools 33.0.2 ==="
& curl.exe -s -L -o "$toolsDir\build-tools.zip" "https://dl.google.com/android/repository/build-tools_r33.0.2-windows.zip"
Write-Output "Extracting build-tools..."
& tar.exe -xf "$toolsDir\build-tools.zip" -C $toolsDir
Remove-Item "$toolsDir\build-tools.zip" -Force

Write-Output "=== 2. Downloading Android Platform 32 (android.jar) ==="
& curl.exe -s -L -o "$toolsDir\platform-32.zip" "https://dl.google.com/android/repository/platform-32_r01.zip"
Write-Output "Extracting platform-32..."
& tar.exe -xf "$toolsDir\platform-32.zip" -C $toolsDir
Remove-Item "$toolsDir\platform-32.zip" -Force

Write-Output "=== 3. Downloading Kotlin Compiler 1.9.22 ==="
& curl.exe -s -L -o "$toolsDir\kotlinc.zip" "https://github.com/JetBrains/kotlin/releases/download/v1.9.22/kotlin-compiler-1.9.22.zip"
Write-Output "Extracting kotlinc..."
& tar.exe -xf "$toolsDir\kotlinc.zip" -C $toolsDir
Remove-Item "$toolsDir\kotlinc.zip" -Force

Write-Output "ALL_TOOLS_READY"
