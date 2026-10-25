@echo off
set ADB="d:\Projetos Antgravity\projeto 01\platform-tools\adb.exe"

echo === Reativando pacotes ===
%ADB% shell pm enable com.shzhtxcz.txbox
%ADB% shell pm enable com.sszztxr.app
%ADB% shell pm enable com.oranth.accessibility
%ADB% shell pm enable com.android.rockchip.camera2
%ADB% shell pm enable com.android.cellbroadcastreceiver
%ADB% shell pm enable com.android.cellbroadcastservice

echo === Restaurando varredura BLE ===
%ADB% shell settings put global ble_scan_always_enabled 1
