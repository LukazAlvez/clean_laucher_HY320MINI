@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"
set OUT=d:\Projetos Antgravity\projeto 01\screens
if not exist "%OUT%" mkdir "%OUT%"
%ADB% connect %IP% >nul
%ADB% install -r "d:\Projetos Antgravity\projeto 01\DarkLauncher.apk"
%ADB% shell am force-stop com.antigravity.darklauncher
%ADB% shell am start -W -n com.antigravity.darklauncher/.MainActivity
ping -n 3 127.0.0.1 >nul
%ADB% exec-out screencap -p > "%OUT%\v2_home.png"
%ADB% shell input keyevent 20
ping -n 3 127.0.0.1 >nul
%ADB% exec-out screencap -p > "%OUT%\v2_pill_focus.png"
%ADB% shell input keyevent 23
ping -n 3 127.0.0.1 >nul
%ADB% exec-out screencap -p > "%OUT%\v2_allapps.png"
%ADB% shell input keyevent 4
ping -n 3 127.0.0.1 >nul
%ADB% shell dumpsys activity activities | findstr /i "mResumedActivity topResumedActivity"
