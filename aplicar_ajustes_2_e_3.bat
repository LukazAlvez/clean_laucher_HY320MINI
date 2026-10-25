@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo === 1. Desativando telemetria e bloatware residual ===
%ADB% shell pm disable-user --user 0 com.shzhtxcz.txbox
%ADB% shell pm disable-user --user 0 com.sszztxr.app
%ADB% shell pm disable-user --user 0 com.oranth.accessibility
%ADB% shell pm disable-user --user 0 com.android.rockchip.camera2
%ADB% shell pm disable-user --user 0 com.android.cellbroadcastreceiver
%ADB% shell pm disable-user --user 0 com.android.cellbroadcastservice

echo === 2. Desativando varredura continua BLE em segundo plano ===
%ADB% shell settings put global ble_scan_always_enabled 0

echo === 3. Verificando estado das alteracoes ===
%ADB% shell settings get global ble_scan_always_enabled
