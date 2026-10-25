@echo off
set ADB=platform-tools\adb.exe
if "%1"=="" (
    set /p IP="Digite o IP do projetor (ex: 192.168.1.50): "
) else (
    set IP=%1
)
set TARGET=%IP%:5555
set OUT=d:\Projetos Antgravity\projeto 01\diagnostico

if not exist "%OUT%" mkdir "%OUT%"

%ADB% connect %TARGET%

echo === DEVICE INFO ===
%ADB% shell "getprop ro.product.model" > "%OUT%\device_info.txt"
%ADB% shell "getprop ro.product.manufacturer" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.build.version.release" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.build.version.sdk" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.build.display.id" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.product.cpu.abi" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.board.platform" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.build.type" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.product.device" >> "%OUT%\device_info.txt"
%ADB% shell "getprop ro.product.brand" >> "%OUT%\device_info.txt"
echo device_info done.

echo === ALL PACKAGES ===
%ADB% shell "pm list packages -s" > "%OUT%\system_packages.txt"
%ADB% shell "pm list packages -3" > "%OUT%\third_party_packages.txt"
%ADB% shell "pm list packages -d" > "%OUT%\disabled_packages.txt"
echo packages done.

echo === MEMORY ===
%ADB% shell "free -m" > "%OUT%\memory.txt"
%ADB% shell "cat /proc/meminfo" >> "%OUT%\memory.txt"
echo memory done.

echo === RUNNING SERVICES ===
%ADB% shell "dumpsys activity services" > "%OUT%\running_services.txt"
echo services done.

echo === CURRENT LAUNCHER ===
%ADB% shell "dumpsys window | grep mCurrentFocus" > "%OUT%\current_launcher.txt"
%ADB% shell "dumpsys window | grep mFocusedApp" >> "%OUT%\current_launcher.txt"
echo launcher done.

echo === SETTINGS ===
%ADB% shell "settings get global animator_duration_scale" > "%OUT%\animation_settings.txt"
%ADB% shell "settings get global transition_animation_scale" >> "%OUT%\animation_settings.txt"
%ADB% shell "settings get global window_animation_scale" >> "%OUT%\animation_settings.txt"
echo settings done.

echo === DISK SPACE ===
%ADB% shell "df -h" > "%OUT%\disk_space.txt"
echo disk done.

echo DIAGNOSTIC_COMPLETE
