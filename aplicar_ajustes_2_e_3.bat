@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo Conectando ao projetor...
%ADB% connect 192.168.5.113:5555 >nul

echo === 1. Desativando telemetria e bloatware residual ===
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.shzhtxcz.txbox
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.sszztxr.app
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.oranth.accessibility
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.android.rockchip.camera2
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.android.cellbroadcastreceiver
%ADB% -s 192.168.5.113:5555 shell pm disable-user --user 0 com.android.cellbroadcastservice

echo === 2. Desativando varredura continua BLE em segundo plano ===
%ADB% -s 192.168.5.113:5555 shell settings put global ble_scan_always_enabled 0

echo === 3. Verificando estado das alteracoes ===
%ADB% -s 192.168.5.113:5555 shell settings get global ble_scan_always_enabled
