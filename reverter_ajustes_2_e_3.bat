@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo Conectando ao projetor...
%ADB% connect 192.168.5.113:5555 >nul

echo === Reativando pacotes ===
%ADB% -s 192.168.5.113:5555 shell pm enable com.shzhtxcz.txbox
%ADB% -s 192.168.5.113:5555 shell pm enable com.sszztxr.app
%ADB% -s 192.168.5.113:5555 shell pm enable com.oranth.accessibility
%ADB% -s 192.168.5.113:5555 shell pm enable com.android.rockchip.camera2
%ADB% -s 192.168.5.113:5555 shell pm enable com.android.cellbroadcastreceiver
%ADB% -s 192.168.5.113:5555 shell pm enable com.android.cellbroadcastservice

echo === Restaurando varredura BLE ===
%ADB% -s 192.168.5.113:5555 shell settings put global ble_scan_always_enabled 1
